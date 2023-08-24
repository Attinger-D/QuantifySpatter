clearvars;clear all;
% CompareHistograms.m is a script that prepares data to plot several histograms on top of each other.
% INPUT: provide the name of two or more '*.mat' data files in the file Histograms2Compare.csv located in the subfolder 'images'
% of the directory where the scripts are installed.

% OUTPUT: two images of histograms of the data, with names defined in variables 'histogram_percent', and 'histogram_numbers'
% The script sends INPUT data to nhist, the script for plotting nice histograms
% by Jonathan Lansey
% Note that the output of the command windows provides the following data that complements the plots, and will be saved in the '*_report.txt' file :
%%Script successfully plotted histograms
%%for the data that you provided at the beginning of this script: (list of filenames)
%%{
%%  [1,1] = Plot #1: mean=0.62, std=1.00, minimum=0.62, 5 points counted in the rightmost bin are greater th
%%an 4.58 ,
%%  [1,2] = Plot #2: mean=1.03, std=0.78, minimum=1.03, 15 points counted in the rightmost bin are greater t
%%han 4.58 }
%% The bar on top of the histogram shows the mean +/- standard deviation.
%%saved image of histogram of stain percentiles: Compared_Hist_percent.png ,
%%saved image of histogram of stain numbers:  Compared_Hist_numbers.png ,
%%Each histogram image file available in the same directory where your code is located, for download.

close all;clc

%%%%%%%%%%%%%%%%
%%% USER INPUT %%%
%%%%%%%%%%%%%%%%
verbose=0;


%%%%%%%%%%%%%%%%%%%%%%
%%% END USER INPUT %%%
%%%%%%%%%%%%%%%%%%%%%%

%developer inputs
relative_path ='images'; % if filename does not start with an absolute path, the code will asume that it is located in that folder of the directory the code is run
Solidity_threshold=0.8; % discard stains (black) that have at least 20 percent of white spots
Pixels_Noise=2; % discard stains that have width less than 2 pixels
% end developer inputs

%%graphics_toolkit gnuplot;
disp('Welcome! This Octave script plots several histograms on top of eachother');


%name various filenames to store the output of the image processing
ext='.png';
histogram_numbers=strcat("Compared_Hist_", 'numbers', ext)   % concatenate strings with "_"
histogram_percent=strcat("Compared_Hist_", 'percent', ext)   % concatenate strings with "_"

pkg load io; % load Octave package with additional scripts on input/output
pkg load signal; % load Octave package with additional scripts on signal processing
pkg load statistics;  % Load octave-statistics package

% Make sure paths of data files are full paths
relative_path ='images'; % if filename does not start with an absolute path, the code will asume that it is located in that folder of the directory the code is run


% read name of input files in .CSV file
csv_file_name = 'Histograms2Compare.csv';
csv_file_path = fullfile(pwd, relative_path, csv_file_name);

% read input file
% Use csv2cell to read the CSV file
input_data = csv2cell(csv_file_path, 1);
% Set the number of processed images
number_files = size(input_data, 1) % will describe all files mentioned in CSV file
%number_images_to_process = 1 ; % will describe only first file mentioned in CSV file

for  i=1:number_files
 filename = input_data{i, 1};
 path = input_data{i, 2};
 label = input_data{i, 3};

   % check if path is relative or absolute path
   if isAbsolutePath(path)
     image_full_filename = fullfile(path,filename) %Ex: ['C:\images\image.png']%determines the full image file name (with path)
     else
     image_full_filename = fullfile(pwd,path,filename) %Ex: ['C:\images\image.png']%determines the full image file name (with path)
   endif

input_files{i}=image_full_filename;
legend_labels{i}=label;
end


% determine names of input/output files
% Check if the user input contains a file separator character (e.g., '\' or '/')

for k=1 : length(input_files)
  filename=input_files{k};

  if ismember(filesep, filename)
    % If the input contains a file separator, assume it's an absolute path
    data_full_filename{k} = filename; % Use the absolute path directly
  else
    % If the input does not contain a file separator, assume it's a filename in the 'images' folder relative to the code's location
    %relative_path ='images'; % file is in 'images' folder of the directory where scripts are run
    data_full_filename{k} = fullfile(pwd, relative_path, filename); % Construct the full image file name
  end
endfor


% process the image
%ProcessImage(image_filename,scale,processed_image_filename, stain_data_filename);
[blurb]=HistogramPrepMultiple(data_full_filename,legend_labels, histogram_numbers, histogram_percent, verbose, Solidity_threshold, Pixels_Noise);


% tell user about files that have been saved
file_names_string = strjoin(data_full_filename, ';');
message_processing1=sprintf('%s %s %s','Script successfully plotted histograms')  ; % concatenate strings
message_processing2=sprintf('%s %s %s','for the data that you provided at the beginning of this script:', file_names_string,'.')  ; % concatenate strings
message_histogram_percent=sprintf('%s %s %s','saved image of histogram of stain percentiles:', histogram_percent ,',')  ; % concatenate strings
message_histogram_numbers=sprintf('%s %s %s','saved image of histogram of stain numbers: ',histogram_numbers,',') ;  % concatenate strings



disp(' ');
disp(message_processing1);
disp(message_processing2);
disp(blurb);
disp(message_histogram_percent);
disp(message_histogram_numbers);
disp('Each histogram image file available in the same directory where your code is located, for download and any use.')
disp('Best.')


