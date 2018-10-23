## Assignment 2
### Q1. Toy problem (20 pts)

The goal of this work is to reconstruct image using only gradients and a pixel of original image. As shown in Fig. 1, I calculated gradients of each H and W directions using simple gradient formula.

![\Large grad_h(h, w) = image(h+1, w) - image(h, w)](https://latex.codecogs.com/svg.latex?grad_h(h,%20w)%20=%20image(h+1,%20w)%20-%20image(h,%20w))

![\Large grad_h(h, w) = image(h+1, w) - image(h, w)](https://latex.codecogs.com/svg.latex?grad_w(h,%20w)%20=%20image(h,%20w+1)%20-%20image(h,%20w))

After calculating gradients, I reconstructed image using LSE solver of MATLAB.
The difference between input image and reconstructed image is **8.3554e-12** which means the reconstruction is successful.

**Figure 1**

![Alt text](/assignment3_result/results/Q1/figure/figure1.png)

### Q2. Laplacian pyramid (20 pts)

Before blending, I preprocessed given images using photoshop. I copy and pasted source images to a empty alpha channel enabled image which size is same as target image. Also, I made masks using eraser in photoshop to prepare blending.

**Figure 2**

![](/assignment3_result/data/preprocessed/chick_original.png)
![](/assignment3_result/data/preprocessed/chick.png)


Using these images, I made image mask using alpha channel.
```matlab
[X, N_, N_] = imread('data/preprocessed/penguin_original.png');
[N_, N_, alpha] = imread('data/preprocessed/penguin.png');
[imh, imw, imc] = size(X);
X_penguin = im2double(X);
M_penguin = zeros([imh imw]);
M_penguin(alpha > 0) = 1;
```

**Figure 3**

![](/assignment3_result/results/Q2/figure/figure1.png)


Fig. 4 shows target image, copy and pasted image and two bounding box. I obtained sub-target image which is designated position to be blended and I draw red rectangle of the area.

**Figure 4**

![](/assignment3_result/results/Q2/figure/figure2.png)

![](/assignment3_result/results/Q2/figure/figure3.png)

![](/assignment3_result/results/Q2/figure/figure4.png)


Using LMS solver of MATLAB, I obtained blended image.

**Figure 5**

![](/assignment3_result/results/Q2/figure/figure5.png)


**Result image**

![](/assignment3_result/results/Q2/Q2_blended_image.png)


As shown in Fig. 4, edge of blended image is not natural for some area. The LMS solver finds global minimum point, however, the error is not exactly 0. Applying alpha blending near the edge would reduce seam.



