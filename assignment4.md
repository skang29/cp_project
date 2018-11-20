## You can find whole code from here

https://github.com/skang29/cp_project/tree/master/assignment4_result

I didn not add whole code to this report because of limited space.


## Assignment 4
### Q1. HDR Imaging (50 pts)
#### Sub Q1. Linearize rendered images (25 pts)

  The goal of this work is to linearize rendered image which is non-linear. Before merging images to HDR image, it is necessary to linearize rendered image. To achieve inverse function which linearize non-linear image, I made least squares optimization problem.

<img src="https://latex.codecogs.com/gif.latex?\min_{g,L_{ij}}&space;\sum_{i,&space;j}&space;\sum_{k}&space;w(I_{ij}^{k})[g(I_{ij}^{k})&space;-&space;log(L_{ij})&space;-&space;log(t^k))]^2&space;&plus;&space;\lambda&space;\sum_{z=0}^{255}&space;w(z)&space;(\nabla^2&space;g(z))^2" title="\min_{g,L_{ij}} \sum_{i, j} \sum_{k} w(I_{ij}^{k})[g(I_{ij}^{k}) - log(L_{ij}) - log(t^k))]^2 + \lambda \sum_{z=0}^{255} w(z) (\nabla^2 g(z))^2" />

  To achieve optimal `g` curve, I clipped image range to `Zmin` to `Zmax`. I found that adding one condition which is `g(Zmax - 1) = 1` to LS optimization problem results better `g` curve. If I use `g(Zmax) = 1` instead of  `g(Zmax - 1) = 1`, the `g` curve is suppressed to have lower value except `g(Zmax)`. Also, I set `g` values which x is smaller than `Zmin` to zero and the values which x is larger than `Zmax-1` to `g(Zmax-1)`. 

  I chose 1,000 for `lambda`, which strongly enforces the g curve to be smooth. `Figure 1, 2, 3` shows each `g` curve and `exp(g)` curve using `uniform, tent, gaussian` weight scheme for each color channels, respectively. Except linear weight scheme, `g` curve are monotonically increasing function which is considerably smooth. Linear weight scheme uses whole range of image pixels which makes sensitive to saturated values.

**Figure 1**

![Alt text](/assignment4_result/results/Q1_Linearization/uniform.png)
![Alt text](/assignment4_result/results/Q1_Linearization/tent.png)
![Alt text](/assignment4_result/results/Q1_Linearization/gaussian.png)

