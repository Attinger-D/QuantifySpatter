% Script MapAspectRatio plots the spatial distribution of aspect ratio AR=length/width of the stains.
% The aspect ratio is related to the angle of impact by the relation sin(1/AR)=impact_angle (angle in radian).
% Drops that impact normally have aspect ratio close to one, drops that impact in slanted manner have larger aspect ratio.
% INPUT is the '*.mat' file with quantitative stain measurements.
% OUTPUT is a '*.png' picture aspect_ratio_map of aspect ratio map.

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

% developer settings
numBinsX = 12; % number of bins in plot
% developer settings

% hide figures to speed up processing
if verbose==0
  set (0, 'DefaultFigureVisible', 'off');
else
  set (0, 'DefaultFigureVisible', 'on');
end

%set(0, 'DefaultFigureVisible', 'on');
Line_Width = 1;
Size_Font = 16;

x = zeros(size(stains));
y = zeros(size(stains));
aspect_ratio = zeros(size(stains));

for i = 1:size(stains,1)
  x(i) = stains(i).Centroid(1) / scale; % in cm
  y(i) = (photoHeight - stains(i).Centroid(2)) / scale; % this ensures that y-axis runs from bottom to top
  aspect_ratio(i) =  stains(i).MajorAxisLength/stains(i).MinorAxisLength;
end


numBinsY = round(numBinsX * photoHeight / photoWidth);

% Extract the image size (in cm)
photoWidth_cm = photoWidth / scale;
photoHeight_cm = photoHeight / scale;

xmin = 0;
xmax = photoWidth_cm;
ymin = 0;
ymax = photoHeight_cm;

% Compute the bin edges based on the desired range
xEdges = linspace(xmin, xmax, numBinsX + 1);
yEdges = linspace(ymin, ymax, numBinsY + 1);

CC = [x, y, aspect_ratio];

% Compute the 2D histogram
[counts, centers] = hist3([x, y], 'Edges', {xEdges, yEdges});

% Compute the average aspect_ratio within each bin
bin_avg_aspect_ratio = zeros(numBinsY, numBinsX);
for i = 1:numBinsY
    for j = 1:numBinsX
        bin_indices = find(CC(:, 1) >= xEdges(j) & CC(:, 1) < xEdges(j + 1) & CC(:, 2) >= yEdges(i) & CC(:, 2) < yEdges(i + 1));
        bin_avg_aspect_ratio(i, j) = mean(CC(bin_indices, 3));
    end
end

% Create a heatmap-like visualization of the average aspect_ratio
figure;
imagesc(centers{1}, centers{2}, bin_avg_aspect_ratio);
colormap('hot');

title('Mean aspect ratio');
xlabel('X, cm');
ylabel('Y, cm');

% Adjust the font size of the axes labels and tick labels
set(gca, 'FontSize', 14);

% Manually set the axis limits to match the desired range
xlim([xmin, xmax]);
ylim([ymin, ymax]);

pos = get(gca, 'Position');
scale_plot = 0.8;
pos(2) = pos(2) + 0.1;
pos(4) = (1 - pos(2)) * scale_plot;
pos(1) = pos(1) + 0.1;
pos(3) = (1 - pos(1)) * scale_plot;
set(gca, 'Position', pos)

colorbarHandle = colorbar;
set(colorbarHandle, 'FontSize', 14);
colorbar;

% Use normal y-axis direction
set(gca, 'YDir', 'normal');

print(aspect_ratio_map);
