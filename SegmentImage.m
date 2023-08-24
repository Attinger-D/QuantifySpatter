% this function segments the stains from a binary image
% INPUT: binary_img, a 1-bit image where stains are thresholded (in black=1) on a white background (white=0)
% OUTPUT: the measurements 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Centroid','BoundingBox','Solidity', 'FilledImage','EquivDiameter'
% by RegionProps in structure 'staindata'.
% Documentation on the measurements is in the Octave script 'regionprops'.

function staindata=SegmentImage(binary_img)

more off; %turn off paging for output
set (0, 'DefaultFigureVisible', 'off'); % does not display figures

% enforce that stains are represented in black and backround in white
if mean(mean(binary_img))>0.5
  binary_img=~binary_img; % invert image color
endif

%

% compute properties of segmented regions in binary image, and store these properties in a structure
staindata = regionprops(binary_img, 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Centroid','BoundingBox','Solidity', 'FilledImage','EquivDiameter');
% unless specified, these values are in pixels


% Sort the structure by 'size of stain', from large to small stains
[~, idx] = sort([staindata.EquivDiameter], 'descend');
staindata = staindata(idx);











