# Open-source Tools for Quantitative Description of Blood Spatter Patterns

A set of tools that measures and describes stains from spatter images.
 This document describes how to perform quantitative analyses of blood spatter patterns, following these three steps:

- image preprocessing: measure length scale and threshold an image of spatter stains into a black/white thresholded image with black stains on white background.
- image processing \(with Octave\): Stains on thresholded images will be counted, their position and size measured, and ellipses fitted. The result of this step is a data file containing the measurement information.
- quantitative analysis \(with Octave\): Statistical data of stain size, location, spatial density, etc. are provided by processing the data file.

Author: Daniel Attinger
[daniel.attinger@gmail.com](mailto:daniel.attinger@gmail.com)
Struo LLC
Ames IA

File Written August 2023

Required Repository Files to run the code:

- BetterEllipse.m
- CompareHistograms.m
- DescribeQuant.m
- HistogramPrepMultiple.m
- HistogramSingle.m
- MapAspectRatio.m
- MapDensity.m
- ProcessImages.m
- RankStains.m
- SegmentImage.m
- SuperposeEllipses.m
- SuperposeEllipses_direct_write.m
- TestConvertImage.m
- fitellipse.m
- imreadort.m
- nhist.m
- write_text_report.m

The image preprocessing step is done with dedicated open source software like GIMP or FIJI. The next two steps are done by running the script files provided in this package with the open\-source scientific computing software Octave. All the work can be done on your local computer \(Mac, PC, Linux\) or from a web browser using online computing services indicated below. While Octave is generally compatible with Matlab, these scripts have not been tested with Matlab and its toolboxes.

