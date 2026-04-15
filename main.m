clc; clear; close all;

addpath('C:\Users\Shweta Sharma\Desktop\07\shearlet\');   

A = im2double(imread('2(A).tif'));
B = im2double(imread('2(B).tif'));

if size(A,3)==3, A = rgb2gray(A); end
isColorB = (size(B,3) == 3);

if isColorB
    B_ycbcr = rgb2ycbcr(B);
    B_Y = B_ycbcr(:,:,1);
    B_gray_for_fusion = B_Y;
else
    if size(B,3) == 3
        B = rgb2gray(B);
    end
    B_gray_for_fusion = B;
end

pfilt = 'maxflat';
shear_parameters.dcomp = [5 5 5 5];
shear_parameters.dsize = [32 32 32 32];

[Y1, shear_f] = nsst_dec2(A, shear_parameters, pfilt);
[Y2, ~]       = nsst_dec2(B_gray_for_fusion, shear_parameters, pfilt);

low1 = Y1{1};
low2 = Y2{1};
high1 = Y1(2:end);
high2 = Y2(2:end);

entropyObj = @(w) -entropy((w(1)*low1 + w(2)*low2) );

SearchAgents = 8;
Max_iter = 20;
lb = [0 0];
ub = [1 1];
dim = 2;

try
    [bestScore, bestPos] = GOA(SearchAgents, Max_iter, lb, ub, dim, entropyObj);
catch
    bestPos = [0.7 0.3];
end

w1 = bestPos(1);
w2 = 1 - w1;

low_fused = w1 * low1 + w2 * low2;

high_fused = cell(size(high1));

for lvl = 1:length(high1)

    A_blk = high1{lvl};
    B_blk = high2{lvl};
    [H,W,D] = size(A_blk);
    fused_blk = zeros(H,W,D);

    for d = 1:D

        A_h = A_blk(:,:,d);
        B_h = B_blk(:,:,d);
        A_ad = imdiffusefilt(A_h,'NumberOfIterations',12,'Connectivity','maximal');
        B_ad = imdiffusefilt(B_h,'NumberOfIterations',12,'Connectivity','maximal');

        SalA = abs(A_h - A_ad);
        SalB = abs(B_h - B_ad);

        WA = SalA ./ (SalA + SalB + 1e-12);
        WB = 1 - WA;

        fused_blk(:,:,d) = WA .* A_h + WB .* B_h;

    end

    high_fused{lvl} = fused_blk;
end

HF_vis = zeros(size(low_fused));

for lvl = 1:length(high_fused)
    HF_vis = HF_vis + sum(abs(high_fused{lvl}),3);
end

HF_vis = mat2gray(HF_vis);

dst = cell(size(Y1));

dst{1} = imresize(low_fused, size(Y1{1}));

for lvl = 1:length(high_fused)
    template = Y1{lvl+1};
    fused_blk = high_fused{lvl};

    if iscell(template)
        numDirs = numel(template);
        dst{lvl+1} = zeros(size(template{1},1), size(template{1},2), numDirs);
        for d = 1:numDirs
            dst{lvl+1}(:,:,d) = imresize(fused_blk(:,:,d), size(template{d}));
        end
    else
        [Ht,Wt,D] = size(template);
        dst{lvl+1} = zeros(Ht, Wt, D);
        for d = 1:D
            dst{lvl+1}(:,:,d) = imresize(fused_blk(:,:,d), [Ht Wt]);
        end
    end
end

Final = nsst_rec2(dst, shear_f, pfilt);
Final = mat2gray(Final);

if isColorB
    B_ycbcr_uint8 = rgb2ycbcr(im2uint8(B));
    B_ycbcr_uint8(:,:,1) = im2uint8(Final);
    F = ycbcr2rgb(B_ycbcr_uint8);
    F = im2double(F);
else
    F = Final;
end

figure; imshow(F,[]);
%imwrite (F, "C:\Users\Shweta Sharma\Desktop\02.png");