% Script ProcessImages.m measures stains on one or several picture of spatter patterns.
% INPUT: % List the images to process in the CSV file 'Files2Process.csv' located in the subfolder 'images'.
% the CSV file has has one header line and the following columns in order:
%%Script ProcessImages.m measures stains on one or several pictures of spatter patterns.
%%INPUT: List the images to process in the CSV file located in the subfolder 'images'. This CSV file can be edited with excel or with a text editor.
% The CSV file has one header line and the following columns in order:
%%Column A: filename  - images needs to be black and white thresholded images in ".png" format. Ex: "image1.png"
%%Column B: scale, in pixel per mm. Ex: 231.
%%Column C: nickname (optional), useful as legends in some output plots
%%Column D: Path to the folder where code is run (Typically, the images are placed in the subfolder "images", but the path can be relative or absolute)
%%Columns E-F: Notes and Source, optional and for user reference only.
%%OUTPUT: a file '*_data.mat' with measurements such as location of stain, width of the ellipse, height of the ellipse, location of the centroid of the stain.
%%File '*_data.mat' file is saved in the same folder as the '*.png' image.
% Once ProcessImages has run, the script DescribeQuant.m which outputs several quantitative measurements of the spatter patterns
% in the form of plots or enhanced images.
% The measurement of the stains is based on the Octave script regionprops from the image analysis package of Octave.



% clear memory and screen, closes existing figures
clearvars; clear all; clc; close all;


% Specify the relative path to the input CSV file
relative_path = 'images';  % Adjust as needed
csv_file_name = 'Files2Process.csv';
input_filename = fullfile(pwd, relative_path, csv_file_name);


% Development variables
%relative_path ='images'; % if filename does not start with an absolute path, the code will asume that it is located in that folder of the folder the code is run
factor_tail=0.8; % fraction (1=100%) of the stain contour points that are used to fit ellipse in BetterEllipse. Code tested with 0.8 and also works with 0.5.
max_number_stains=1e8;% maximum number of stains that will be measured by the code  (1e8 will likely process every stain, and smaller number are only useful for increasing speed in code testing)
dbstop if error; % helps find bugs if code crashes
verbose=0; % 0=no figure displayed until code ends; 1=figures displayed during run (this may use more memory and crash code if run on Cocalc)
% End Development variables

% load specific packages of scripts to Octave
pkg load image; % image processing scripts
pkg load io;    % input/output scripts

if verbose == 0
  set (0, 'DefaultFigureVisible', 'off'); % does not display figures
endif


tic; % start time counter

% Read the input CSV file
input_data = csv2cell(input_filename, 1); % The '1' skips the first row, which is a header row

% Get the number of processed images
number_images_to_process = size(input_data, 1)


for  i=1:number_images_to_process

  scale = (input_data{i, 2}); % get the scale, in pixel per mm
  nickname = ''; % Default value for nickname (if it's not present in the CSV)

  % Check if the nickname is provided (if your CSV has the nickname column)
  if size(input_data, 2) >= 2
    nickname = input_data{i, 3};
  end

  filename = input_data{i, 1};
  path = input_data{i, 4};

   % check if path is relative or absolute path
   if isAbsolutePath(path)
     image_full_filename = fullfile(path,filename) %Ex: ['C:\images\image.png']%determines the full image file name (with path)
     else
     image_full_filename = fullfile(pwd,path,filename) %Ex: ['C:\images\image.png']%determines the full image file name (with path)
   endif

  [filepath,name, ext] = fileparts(image_full_filename); %Breaks full filename in 3 parts, the path, the name without extension and the extension. Ex: ['C:\images', 'picture','.png'];

  % construct names of various output files of code
  stripped_filename = fullfile(filepath, name);  % reassemble file name without extension, Ex. 'C:\images\picture'

  ext='.png'; % extension for pictures produced by code
  processed_image_filename=strcat(stripped_filename, "_", 'identified', ext);   % concatenate strings with "_", Ex. 'C:\images\picture_identified.png', picture with ellipses around stains)
  processed_image_filename_b=strcat(stripped_filename, "_", 'identified_b', ext);   %  another picture with ellipses around stains
  histogram_numbers=strcat(stripped_filename, "_Hist_", 'size_numbers', ext);   % histogram of stain sizes, Ex. 'C:\images\picture_Hist_size_numbers.png'
  histogram_percent=strcat(stripped_filename, "_Hist_", 'size_percent', ext);   % another histogram of stain sizes, Ex. 'C:\images\picture_Hist_size_numbers.png'
  density_map = strcat(stripped_filename, "_Density_map", ext);   % spatial map of number density of stains, Ex. 'C:\images\picture_Density_map.png'
  %orientation_map = strcat(stripped_filename, "_Orientation_map", ext);   % spatial map of directionalities of stains, Ex. 'C:\images\picture_Orientation_map.png'

  ext='.mat'; % extension for data
  stain_data_filename=strcat(stripped_filename, "_", 'data', ext);   % Ex. 'C:\images\picture_data.mat', data file of stain segmentation and measure



  % processes data
  missing_file=0; % assume that image file is present
  try
    input_img_bin=TestConvertImage(image_full_filename); % opens image, tests that image is binary (in some cases, make the image binary), return binary image
  catch exception
    % Catch the error thrown by the function and handle it here
    warning('image file not found or image not in binary format');
    missing_file=1;
  end
  if missing_file ~=1 % if file is present, it will be processed
    % process the image
    display('start segmentation of stains');
    toc % mark time
    stains=SegmentImage(input_img_bin); % measures stains with regionprops and returns stains, a numeric structure with stain information
    display('end segmentation of stains');
    toc; %mark time
    number_stains=size(stains,1) % number of stains segmented and measured

    display('start ellipse refitting'); toc
    BetterEllipse; % refit ellipses with algorithm that is less sensitive to stains with tails
    display('end ellipse refitting');toc;

    source_image_full_filename=image_full_filename;
    source_stain_data_filename=stain_data_filename

    %saving data '.mat' file in  the original folder of the picture that was processed
    save -mat7-binary 'a.mat' 'stains' 'source_image_full_filename' 'scale' 'source_stain_data_filename' 'nickname';
    old_filename = "a.mat";    % old filename
    new_filename = stain_data_filename;    % new filename

    if exist(old_filename, 'file')   % check if the old file exists
      movefile(old_filename, new_filename, 'f');   % rename and overwrite the old file
      % the data file is placed in the original folder of the picture that was processed
    else
      rename ('a.mat',stain_data_filename);
    end
    % end saving data
  endif
  endfor
