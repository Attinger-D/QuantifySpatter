% This script prepares the data for histogram plots,
% Script HistogramSingle
% calls the histogram plotting script and
% saves the histogram plots as images.
% Note that the histograms are based on the width of the stains
% INPUTS: fullFileName: cell array of "*_data.mat" files of strctures with stain measurements of spatter pattern
%          Legend_label: cell array of legend labels to be displayed in histograms
%          histogram_numbers, histogram_percent: name of histograms
%          verbose:  0=no figure displayed until code ends; 1=figures displayed during run (this may use more memory and crash code)
%          Solidity_threshold:  discard stains (black) that have given percentage of white spots
%          Pixels_Noise: discard stains that have width less than Pixels_Noise in pixels



function [theText]=HistogramSingle(fullFileName,Legend_label, histogram_numbers, histogram_percent, verbose)


close all;
debug_on_error(0);




% Define the number of figures to create
num_figs = 2;
Line_Width=1;
Size_Font=12;

% Create an array to store the figure handles
figs = zeros(num_figs,1);


tic;
%

%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1 : length(fullFileName)

  FileName = fullFileName{k};
  load (FileName);

%%  N_spots = size(stains,1) % number of spots observed on picture
%%
%%  display('discarding stains withe small size close to picture resolution, and stains containing large empty areas');
%%  RankStains; %rank stains according to criteria, from best candidates to worst candidates for ellipse fitting, and remove low solidity stains and stains smaller than Pixels_Noise
%%  N_stains_kept = size(stains,1) % number of stains after discard processed


   % determine names of various output files
  %[filepath,name, ext] = fileparts(FileName);

  % build the data that will be used in the histograms
  WidthData = [stains.MinorAxisLength]'/scale*10; % width of stains, in mm
  LengthData = [stains.MajorAxisLength]'/scale*10; % length of stains, in mm
  diaData = WidthData; % Equivalent Diameter of each stain is taken as the stain width, in mm


  D_data{k}=diaData; % Equivalent Diameter of each stain , in mm

  toc;


  N_stains=length(diaData)
  toc;

  display=[N_stains/1000];
end


figs(1) = figure('Visible','off');
[theText,rawN, x] =nhist(D_data,'color','copper','samebins')
set(gca, "linewidth", Line_Width, "fontsize", Size_Font);
hold on;
current_limits = xlim();  % Retrieve the current x-axis limits
xlim([0, current_limits(2)]);  % Set the minimum x-limit to 0 and keep the maximum x-limit unchanged
legend(Legend_label, 'location', 'east');
xlabel 'stain width (mm)';
ylabel 'probability density, mm^{-1}';

print(histogram_percent);


%figure(2); clf;
figs(2) = figure('Visible','off');
[theText,rawN, x] =nhist(D_data,'color','copper','samebins','numbers')
set(gca, "linewidth", Line_Width, "fontsize", Size_Font);
current_limits = xlim();  % Retrieve the current x-axis limits
xlim([0, current_limits(2)]);  % Set the minimum x-limit to 0 and keep the maximum x-limit unchanged
hold on;
legend(Legend_label,  'location', 'east' );
xlabel 'stain width (mm)';
ylabel 'number of stains';

print(histogram_numbers);

%%spots_description = sprintf('The number of spots processed is %d.', N_spots);
%%stains_description = sprintf('The number of stains analyzed is %d. ', N_stains_kept);
%%stains_description2=sprintf(' This number is smaller than the number of spots because spots with width less than %d pixels are discarded', Pixels_Noise);
%%stains_description3=sprintf(', and stains with significant empty inside areas (solidity smaller than %d) are also discarded.', Solidity_threshold);





% Show all the figures if verbose equals 1

if verbose
  % Show all the figures only if verbose is equal to one
  for i = 1:num_figs
    set(figs(i),'Visible','on');
    figure(i);
  end
end


