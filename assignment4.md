## You can find whole code from here

https://github.com/skang29/cp_project/tree/master/assignment4_result

I didn not add whole code to this report because of limited space.


## Assignment 4
### Q1. HDR Imaging (50 pts)
#### Sub Q1. Linearize rendered images (25 pts)

  The goal of this work is to linearize rendered image which is non-linear. Before merging images to HDR image, it is necessary to linearize rendered image. To achieve inverse function which linearize non-linear image, I made least squares optimization problem.

<img src="https://latex.codecogs.com/gif.latex?\min_{g,L_{ij}}&space;\sum_{i,&space;j}&space;\sum_{k}&space;w(I_{ij}^{k})[g(I_{ij}^{k})&space;-&space;log(L_{ij})&space;-&space;log(t^k))]^2&space;&plus;&space;\lambda&space;\sum_{z=0}^{255}&space;w(z)&space;(\nabla^2&space;g(z))^2" title="\min_{g,L_{ij}} \sum_{i, j} \sum_{k} w(I_{ij}^{k})[g(I_{ij}^{k}) - log(L_{ij}) - log(t^k))]^2 + \lambda \sum_{z=0}^{255} w(z) (\nabla^2 g(z))^2" />

  To achieve optimal `g` curve, I clipped image range to `Zmin` to `Zmax`. I found that adding one condition which is `g(Zmax - 1) = 1` to LS optimization problem results better `g` curve. If I use `g(Zmax) = 1` instead of  `g(Zmax - 1) = 1`, the `g` curve is suppressed to have lower value except `g(Zmax)`. Also, I set `g` values which x is smaller than `Zmin` to zero and the values which x is larger than `Zmax-1` to `g(Zmax-1)`. 

  I chose 1,000 for `lambda`, which strongly enforces the g curve to be smooth. **Figure 1, 2, 3** shows each `g` curve and `exp(g)` curve using `uniform, tent, gaussian` weight scheme for each color channels, respectively. Except linear weight scheme, `g` curve are monotonically increasing function which is considerably smooth. Linear weight scheme uses whole range of image pixels which makes sensitive to saturated values.

**Figure 1: Uniform**
![Alt text](/assignment4_result/results/Q1_Linearization/uniform.png)


**Figure 2: Tent**
![Alt text](/assignment4_result/results/Q1_Linearization/tent.png)


**Figure 3: Gaussian**
![Alt text](/assignment4_result/results/Q1_Linearization/gaussian.png)



#### Sub Q2. Merge exposure stack into HDR image (15 pts)
Merged exposure stacks have 12 types: 2 sets of images (RAW and rendered) x 2 merging schemes(linear and logarithmic) x 3 weighting schemes (uniform, tent, Gaussian). I post-processed using `MATLAB` **tonemap** function. In rendered images, some of cases show noisy results. I presume that the reason of noise value is due to clipping saturated value in `Sub Q1`. In my view, logarithmic merging scheme shows better results than linear merging scheme.

**Figure 4-(1): Raw, Linear, Uniform**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/uniform_raw_linear.jpg)




**Figure 4-(2): Raw, Linear, Tent**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/tent_raw_linear.jpg)




**Figure 4-(3): Raw, Linear, Gaussian**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/gaussian_raw_linear.jpg)




**Figure 4-(4): Raw, Logarithmic, Uniform**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/uniform_raw_logarithmic.jpg)




**Figure 4-(5): Raw, Logarithmic, Tent**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/tent_raw_logarithmic.jpg)




**Figure 4-(6): Raw, Logarithmic, Gaussian**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/gaussian_raw_logarithmic.jpg)




**Figure 4-(7): Rendered, Linear, Uniform**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/uniform_rendered_linear.jpg)




**Figure 4-(8): Rendered, Linear, Tent**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/tent_rendered_linear.jpg)




**Figure 4-(9): Rendered, Linear, Gaussian**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/gaussian_rendered_linear.jpg)




**Figure 4-(10): Rendered, Logarithmic, Uniform**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/uniform_rendered_logarithmic.jpg)




**Figure 4-(11): Rendered, Logarithmic, Tent**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/tent_rendered_logarithmic.jpg)




**Figure 4-(12): Rendered, Logarithmic, Gaussian**
![Alt text](/assignment4_result/results/Q2_HDR/tonemapped_matlab/gaussian_rendered_logarithmic.jpg)



#### Sub Q3. Evaluation (10 pts)
After merging exposure stacks to HDR images, I evaluated the quality of HDR merging scheme by measuring its linearity of luminance value. Utilizing patches 4, 8, 12, 16, 20 and 24 of color checkers, I got log luminance intensity of each patch. The results of linear regression are shown in **figure 5**. Every case shows meaningful R-squared value which indicates the error of regression result. Logarithmic merging scheme shows better results in both qualitative and quantitative evaluations.


**Figure 5: Linear regression results**
![Alt text](/assignment4_result/results/Q2_HDR/linear_regression.png)




### Q2. Tonemapping (50 pts)
#### Sub Q1. Photographic tonemapping (20 pts)
  Following given equation which is shown below, I got two photographic tonemapped images. First one is tonemapped channelwisely in RGB colorspace. Second one is tonemapped using only Y channel in xyY colorspace. In my view, photographic tonemapping using `RGB colorspace` is better than `xyY colorspace`. `xyY colorspace` tonemapping somehow changed white balance of the image which makes image unreal. Parameters are shown below.
```MATLAB
% Parameters for RGB tonemapping
K_p = 0.8;
B_p = 0.9;

% Parameters for xyY tonemapping
K_y = 0.2;
B_y = 0.9;
```
  
  
![Alt text](/assignment4_result/results/Q3_tonemap/formula.png)

**Figure 6: Tonemapped images**
![Alt text](/assignment4_result/results/Q3_tonemap/figure.png)


**Figure 7: Tonemapped images-RGB**
![Alt text](/assignment4_result/results/Q3_tonemap/photo_rgb.png)


**Figure 8: Tonemapped images-xyY**
![Alt text](/assignment4_result/results/Q3_tonemap/photo_xyY.png)



#### Sub Q2. Bilateral tonemapping (20 pts)
  Following given equation which is shown below, I got two photographic tonemapped images. First one is tonemapped channelwisely in `RGB colorspace`. Second one is tonemapped using only Y channel in `xyY colorspace`. Bilateral tonemapping in `RGB colorspace` show more smoothed result in color than photographical tonemapping. As it uses bilateral filter, the edge is encouraged which makes image more clear. `xyY colorspace` shows saturated result. In this method, I prefer `RGB colorspace` tonemapping result than `xyY colorspace` tonemapping result. Parameters are shown below.
  ``` MATLAB
% Parameters for RGB
S_rgb = 0.15;
sigma_spatial_rgb = 1;
sigma_intensity_rgb = 0.1;
kernel_size_rgb = 5;

% Parameters for xyY
S_xyY = 0.17;
sigma_spatial_xyY = 1;
sigma_intensity_xyY = 0.1;
kernel_size_xyY = 5;
```

**Figure 9: Tonemapped images**
![Alt text](/assignment4_result/results/Q3_tonemap/figure_bilateral.png)


**Figure 10: Tonemapped images-RGB**
![Alt text](/assignment4_result/results/Q3_tonemap/bilateral_rgb.png)


**Figure 11: Tonemapped images-RGB**
![Alt text](/assignment4_result/results/Q3_tonemap/bilateral_xyY.png)
