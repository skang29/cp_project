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
  To get all-focus image, I weighted summed all focal stack. The weight used to merge all focal stack can be acquired using the fact that focused area has sharp image. Following the procedure written below, I could get all-focused image **Fig. 3**. Also, I used the parameters which are shown below for gaussian kernel.
```MATLAB
% params
sigma_1 = 10;
sigma_2 = 3;
```

![Alt text](/assignment5_result/results/Q4_all_focusing_depth/equation_1.png)


**Figure 3: All-focused images**


![Alt text](/assignment5_result/results/Q4_all_focusing_depth/all_focus.png)


 To get depth map, I weighted summed depth. The weight used to merge depth is same as the weight used to create all-focused image. **Fig. 4** shows the result of depth image.
 
 
 **Figure 4: Depth images**


![Alt text](/assignment5_result/results/Q4_all_focusing_depth/depth.png)