# Video Presentation of the tool
[https://youtu.be/t4qPyakseR8](https://youtu.be/t4qPyakseR8?si=q3cO7dhipfp4J5ys) describes the following topics:  
-Rationale  
-Concept of the open-source tool  
-Workflow, input and output  
 quantitative measurements of spatter patterns  
-Preprocessing of Images  
-Under the hood: Technology   
-Accuracy and Performance  
-Examples relevant to BPA  
                 Classification  
                 Quality Control  
                 Physical Basis of BPA  
                 Area of Convergence/Origin  
-Download and Contact Info  
-Conclusion, Acknowledgements  
-Bibliography  

# Installation

## installation of image preprocessing software or online use

My favorite open\-source and image\-processing software is Gimp. It is freely available from https://www.gimp.org/downloads/ for Mac, PC, Linux. An alternative is FIJI, which was funded by the US Government to help scientists process images. FIJI is the latest version of ImageJ that has been around for decades. FIJI is freely available for installation on your personal computer at https://imagej.net/software/fiji/downloads . As checked in August 2023, FIJI can also be run online by pointing your web browser at https://ij.imjoy.io/ .

## installation of scientific computing software or online use

Download and install the latest stable release of Octave from https://octave.org/download \(our code was tested with version 8.2.0 and Octave is generally backward compatible. Octave can run on Windows, Mac or Linux machines.  

Install the needed packages of functions by typing the following instruction in the Octave command window \(and then pressing return\):

pkg install \-forge io 

pkg install \-forge statistics 

pkg install \-forge signal 

pkg install \-forge image

The following instructions are also useful:

pkg list \(gives a list of installed packages\)

pkg update \(updates all installed packages to latest version\)

Once Octave is installed, download the package of scripts and images from the GitHub repository, and unzip these to a folder in your computer. The scripts list Octave commands to process and quantify spatter patterns, according to the three steps below. By opening these scripts in the Octave editor, and running these in the Octave command window, you will be able to perform tasks B and C below, which process images and produce quantitative results from blood spatter patterns. 

Octave is a scientific computing software that has been around for decades. It is open\-source and highly compatible with the proprietary Matlab which has been a favorite scientific computing software of engineers and physicists. The scripts provided in this project \(files ending with .m, aka "m\-files"\) tell Octave what to do with the images and data until it outputs results such as images of stains with ellipses fitted, histograms, density maps, etc. Here is an instructional video on how to get started with Octave: https://www.youtube.com/watch?v=ZOs4eqoXPPA . Octave is also available on online services such as [www.Cocalc.com](http://www.Cocalc.com), in version 8.2.

# Process images with these three steps (A,B,C)

FIrst, preprocess your image either with Fiji or Gimp.

## A. Preprocessing Image \(with FIJI\)

In the subfolder 'images' of the code folder, move your own spatter pattern images or use the available spatter pattern images. Note, you can skip this file if you work with images ending with '\*\_BW.png' that have already been prepared.

Preprocessing large images take more computing resources in Octave than in dedicated image processing software, so we preprocess the image with FIJI as a dedicated tool, and save the image as a thresholded black/white \(B/W\) image in the lossless ".png" format. Contrary to the more popular ".jpg" format, the ".png" format maintains image quality during successive saves.

- Open the desired image: File&gt;Open
- Analyze&gt;Measure the scale of your image, in pixels/cm. \(Walkthrough with FIJI at https://www.youtube.com/watch?v=EkYBbeRXDPw&t=60s \) \(Note: several image files from the folder named "HP\_\*.png were scanned at a scale of 236.2 pixels per cm, corresponding to 600 DPI, and have no visible scale\).
- Document the scale in association with the name of your image file.
- Convert image to grayscale: Menu Image&gt;Type&gt;8 bit
- Crop unnecessary elements \(all locations without stains\) from your images with the Crop tool 
- Threshold the image: Image&gt;Adjust&gt;Threshold.  Move the two sliders until the background and stains are separated in black and white. You can zoom with keys "\+" or "\-". Click Apply when threshold is satisfactory, to perform thresholding. For complex background, you can threshold from different colors of the original colored image, or you may need to retake the picture with different light if the scene is still available.
- Use the Eraser tool to remove black elements that are obviously not stains \(ruler, features of target surface\). Note: if the Eraser Tool is not present: More Tools&gt;Drawing Tools
- File&gt;Export As "\*BW.png" \(this high\-quality format does not lose information, and BW stands for black and white\). Set compression level to '6' but any is fine and will only affect image reading time, and will not lose image information.
- Compare the ".png" image with the original image to make sure that the stains are well\- thresholded. The black regions should correspond as exactly as possible to the stains in the original image. 

## A. Preprocessing image \(with GIMP\)

In the subfolder 'images' of the code folder, move your own spatter pattern images or use the available spatter pattern images. Note, you can skip this file if you work with images ending with '\*.BW.png' that have already been prepared.

Preprocessing large images take more computing resources in Octave than in dedicated image processing software, so we preprocess the image with GIMP as a dedicated tool, and save the image as a thresholded black/white \(B/W\) image in the lossless ".png" format. Contrary to the more popular ".jpg" format, the ".png" format maintains image quality during successive saves.

- Open the desired image with Gimp: File&gt;Open
- Use the Measure tool \(the one that looks like a compass\) to measure the scale of your image, in pixels/cm. \(Walkthrough for GIMP at \[[https://www.youtube.com/watch?v=8gf\_aFtYHYQ](https://www.youtube.com/watch?v=8gf_aFtYHYQ) \)\]\([https://www.youtube.com/watch?v=8gf\_aFtYHYQ](https://www.youtube.com/watch?v=8gf_aFtYHYQ)\) \(Note: several image files from the folder named "HP\_\*.png were scanned at a scale of 236.2 pixels per cm, corresponding to 600 DPI, and have no visible scale\).
- Document the scale in association with the name of your image file.
- Convert image to grayscale: Menu Image&gt;Mode&gt;Grayscale
- Crop unnecessary elements \(all locations without stains\) from your images with the Crop tool 
- Threshold the image: Menu Colors&gt;Threshold.  Modify the Channel values \(typically the left one that starts at 127\) and inspect image using 'Split View' and sliding the vertical slider bar, until the stains and background are separated as black and white regions. You can zoom with keys "\+" or "\-". Click OK when chosen threshold is satisfactory, to perform thresholding. For complex background, you can threshold from different colors of the original colored image, or you may need to retake the picture with different light if the scene is still available.
- Use the Eraser tool to remove black elements that are obviously not stains \(ruler, features of target surface\)
- File&gt;Export As "\*\_BW.png" \(this high\-quality format does not lose information, and BW stands for black and white\). Set compression level to '6' but any is fine and will only affect image reading time, and will not lose image information.
- Compare the ".png" image with the original image to make sure that the stains are well\-thresholded. The black regions should correspond as exactly as possible to the stains in the original image. 

## B. Processing of Thresholded Black/White Image Files

After thresholding the image with either GIMP or FIJI \(sections A\), the image can be processed to identify \('segment'\) the stains, measure these and save all the measurements in a ".mat" data file. This process can be done for a single file or for multiple files that have been thresholded.

Enter the names of the thresholded files that you want to process, one per row of the file "Files2Process.csv" located in the subfolder 'images' of the folder where you have installed the downloaded Quantify Spatter scripts. This file can be edited with Excel or with a text editor.  Runn the script ProcessImage.m  in Octave as follows:

- Set the folder where the script is as the current directory of Octave command window
- Script ProcessImages.m measures stains on one or several pictures of spatter patterns.
- INPUT: List the images to process in the CSV file located in the subfolder 'images'. The CSV file has one header line and the following columns in order:
- Column A: filename  \- images need to be black and white thresholded images in ".png" format. Ex: "image1.png"
- Column B: scale, in pixels per mm. This is the scale you have measured in step A. Ex: 231.
- Column C: nickname \(optional\), useful as legends in some output plots
- Column D: Path to the folder where code is run \(Typically, the images are placed in the subfolder "images", but the path can be relative or absolute\)
- Columns E\-F: Notes and Source, optional and for user reference only.
- OUTPUT: a file '\*_\_data.mat' with measurements such as location of stain, width of the ellipse, height of the ellipse, location of the centroid of the stain._
- File '\*\_data.mat' file is saved in the same folder as the '\*.png' image.

As files are processed, the "\*.mat" files are produced in the directories where the images are located. Note that the following message means that your file was not processed: "image\_full\_filename = C:\\Users\\code\\images\\low\_angles\_not BW.png. warning: code requires thresholded images. Please save as 8 bit and threshold in B/W before running code"

## C. Quantitive Description

Describe the image quantitatively by running script DescribeQuant.m in Octave which outputs several quantitative measurements of the spatter patterns in the form of plots or enhanced images. 
The measurement of the stains is based on the Octave script regionprops from the image analysis package of Octave.

Script DescribeQuant.m can be run after one or several '_.png' spatter pattern pictures have been processed by ProcessImages.m._

Set the folder where the script is as the current directory of Octave command window

_User input: The name and location of the files to describe quantitatively are provided in a dedicated file "Files2DescribeQuant.csv", located in the 'images' subfolder._

_Outputs are saved as enhanced images or images of plots in the folder containing the input image:_

_'\*_\_identified.png', B/W picture of spatter pattern with ellipses fitted in red around stains. Fitting an ellipse around stains is one of the measurements performed.

'\*_\_identified\_b.png', same as above, but with arrows showing directionality of drop impact by pointing towards the tail of the stain \(our best guess, works obviously better for stains that exhibit a distinguishable tail\)_

_'\*_\_Hist\_size\_numbers.png'% histogram of stain sizes, y\-axis is number of stains per mm, and x\-axis is size of stains in mm

'\*_\_Hist\_size\_percent.png'% histogram of stain sizes, y\-axis is binned percentage of stains per mm, and x\-axis is size of stains in mm_

_'\*_\_Density\_map.png' % spatial map of number density of stains

_'\*_\_Aspect\_ratio\_map.png'  spatial map of aspect ratios of stains. Aspect ratio is length over width of the fitted ellipse, and can be used to estimate the impact angle.

% Note that each time the script is run, existing result files are erased and replaced with the new ones

## D. Compare histograms of several blood spatter patterns running CompareHistograms.m \(optional\)

% CompareHistograms.m is a script that prepares data to plot several histograms on top of each other.


INPUT: provide the name of two or more '\*_.mat' data files in the file Histograms2Compare.csv located in the subfolder 'images' of the directory where the scripts are installed._

_OUTPUT: two images of histograms of the data, with names defined in variables 'histogram\_percent', and 'histogram\_numbers'_

_The script sends INPUT data to nhist, the script for plotting nice histograms by Jonathan Lansey_

_Note that the output of the command windows provides this kind of data that complements the plots, saved in the '_\_report.txt' file:

"Script successfully plotted histograms
for the data that you provided at the beginning of this script: \(list of filenames\)
{  \[1,1\] = Plot #1: mean=0.62, std=1.00, minimum=0.62, 5 points counted in the rightmost bin are greater than 4.58 ,  \[1,2\] = Plot #2: mean=1.03, std=0.78, minimum=1.03, 15 points counted in the rightmost bin are greater than 4.58 }

The bar on top of the histogram shows the mean \+/\- standard deviation. 
saved image of histogram of stain percentiles: Compared\_Hist\_percent.png,
saved image of histogram of stain numbers:  Compared\_Hist\_numbers.png.
Each histogram image file available in the same directory where the code is located, for download.

# How to take good pictures of blood traces

1. Use DSLR camera, perpendicular to stained surface. 
2. Use sufficient light \(incandescent is not best\) and/or tripod to prevent blur
3. adjust exposure time or aperture to maximize picture quality.
4. Take picture of entire spatter pattern, with a scale labelled in mm and a label \(both should ideally be in an area without stains\).

# Licenses:

All licenses for third party scripts are included and must be kept with provided scripts. If third\-party materials were not cited within the repository Licenses folder, this was not intentional by the author.

# Need more help?

If you happen to need more information regarding:

- image preprocessing: ample help is available on youtube to learn how to perform specific instructions , like "How to threshold image in GIMP". 

- other issues: if the code crashes, or if you have an application or improvement idea feel welcome to contact Dr. Attinger.

