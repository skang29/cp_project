## Assignment 3
### Q1. Toy problem (20 pts)

The goal of this work is to reconstruct image using only gradients and a pixel of original image. As shown in Fig. 1, I calculated gradients of each H and W directions using simple gradient formula.

![\Large grad_h(h, w) = image(h+1, w) - image(h, w)](https://latex.codecogs.com/svg.latex?grad_h(h,%20w)%20=%20image(h+1,%20w)%20-%20image(h,%20w))

![\Large grad_h(h, w) = image(h+1, w) - image(h, w)](https://latex.codecogs.com/svg.latex?grad_w(h,%20w)%20=%20image(h,%20w+1)%20-%20image(h,%20w))

After calculating gradients, I reconstructed image using LSE solver of MATLAB.
The difference between input image and reconstructed image is **8.3554e-12** which means the reconstruction is successful.

**Figure 1**

![Alt text](/assignment3_result/results/Q1/figure/figure1.png)

### Q2. Poisson blending (50 pts)

Before blending, I preprocessed given images using photoshop. I copy and pasted source images to a empty alpha channel enabled image which size is same as target image. Also, I made masks using eraser in photoshop to prepare blending.

**Figure 2**

![a](/assignment3_result/data/preprocessed/chick_original.png)
![a](/assignment3_result/data/preprocessed/chick.png)


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

![a](/assignment3_result/results/Q2/figure/figure1.png)


Fig. 4 shows target image, copy and pasted image and two bounding box. I obtained sub-target image which is designated position to be blended and I draw red rectangle of the area.

**Figure 4**

![a](/assignment3_result/results/Q2/figure/figure2.png)

![a](/assignment3_result/results/Q2/figure/figure3.png)

![a](/assignment3_result/results/Q2/figure/figure4.png)


Using LMS solver of MATLAB, I obtained blended image.

**Figure 5**

![a](/assignment3_result/results/Q2/figure/figure5.png)


**Result image**

![a](/assignment3_result/results/Q2/Q2_blended_image.png)


As shown in Fig. 4, edge of blended image is not natural for some area. The LMS solver finds global minimum point, however, the error is not exactly 0. Applying alpha blending near the edge would reduce seam.


### Q3. Blending with mixed gradients (10 pts)

A little change in least squares problem, I could obtain a mixed gradients blending result. Fig. 6 shows both Poisson blending and mixed gradient blending.

**Figure 6**

![a](/assignment3_result/results/Q3/figure/figure1.png)


**Result image**

![a](/assignment3_result/results/Q3/Q3_mixed_gradient_blended_image.png)


Mixed gradient blending utilizes gradient of max value of both target and source images. This blends styles of two images and sometimes makes the image more natural. However, it shows more pale results compared to Poisson blending. Further examples are listed in Q4.



### Q4. My own examples (20 pts)

#### Example 1. ####

![a](/assignment3_result/results/Q4/1/figure1.png)

**Poisson blending**
![a](/assignment3_result/results/Q4/1/1_poisson.png)

**Mixed gradient blending**
![a](/assignment3_result/results/Q4/1/1_mixed_gradient.png)


Basketball in target image has more high frequency components compared to background. Thus, mixed gradient blending shows more natural result. However, mixed gradient blending shows more blurry edges compared to Poisson blending.


#### Example 2. ####

![a](/assignment3_result/results/Q4/3/figure3.png)

**Poisson blending**
![a](/assignment3_result/results/Q4/3/3_poisson.png)

**Mixed gradient blending**
![a](/assignment3_result/results/Q4/3/3_mixed_gradient.png)


In this case, mixed gradient blending shows noticeable results. Poisson blended image shows thick edge line which makes image unnatural. Mixed gradient method utilizes high frequency components of target image which reduces seam of edge.


#### Example 3. ####

![a](/assignment3_result/results/Q4/2/figure2.png)

**Poisson blending**
![a](/assignment3_result/results/Q4/2/2_poisson.png)

**Mixed gradient blending**
![a](/assignment3_result/results/Q4/2/2_mixed_gradient.png)


In this case, style between target and source image is considerably different. For Poisson blending, it shows unnatural edge. For mixed gradient blending, the source image lost its information.




### Q5. Bonus: Implement a different gradient-domain processing algorithm (Up to 50 pts)

Authors introduced non-photorealistic rendering in the paper and its result attracted the most. I implemented NPR filter using LMS solver of MATLAB.

![a](/assignment3_result/results/Q5/paper_figure.png)

![a](/assignment3_result/results/Q5/paper_equations.png)



**Result image**
![a](/assignment3_result/results/Q5/result.png)


### Trick or treat!
![a](/assignment3_result/results/Q5/failure_case.png)
