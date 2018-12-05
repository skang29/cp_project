## You can find whole code from here

https://github.com/skang29/cp_project/tree/master/assignment5_result

I didn not add whole code to this report because of limited space.

## Assignment 5
### Q1. Light field rendering, focal stacks, and depth from defocus (100 pts)
#### Sub Q1. Initials (5 pts), Sub Q2. Sub-aperture views (20 pts)

  The goal of this work is to preprocess a image which is acquired using plenoptic camera to 5D light field matrix L(u, v, s, t, c). After re-ordering pixels to L(u, v, s, t, c), I could get each pinhole image(sub-aperture view image) which can be expressed by L(u=u0, v=v0, s, t, c). **Fig. 1** shows each pinhole images in 16 by 16 grid view. The image is resized with resize ratio 0.4 due to size limit of github.
  
  
  
**Figure 1: Sub-aperture view**


![Alt text](/assignment5_result/results/Q2_sub_aperture_views/result.png)


#### Sub Q3. Refocusing and focal-stack generation (40 pts)
  To get a focused image using L(u, v, s, t, c), I used equation shown below. The equation shows that summing shifted light field matrix along (s, t) axes can generate a focused image.
![Alt text](/assignment5_result/results/Q3_refocusing/equation_1.png)

  **Fig. 2** shows several focused images.
  
  
  
**Figure 2: Focused images**


![Alt text](/assignment5_result/results/Q3_refocusing/06_d(-4).png)
![Alt text](/assignment5_result/results/Q3_refocusing/10_d(0).png)
![Alt text](/assignment5_result/results/Q3_refocusing/14_d(4).png)
![Alt text](/assignment5_result/results/Q3_refocusing/18_d(8).png)
![Alt text](/assignment5_result/results/Q3_refocusing/22_d(12).png)
![Alt text](/assignment5_result/results/Q3_refocusing/26_d(16).png)
![Alt text](/assignment5_result/results/Q3_refocusing/30_d(20).png)
![Alt text](/assignment5_result/results/Q3_refocusing/34_d(24).png)


#### Sub Q4. All-focus image and depth from defocus (35 pts)
  To get all-focus image, I weighted summed all focal stack. The weight used to merge all focal stack can be acquired using the fact that focused area has sharp image. Following the procedure written below, I could get all-focused image. Also, I used the parameters which are shown below for gaussian kernel.
```MATLAB
% params
sigma_1 = 10;
sigma_2 = 3;
```

![Alt text](/assignment5_result/results/Q4_all_focusing_depth/equation_1.png)


  
  
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
