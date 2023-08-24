% Scripts writes and saves a text report '*.report.txt' describing the outputs of the quantitative description of the stains in image '*.png'
% The report summarizes key results of the quantitative description, is not formatted so that it can be copy-pasted for your own report.

% Open the text document for writing
file = fopen(txt_report, 'w');

% Define the content
report_title = 'Report on spatter image ';
description = 'The figure %s shows the stains processed with red ellipses.';
description2 = 'The scale bar top right measures 10 mm.';
description3=  sprintf('The scale of the original picture is %d pixel(s) per mm.', scale/10);
spots_description = sprintf('The number of spots processed is %d.', N_spots);
stains_description = sprintf('The number of stains measured is %d. ', N_stains_kept);
stains_description2=sprintf('The number of stains may be smaller than the number of spots because spots with width less than %d pixels are discarded.', Pixels_Noise);
stains_description3=sprintf('For the spatter considered, this corresponds to discarding spots with sizes less than %.3f mm.', Pixels_Noise/scale*10);
stains_description4=sprintf('Note that stains with significant "empty" area inside (solidity smaller than %d) are also discarded.', Solidity_threshold);
histogram_description = 'The data plotted in histograms is as follows, in mm: ';

% Write the content to the text document
fprintf(file, '%s%s\r\n\r\n', report_title, image_full_filename); %/n means carriage return, %s means string
fprintf(file, [description '\r\n'], processed_image_filename);
fprintf(file, '%s\r\n', description2);
fprintf(file, '%s\r\n', description3);
fprintf(file, '%s\r\n', spots_description);
fprintf(file, '%s\r\n', stains_description);
fprintf(file, '%s\r\n', stains_description2);
fprintf(file, '%s\r\n', stains_description3);
fprintf(file, '%s\r\n', stains_description4);
fprintf(file, '%s\r\n', histogram_description);
fprintf(file, '%s\r\n', blurb{1});


% Close the text document
fclose(file);
