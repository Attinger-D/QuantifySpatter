% DescribeQuant.m describes the image quantitatively by running script DescribeQuant.m in Octave which outputs several
% quantitative measurements of the spatter patterns in the form of plots or enhanced images.
% The measurement of the stains is based on the Octave script regionprops from the image analysis package of Octave.
% Script DescribeQuant.m can be run after one or several '.png' spatter pattern pictures have been processed by ProcessImages.m.
% The name and location of the files to describe quantitatively are  provided in a dedicated file "Files2DescribeQuant.csv",
% located in the 'images' subfolder.

% User input: The name and location of the files to describe quantitatively are provided in a dedicated file "Files2DescribeQuant.csv",
% located in the 'images' subfolder.

% or with a text editor and specify: the 'filename' the name of the picture to describe quantitatively, and the folder where the image and data file are located
% (typically the "images" folder).
% Column 1: image_filename - images needs to be black and white thresholded images in .png format
% Column 2: path to the folder where images are stored (by default, it is the relative path to subfolder "images")


% % Outputs are saved in the folder containing the input image as enhanced images or images of plots:
% '*_identified.png', B/W picture of spatter pattern with ellipses fitted in red around stains. Fitting an ellipse around stains is one of the measurements performed.
% '*_identified_b.png', same as above, but with arrows showing directionality of drop impact by pointing towards the tail of the stain (our best guess, works obviously better for stains that exhibit a distinguishable tail)
% '*_Hist_size_numbers.png'% histogram of stain sizes, y-axis is number of stains per mm, and x-axis is size of stains in mm
% '*_Hist_size_percent.png'% histogram of stain sizes, y-axis is binned percentage of stains per mm, and x-axis is size of stains in mm
% '*_Density_map.png' % spatial map of number density of stains
% '*_Aspect_ratio_map.png'% spatial map of aspect ratios of stains. Aspect ratio is length over width of the fitted ellipse, and can be used to estimate the impact angle.

%%Copyright (c) 2023, Daniel Attinger
%%
%%All rights reserved.
%%Redistribution and use in source and binary forms, with or without
%%modification, are permitted provided that the following conditions are met:
%%
%%1. Redistributions of source code must retain the above copyright notice, this
%%   list of conditions and the following disclaimer.
%%
%%2. Redistributions in binary form must reproduce the above copyright notice,
%%   this list of conditions and the following disclaimer in the documentation
%%   and/or other materials provided with the distribution.
%%
%%3. Neither the name of the copyright holder nor the names of its
%%   contributors may be used to endorse or promote products derived from
%%   this software without specific prior written permission.
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

close all; clearvars; clc; % clear memory and screen, closes existing figures


% Development variables
relative_path ='images'; % if filename does not start with an absolute path, the code will asume that it is located in that folder of the folder the code is run
verbose=0; % % 0=no figure displayed until code ends; 1=figures displayed during run (this may use more memory and crash code if run on Cocalc)
max_number_stains=1e8; % maximum number of stains that will be measured by the code  (1e8 will likely process every stain, and smaller number are only useful for increasing speed in code testing)
ImageTooLargeToShow=3000; % size of image in pixels that will result in image being directly saved as imagefile and not shown on screen
Solidity_threshold=0.7; % discard spots that are not close to elliptic in shape (may not be stains). 0.7 to 0.8 is recommended. This is a setting of procedure regionprops.
Pixels_Noise=2; % discard stains that have width less than 2 pixels
dbstop if error; % helps find bugs if code crashes
% End Development variables

% Specify the relative path to the input CSV file
relative_path = 'images';  % Adjust as needed
csv_file_name = 'Files2DescribeQuant.csv';
csv_file_path = fullfile(pwd, relative_path, csv_file_name);

% housekeeping to minimize issues with a variety of display sizes and capabilities
display('housekeeping')
tic;
% user inputs
graphics_toolkit gnuplot;
display_crash_limit=16384; % maximum side length of image that Octave can display
figure_relative_size=0.5; % relative output size of figures with respect to maximum size that Octave can handle
% user inputs
screen_size = get(0, 'screensize'); %maximum side length of image that system can handle (computer, screen, Octave).
pkg load io; % load Octave package with additional scripts on input/output
pkg load signal; % load Octave package with additional scripts on signal processing
pkg load statistics;  % Load octave-statistics package

% hide figures to speed up processing
if verbose==0
  set (0, 'DefaultFigureVisible', 'off');
else
  set (0, 'DefaultFigureVisible', 'on');
end

% end housekeeping of display issues

