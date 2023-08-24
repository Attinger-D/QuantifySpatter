% Script SuperposeEllipses2 enhances thresholded black and white pictures of stains with the boundaries of fitted ellipses and their directionality.
% INPUT: image_full_filename, a ".png' image, black and white, thresholded and processed with ProcessImages.m
% OUTPUT: processed_image_filename, a '.png' figure with red fitted ellipses superposed to the original stains
% Script adds to figure a scale bar on the top left with length of 10mm.
% Figure is saved as '.png' files rather than displayed to accommodate pictures with sizes that would crash Octave's display routines on some computing environments.

%%Copyright (c) 2023, Daniel Attinger
%%
%%All rights reserved.
%%Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
%%* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
%%* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution
%%
%%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
%%BELIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%%POSSIBILITY OF SUCH DAMAGE.

input_img_bin=TestConvertImage(image_full_filename); % produces binary_img from file in image_file
dbstop if error; % helps find bugs if code crashes


%%  axis image;  % Ensures the aspect ratio is maintained


% Convert binary image to numeric format
binary_image = double(input_img_bin);

% Create a new color image
color_image = zeros(size(input_img_bin, 1), size(input_img_bin, 2), 3);

% Create a new color image with initial black and white colors
color_image(:,:,1) = input_img_bin;   % Set red channel to binary values (black)
color_image(:,:,2) = input_img_bin;   % Set green channel to binary values (black)
color_image(:,:,3) = input_img_bin;   % Set blue channel to binary values (white)


x_points=[];
y_points=[];

for i=1:size(stains,1)

  x_points = vertcat(x_points,stains(i).Ellipse(:,1));
  y_points = vertcat(y_points, stains(i).Ellipse(:,2));

  if stains(i).FitEllipse==1
        hold on;
        NewCentroid=stains(i).NewCentroidGlobal;
        t=stains(i).tangent;
        length_arrow=stains(i).NewMajor/2;
  endif
endfor


x = round(x_points);
y = round(y_points);



% remove points that are outside of figure (happens for stains near edges)

info = imfinfo(image_full_filename); % Replace with your image file name

% Extract the window boundaries
xmin = 1;
xmax = photoWidth;
ymin = 1;
ymax = photoHeight;

% Perform logical indexing to keep points inside the window
indices = (x >= xmin) & (x <= xmax) & (y >= ymin) & (y <= ymax);
points = [x, y];
filtered_points = points(indices, :);
x = filtered_points(:, 1);
y = filtered_points(:, 2);

% Initialize the red channel of the color_image to 0
color_image(:, :, 1) = 0;

% Set the red channel to 1 for the dots using sub2ind
linear_inds = sub2ind(size(color_image), y, x);
color_image(linear_inds) = 1;

% Add a scale bar to the image
% Set the pixel/mm conversion rate
pixels_per_mm = scale/10;

% Calculate the length and height of the scale bar in pixels
scale_length_mm = 10;
scale_length_pixels = round(scale_length_mm * pixels_per_mm);
scale_height_pixels = round(scale_length_pixels / 10);

% Determine the position of the scale bar
scale_position = [10, 10];

% Design the rectangular scale bar
x_scale = repmat(scale_position(1):scale_position(1)+scale_length_pixels-1, scale_height_pixels, 1);
y_scale = repmat(scale_position(2):scale_position(2)+scale_height_pixels-1, scale_length_pixels, 1)';
y_scale = y_scale(:);

% Draw the scale bar as a rectangle
for i = 1:numel(x_scale)
    color_image(y_scale(i), x_scale(i), :) = [1, 0, 0];  % Set red channel to 1 for the rectangle
endfor



toc;
disp('start saving image of stains with superposed ellipses');
% Save the color image
imwrite(color_image, processed_image_filename);%220s

toc;
