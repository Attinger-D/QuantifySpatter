% Script SuperposeEllipses2 enhances thresholded black and white pictures of stains with the boundaries of fitted ellipses and their directionality.
% INPUT: image_full_filename, a ".png' image, black and white, thresholded and processed with ProcessImages.m
% OUTPUT: processed_image_filename, a '.png' figure with red fitted ellipses superposed to the original stains
%and
% processed_image_filename_b, a '.png' figure with red fitted ellipses superposed to the original stains,
% with arrows pointing to the most likely vertex of the ellipse corresponding to the tail.
% Script adds to both figures a 10mm scale bar on the top left.
% Output figures are saved as '.png' files rather than displayed to accommodate pictures with sizes that would crash Octave's display routines on some computing environments.

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

if verbose==0
  set (0, 'DefaultFigureVisible', 'off');
else
  set (0, 'DefaultFigureVisible', 'on');
end

%


input_img_bin=TestConvertImage(image_full_filename); % produces binary_img from file in image_file





  % Generate some array of points - this will be used to plot ellipses
  x_points=[];
  y_points=[];
%
stains=stains;

%%
    for i=1:size(stains,1)

      x_points = vertcat(x_points,stains(i).Ellipse(:,1)); % all ellipses
      y_points = vertcat(y_points,stains(i).Ellipse(:,2));

      if stains(i).FitEllipse==1 % this are the stains which have been fitted with Fitz algorith, which provides more accurate ellipses for stains with tails
        hold on;
        NewCentroid=stains(i).NewCentroidGlobal;
        t=stains(i).tangent;
        length_arrow=stains(i).NewMajor/2;
  endif

  end




% Extract the window boundaries
xmin = 1;
xmax = photoWidth;
ymin = 1;
ymax = photoHeight;

% Perform logical indexing to remove ellipse points outside of the original picture (so that script does not attempt to plot points of ellipses outside of picture area)
indices = (x_points >= xmin) & (x_points <= xmax) & (y_points >= ymin) & (y_points <= ymax);
points=[x_points,y_points];
filtered_points = points(indices, :);
x_points=filtered_points(:,1);
y_points=filtered_points(:,2);



 figure();
 fig=gcf;

  %% Set the figure size to match the image size in pixels
  set(fig, 'Units', 'pixels');
size_image=max(photoWidth,photoHeight);


  if size_image > display_crash_limit % resize large images

    if aspect_ratio_image<1 % height is limiting

      fig_height = round(figure_relative_size*display_crash_limit);
      fig_width = round(fig_height*aspect_ratio_image);

    else % aspect ratio larger or equal to one, width is limiting
      fig_width = round(figure_relative_size*display_crash_limit);
      fig_height = round(fig_width/aspect_ratio_image);
    end
  else     % do nothing
    fig_width  = photoWidth;
    fig_height = photoHeight;

  end

  set(fig, 'Position', [round(screen_size(3)/10), round(screen_size(4)/10), fig_width, fig_height]);

  display('start plotting ellipses');toc


  % Create a figure and set its size to match the image resolution
fig = figure;
set(fig, 'Units', 'pixels', 'Position', [0, 0, photoWidth, photoHeight]);


imshow(input_img_bin);hold on;


% plot scale
pixels_per_mm = scale/10;

% Calculate the length of the scale bar in pixels
scale_length_mm = 10;
scale_length_pixels = scale_length_mm * pixels_per_mm;

% Set the position of the scale bar
scale_position = [10, 10];

% Draw the scale bar as a rectangle
rectangle_height=50;
rectangle('Position', [scale_position, scale_length_pixels, rectangle_height], 'FaceColor', 'white');

% Add a text label to indicate the length of the scale bar
%text(scale_position(1) + scale_length_pixels/2, scale_position(2) + 10, sprintf('%d mm', scale_length_mm), 'HorizontalAlignment', 'center');
text(scale_position(1) + scale_length_pixels/2, scale_position(2)+rectangle_height/2, sprintf('%d mm', scale_length_mm), 'HorizontalAlignment', 'center');
% end plot scale
hold on;




  axis image;  % Ensures the aspect ratio is maintained

  hold on;  % Enable the "hold on" mode to overlay the points on the image
  plot(x_points, y_points, 'r.', 'MarkerSize', .3);

  hold off;

if verbose==1
  set(gcf, 'visible', 'on');
end
  display('stop plotting ellipses');toc


  display('start saving identified stain image');
  toc

  % Save the figure as a PNG file
  print(fig, processed_image_filename, '-dpng', '-r0'); % note:the warning message DEBUG: FC_WEIGHT didn't match is associated with lack of available fonts for printing. This minor issue does not affect the integrity of the results.

  % produces a second image with arrows superposed to stains, indicating directionality
  for i=1:size(stains,1)
    if stains(i).FitEllipse==1
        hold on;
        NewCentroid=stains(i).NewCentroidGlobal;
        t=stains(i).tangent;
        length_arrow=stains(i).NewMajor/2;
        quiver(NewCentroid(1), NewCentroid(2), t(1)*length_arrow, t(2)*length_arrow, 'r', 'LineWidth', 2);hold on;
        endif

end

display('start saving identified stain image with arrows');toc
  % Save the figure as a PNG file
  print(fig, processed_image_filename_b, '-dpng', '-r0');
