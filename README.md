# Saliency-Driven-Multi-Modal-Medical-Image-Fusion-via-NSST-with-Grasshopper-Optimization-Algorithm

The fusion method consists of the following steps:

1. NSST Decomposition:  
   Images are decomposed into low-frequency (approximation) and high-frequency (detail) sub-bands using the Non-Subsampled Shearlet Transform (NSST), providing multi-scale and multi-directional representation.

2. Fusion Strategy:  
   - Low-frequency components are fused using weighted averaging, where optimal weights are determined using the Grasshopper Optimization Algorithm (GOA) to maximize information content.  
   - High-frequency components are processed using anisotropic diffusion to extract salient features.  
   - Saliency-based adaptive weight maps are computed, and high-frequency components are fused using weighted averaging to preserve edges and textures.

3. Image Reconstruction:  
   The fused image is reconstructed from the combined low- and high-frequency sub-bands using inverse NSST.

4. Output:  
   The final fused image is displayed and saved.


📁 Files Included

- `main.m`: Main script for loading images, performing NSST-based fusion, displaying results, and saving the output.


🛠️ Requirements

- MATLAB R2018a or later
- Image Processing Toolbox  
- NSST Toolbox  


📊 Dataset Used

- https://github.com/dawachyophel/medical-fusion/tree/main/MyDataset  
- https://www.med.harvard.edu/aanlib/
