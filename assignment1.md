## Assignment 1
### Question 1. Initials(5pts)

```matlab
% As the image is represented using Bayer Pattern,
% original image size is [im1, im2]
imSize = size(im1);
disp("Image information");
fprintf("Image size: %d x %d\n", imSize(1), imSize(2));
fprintf("Datatype: uint16\n");

% Convert image into double precision array
im1 = cast(im1, 'double');
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/skang29/cp_project/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
