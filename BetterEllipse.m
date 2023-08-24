% Script BetterEllipse calls a least-square fit of the ellipse to the contour points of the stain, and adds the results to the structure 'stains'.
% Fits ellipse that is less sensitive to tails than the algorithm in regionprops from Octave image package
% Process is based on fitellipse.m (see acknowledgement text file)
% Directionality in degree.
% INPUT: data structure 'stains' file is augmented with fields as mentioned at end of script:
% OUTPUT: data structure 'stains' with following additional fields
% Estimate of impact angle in degree: NewAlpha;
% Points of ellipse: Ellipse;
% Tangent vector (directionality) from regionprops: tangent;
% Tangent vector (directionality) after fitellipse: tangent2, to point towards the most likely tail of the stain (it is called directionality in BPA);
% Orientation of the tangent vector: NewOrientation, angle in degree between horizontal and direction to stain tail
% Note that origin (0,0) is top left, that is y axis pointing down

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

if verbose==1
  set (0, 'DefaultFigureVisible', 'on');
endif

phi = linspace(0,2*pi,120); % 120 points used to plot ellipse
cosphi = cos(phi);
sinphi = sin(phi);

for i=1:min(max_number_stains,number_stains)
  index_stain=i;

  img=stains(index_stain).FilledImage; % image of stain produced by regionprops


  %display('start fit ellipse')
  %toc;

  rotation_angle=pi-stains(index_stain).Orientation*pi/180; % Orientation is angle between horizontal line and main axis of stain, in trigonometric direction (positive=clockwise)
  centroid_global=[stains(index_stain).Centroid];
  BBox=[stains(index_stain).BoundingBox(1:2)];
  centroid_local=centroid_global-BBox;
  Major=stains(index_stain).MajorAxisLength; % values are in pixel
  Minor=stains(index_stain).MinorAxisLength;


  if Major<5 || Minor<3  % ellipse will be produced but fitted with Fitz method for small stains (values in pixels) because of uncertainty and crash of fitellipse for very small stains

    stains(index_stain).FitEllipse=0; % marker in the data file that indicates that ellipse has not been refitted after regionprops
    stains(index_stain).NewCentroidGlobal=centroid_global;
    stains(index_stain).NewMajor=Major;
    stains(index_stain).Newminor=Minor;

    xbar = stains(index_stain).Centroid(1);
    ybar = stains(index_stain).Centroid(2);

    a = stains(index_stain).MajorAxisLength/2;
    b = stains(index_stain).MinorAxisLength/2;

    theta = pi*stains(index_stain).Orientation/180;
    R = [ cos(theta)   sin(theta)
        -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    stains(index_stain).Ellipse=[x', y'];

  else


    bounds = bwboundaries (img); % segments boundaries of stain

    %   plot (bounds {1} (:, 2), bounds {1} (:, 1), 'r', 'linewidth', 2);%

    x=bounds {1} (:, 2);
    y=bounds {1} (:, 1);

    t=[ cos(rotation_angle) sin(rotation_angle) ]; % define tangent vector to main axis of stain


    % determination of sign of tangent vector, to point towards the most likely tail of the stain (it is called directionality in BPA)
    signed_distances=[(x-centroid_local(1))*t(1)+(y-centroid_local(2))*t(2)]; % define distance between centroid of stain and boundaries
    direction=-max(signed_distances)/min(signed_distances);

    % remove the contour points that are likely tail points from the ellipse fitting
    if direction >=1 % tail is on positive values of signed distance
      mask=signed_distances<=factor_tail*max(signed_distances)/direction;

    else %direction <=1 tail is on negative value of signed distances
      mask=signed_distances>=factor_tail*min(signed_distances)*direction;
      t=-t;
    end

    rho=cart2pol(t(1),t(2));

    %mask = remove points of the tail;
    x(~mask)=[];
    y(~mask)=[];



    % fit ellipse on stain point remaining after removal above
    a = fitellipse(x',y');
    phase_measured_deg=a(5)*180/pi;

    NewMajor=max(a(3), a(4));
    Newminor=min(a(3), a(4));
    NewCentroid=[a(1),a(2)];
    NewOrientation=a(5)-(a(3)<=a(4))*pi/2-pi; %in radian,

    % determination of orientation of main axis of stain
    delta=rho-NewOrientation;
    if cos(delta)<0
      NewOrientation=NewOrientation+pi;
    endif

    if NewOrientation>pi
      NewOrientation=NewOrientation-2*pi;
    endif

    if NewOrientation<-pi
      NewOrientation=NewOrientation+2*pi;
    endif

    NewOrientation=-NewOrientation; % so that angle is measured counterclockwise.
    %angle between horizotal and direction of stain tail, between pi and minus pi, positive is couterclockwise. This is the directionality of the stain.

    theta=[1:3:360]*pi/180;

    xfit=a(1)+a(3)*cos(theta)*cos(a(5))-a(4)*sin(theta)*sin(a(5)); %position, radius
    yfit=a(2)+a(3)*cos(theta)*sin(a(5))+a(4)*sin(theta)*cos(a(5)); %position, radius % the fifth parameter is the rotation angle (phase)

    if verbose==1 %plot arrow on stain and fitted ellipse (used for code testing)
      figure(20);
      clf;imshow(img);hold on;
      plot (x , y , 'oc', 'linewidth', 1);hold on;
      quiver(NewCentroid(1), NewCentroid(2), t(1)*30, t(2)*30, 'r', 'LineWidth', 2);hold on; % 30 pixels length for tangent vector

      figure(12);clf
      plot(x,y,'.r'); hold on; % contour in red
      plot(xfit, yfit,'+g') %fitted ellipse in green
      axis equal
      %pause
    endif

    %%% end fit ellipse on stain

    t2=[ cos(NewOrientation) sin(NewOrientation) ]; % tangent vector to main axis

    Orientation_Fitz=(NewOrientation)*180/pi; % these are the values from fitellipse (Fitz is one of the author of the method)
    %delta=psi_regionprops-psi_Fitz;

    alpha_regionprops=asin(Minor/Major)*180/pi;
    alpha_Fitz=asin(Newminor/NewMajor)*180/pi;
    CentroidGlobalFitz= NewCentroid+BBox;
    x_global=xfit'+BBox(1);
    y_global=yfit'+BBox(2);

    %update stain data
    stains(index_stain).FitEllipse=1;
    stains(index_stain).NewCentroidGlobal=CentroidGlobalFitz; % x, y coordinates of centroid, note that origin (0,0) is top left, that is y axis pointing down
    stains(index_stain).NewMajor=NewMajor;
    stains(index_stain).Newminor=Newminor;
    stains(index_stain).NewOrientation=Orientation_Fitz; % directionality in degree
    stains(index_stain).NewAlpha=alpha_Fitz;             % estimate of impact angle in degree
    stains(index_stain).Ellipse=[x_global y_global];     % coordinates of ellipse
    stains(index_stain).tangent=t;                       % tangent vector (directionality) from regionprops
    stains(index_stain).tangent2=t2;                     % tangent vector (directionality) after fitellipse, from centroid towards tail



    %name;
    %pause
    %toc
  endif
endfor






