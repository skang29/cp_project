## You can find whole code from here

https://github.com/skang29/cp_project/tree/master/assignment5_result

I didn not add whole code to this report because of limited space.

## Assignment 5
### Q1. Light field rendering, focal stacks, and depth from defocus (100 pts)
#### Sub Q1. Initials (5 pts), Sub Q2. Sub-aperture views (20 pts)

  The goal of this work is to preprocess a image which is acquired using plenoptic camera to 5D light field matrix L(u, v, s, t, c). After re-ordering pixels to L(u, v, s, t, c), I could get each pinhole image(sub-aperture view image) which can be expressed by L(u=u0, v=v0, s, t, c). **Fig. 1** shows each pinhole images in 16 by 16 grid view. The image is resized with resize ratio 0.4 due to size limit of github.
  
**Figure 1: Sub-aperture view**
![Alt text](/assignment4_result/results/Q2_sub_aperture_views/result.png)


#### Sub Q3. Refocusing and focal-stack generation (40 pts)
  To get a focused image using L(u, v, s, t, c), I used equation shown below. The equation shows that summing shifted light field matrix along (s, t) axes can generate a focused image.
![Alt text](/assignment4_result/results/Q3_refocusing/equation_1.png)

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


**Figure 11: Tonemapped images-xyY**
![Alt text](/assignment4_result/results/Q3_tonemap/bilateral_xyY.png)
