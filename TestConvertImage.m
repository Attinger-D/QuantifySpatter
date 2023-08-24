% Function TestConvertImage checks that image is compatible with code in terms of format and size
% INPUT: image_full_filename, path and filename of a thresholded black and white '*.png' image
% OUTPUT: 'binary_img', a binary format thresholded black and white '*.png' image



function binary_img=TestConvertImage(image_full_filename)

%development variables to accommodate small and large displays
%display_crash_limit=16384; % maximum dimension of image that Octave can display
display_crash_limit=40000; % maximum dimension of image that will run without crashing
figure_relative_size=0.5; % relative output size of figures
% end development variables

screen_size = get(0, 'screensize'); %maximum side length of image that system can handle (computer, screen, Octave).

% if the image file does not exist, abort the computation
if ~exist(image_full_filename, 'file')
    warning(['File not found: ' image_full_filename]);
    binary_img=0;
    error('File not found. Stop the script by pressing CTRL + C.');
end

%gather size info on image
info=imfinfo(image_full_filename);
size_image = max(info.Width,info.Height); % this is the maximum size
aspect_ratio_image=info.Width/info.Height; % aspect ratio of original image, wider than higher corresponds to aspect ratio > 1
img_input=imreadort(image_full_filename); % read image, and tries to orient if with respect to metadata if available (license provided)

if size_image > display_crash_limit
  disp('image too large for being displayed as is.');
  warning('code will not run');
stop

else
  resize_factor=NaN;
  img=img_input;
end


% check if image has been thresholded, otherwise stop code
if strcmp(info.ColorType,"truecolor")% if image is fake 3 color but already thresholded
warning('code requires thresholded images. Please save as 8 bit and threshold in B/W before running code');
stop

elseif (strcmp(info.ColorType,"grayscale") || strcmp(info.ColorType,"indexed")) % enforce binary image rather than 8-bit
  if info.BitDepth==1
    binary_img=~img;
  elseif info.BitDepth>1
    binary_img=im2bw(img, 0.5);
  end

else
  warning('imagetype not recognized')
  stop
end
  display('end image check');toc;