% read input file
% Use csv2cell to read the CSV file
input_data = csv2cell(csv_file_path, 1);
% Set the number of processed images
number_images_to_process = size(input_data, 1) % will describe all files mentioned in CSV file
%number_images_to_process = 1 ; % will describe only first file mentioned in CSV file

for  i=1:number_images_to_process
 filename = input_data{i, 1};
 path = input_data{i, 2};

   % check if path is relative or absolute path
   if isAbsolutePath(path)
     image_full_filename = fullfile(path,filename) %Ex: ['C:\images\image.png']%determines the full image file name (with path)
     else
     image_full_filename = fullfile(pwd,path,filename) %Ex: ['C:\images\image.png']%determines the full image file name (with path)
   endif

  [filepath,name, ext] = fileparts(image_full_filename); %Breaks full filename in 3 parts, the path, the name without extension and the extension. Ex: ['C:\images', 'picture','.png'];

% construct names of various output files of code
stripped_filename = fullfile(filepath, name);  % reassemble file name without extension, Ex. 'C:\images\picture'

ext='.png'; % extension for images of plots produced by code
processed_image_filename=strcat(stripped_filename, "_", 'identified', ext);   % concatenate strings with "_", Ex. 'C:\images\picture_identified.png', picture with ellipses around stains)
processed_image_filename_b=strcat(stripped_filename, "_", 'identified_b', ext);   % name of another picture with ellipses around stains and arrows pointing towards tail of stains
histogram_numbers=strcat(stripped_filename, "_Hist_", 'size_numbers', ext);   % name of histogram of stain sizes, in numbers Ex. 'C:\images\picture_Hist_size_numbers.png'
histogram_percent=strcat(stripped_filename, "_Hist_", 'size_percent', ext);   % name of another histogram of stain sizes, in percentages, Ex. 'C:\images\picture_Hist_size_numbers.png'
density_map = strcat(stripped_filename, "_Density_map", ext);   % spatial map of number density of stains, Ex. 'C:\images\picture_Density_map.png'
%orientation_map = strcat(stripped_filename, "_Orientation_map", ext);   % spatial map of directionalities of stains, Ex. 'C:\images\picture_Orientation_map.png'
aspect_ratio_map = strcat(stripped_filename, "_Aspect_ratio_map", ext);   % spatial map of aspect ratios of stains, Ex. 'C:\images\picture_Aspect_ratio_map.png'

ext='.mat'; % extension for data
stain_data_filename=strcat(stripped_filename, "_", 'data', ext);   % Ex. 'C:\images\picture_data.mat' data file of stain segmentation and measure


ext='.txt';
txt_report = strcat(stripped_filename, "_report", ext);   % report with features of the quantitative description

input_file_full_paths = {
stain_data_filename
};

% load image data
load(stain_data_filename); % this will load the data as "stains"
display('image data loaded');
toc;
info = imfinfo(image_full_filename); % Replace with your image file name

% Extract the image size (in pixel)
photoWidth = info.Width;
photoHeight = info.Height; % height in pixels
size_image = max(photoWidth,photoHeight); % this is a single lenght in pixel that corresponds to the longest dimension of the picture
aspect_ratio_image=photoWidth/photoHeight; % aspect ratio of original image, wider than higher corresponds to aspect ratio larger than one


N_spots = size(stains,1) % number of spots observed on picture

display('discarding stains with small size close to picture resolution, and stains containing large empty areas');
RankStains; %rank stains according to criteria, from best candidates to worst candidates for ellipse fitting, and remove low solidity stains and stains smaller than Pixels_Noise
N_stains_kept = size(stains,1) % number of stains after above discard processed

% perform quantitative descriptions sequentially
%MapOrientation; %produce orientation map
%disp('done map orientation'); toc

MapAspectRatio;
disp('done map of aspect_ratios'); toc
MapDensity;disp('end map density'); toc

% plot histograms


if (exist('nickname', 'var') && ~isempty(nickname) && ~isa(nickname, 'double'))
  legend_labels=nickname;
else
    if isa(nickname, 'double')
    legend_labels = num2str(nickname);
  else
  % 'nickname' does not exist in the workspace
  legend_labels='stain data';
  end

end
[blurb]=HistogramSingle(input_file_full_paths,legend_labels, histogram_numbers, histogram_percent, verbose);
disp('end produce histograms'); toc

% superpose ellipses
disp('begin superpose ellipses to image'); toc
if size_image < ImageTooLargeToShow
  SuperposeEllipses;
else
  SuperposeEllipses_direct_write;
endif
disp('end superpose ellipses'); toc

write_text_report; %writes a text report that describes features of the quantitative description
endfor
disp('images of the plots, the stains with ellipses, as well as a text report describing the measurements are available in the folder of the images');





