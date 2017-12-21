function [ ] = NIfTI2avi( )
%% convert NIfTI format to avi format
%Author: YSL; E-mail: ysl1abx@gmail.com
%Copyright (c) 2017, Yan Song-lin
%All rights reserved.
%compiled by matlab 2016a
clc;

%% get file part
%batch process
[filename, pathname] = uigetfile( ...
{'*.nii','NIfTI (*.nii)'}, ...
 'Select a file');
if isequal(filename,0)
   disp('User selected Cancel');
   errordlg('not a file selected, the program will exit','Error! Please slect a file');
   error('Program exception');
else
   disp(['User selected:', fullfile(pathname, filename)]);
end

old_direction = fullfile(pathname,filename);
pause(1);

prompt1 = {'please input the postfix: '};
dlg_title1 = 'file postfix';
num_lines1 = 1;
def1 = {'reslice'};
value1 = inputdlg(prompt1,dlg_title1,num_lines1,def1);
input1 = value1{1,1};

[pathstr,fname,ext] = fileparts(filename);
new = strcat(fname,'_',input1,ext);
new_direction = fullfile(pathname,new);

if (exist(new_direction,'file') == 2) 
    delete(new_direction);
end

%parameters: old_fn, new_fn, [voxel_size], [verbose], [bg], [method]
% if you get error, uncomment the line below.
%reslice_nii(old_direction,new_direction,[], 1, [], 3);%for confirming nii format can be read by load_nii function, convert original file to new style 
%nii = load_nii(new_direction);% uncomment this line, and comment the line below 
nii = load_nii(old_direction);%to load NIFTI data to a structure: 
pause(1);
%% save type part
savepath = uigetdir('C:\', 'Select save path' );  %set the save folder

if isequal(savepath,0)
   disp('User selected Cancel');
   errordlg('not a path selected, the program will exit','Error! Please slect a save path');
   error('Program exception');
else
   disp(['User selected : ', savepath]);
end

pause(1);

prompt1 = {'save file name:'};
name1 = 'Enter avi file name';
numlines1 = 1;
defAns1 = {'Movie'};
Resize1 = 'on';
answer1 = inputdlg(prompt1,name1,numlines1,defAns1,Resize1);

pause(1);

AviFilename = strcat(answer1,'.avi');
AviFile = fullfile(savepath,AviFilename{1});

%will delete existed the same name file
if (exist(AviFile,'file') == 2) 
    delete(AviFile);
end
pause(1);
%% parameter part
prompt = {'length:','width:'};%set notification string
name = 'Enter unified size of input data';%set title
numlines = 1;%set row of input data
defAns = {'512','512'};%set default value
Resize = 'on';%set dialogue box that can be tuned
answer = inputdlg(prompt,name,numlines,defAns,Resize);%create input interface

lent = str2double(answer{1});  
wid = str2double(answer{2});
if (isequal(isempty(lent),1)) || (isequal(isempty(wid),1)) || (isequal(isnan(lent),1)) || (isequal(isnan(wid),1)) || (lent <= 0) || (wid <= 0)
    disp('User does not enter any parameter');
    errordlg('not a correct parameter entered, the program will exit','Error! Please enter right number');
    error('Program exception');
end

pause(1);

%Compression mode:
%      'Archival'         - Motion JPEG 2000 file with lossless compression
%      'Motion JPEG AVI'  - Compressed AVI file using Motion JPEG codec.
%                           (default)
%      'Motion JPEG 2000' - Compressed Motion JPEG 2000 file
%      'MPEG-4'           - Compressed MPEG-4 file with H.264 encoding 
%                           (Windows 7 and Mac OS X 10.7 only)
%      'Uncompressed AVI' - Uncompressed AVI file with RGB24 video.
%      'Indexed AVI'      - Uncompressed AVI file with Indexed video.
%      'Grayscale AVI'    - Uncompressed AVI file with Grayscale video.
[sel,ok]=listdlg('ListString',{'Grayscale AVI','Indexed AVI','Uncompressed AVI','Motion JPEG AVI','MPEG-4'},...  
    'Name','avi mode selection','PromptString','Select a mode:','OKString','ok','CancelString','cancel','SelectionMode','single','ListSize',[250 250]); 

if isequal(ok,0)
    disp('User selected Cancel');
    disp('the mode will be set Grayscale AVI as default');
    Compression_mode = 'Grayscale AVI';
else
    switch sel
        case 1
            Compression_mode = 'Grayscale AVI';  
        case 2
            Compression_mode = 'Indexed AVI';
        case 3
            Compression_mode = 'Uncompressed AVI';
        case 4
            Compression_mode = 'Motion JPEG AVI';
        case 5
            Compression_mode = 'MPEG-4';
        otherwise
            errordlg('not a right mode','Error! Please slect a right mode');
            error('Program exception');
    end
end

pause(1);

%frame rate
prompt2 = {'frame rate:'};
name2 = 'Enter frame rate of movie';
numlines2 = 1;
defAns2 = {'12'};
Resize2 = 'on';%set dialogue box that can be tuned
answer2 = inputdlg(prompt2,name2,numlines2,defAns2,Resize2);%create input interface

rate = str2double(answer2{1});  
if (isequal(isempty(rate),1)) || (isequal(isnan(rate),1)) || (rate <= 0)
    disp('User does not enter any parameter');
    errordlg('not a correct parameter entered, the program will exit','Error! Please enter right number');
    error('Program exception');
end

pause(1);
%% main
view_nii(nii); %to plot a nii struct:
pause(1);
[l,m,n] = size(nii.img);%get the number of files

%write to avi
AviFileObj = VideoWriter(AviFile,Compression_mode); 

%frame rate (the menber of class)
AviFileObj.FrameRate = rate;  
%frame quality: Integer from 0 through 100. Only applies to objects associated with the Motion JPEG AVI and MPEG-4 profiles.
%AviFileObj.Quality = 100;  %0-100
 
%note: Number of color channels in each output video frame, specified as a positive integer:
%      Uncompressed AVI, Motion JPEG AVI, and MPEG-4 files have three color channels.
%      Indexed and grayscale AVI files have one color channel.
%      For Motion JPEG 2000 files, the number of channels depends on the input data to the writeVideo function: one for monochrome image data, three for color data.

% Open file  (start writer)
open(AviFileObj);  

for k = 1 : n
    %get files one by one
    A = nii.img(:,:,k);
    %uint16 to uint8
    M = mat2gray(A);
    L = imrotate(M,90,'bilinear','crop');
    %resize to unified size
    T = imresize(L,[wid,lent],'bicubic');
    JpegImg = mat2gray(T);
    [l1,m1,n1] = size(JpegImg);
    
    if (strcmp(Compression_mode,'Grayscale AVI'))
        if (n1 == 1)
            Mov = JpegImg;
        else
            JpegImg = rgb2gray(JpegImg);
            Mov = JpegImg; 
        end
    elseif (strcmp(Compression_mode,'Indexed AVI'))
        if (n1 == 1)
            [X,map] = gray2ind(JpegImg,256); %add index
            Mov = im2frame(X,map);                  
        else
            JpegImg = rgb2gray(JpegImg);
            [X,map] = gray2ind(JpegImg,256);
            Mov = im2frame(X,map);           
        end
    elseif (strcmp(Compression_mode,'Uncompressed AVI')) || (strcmp(Compression_mode,'Motion JPEG AVI')) || (strcmp(Compression_mode,'MPEG-4'))
        if (n1 == 1)
            [X, map] = gray2ind(JpegImg, 256);
            Mov = im2frame(X,map);
        else
            Mov = JpegImg;
        end
    else
        Mov = JpegImg;
    end  
    if rem(k, 10) == 0  
        disp([num2str(k) ' frames processed...'])  
    end  
    %write images to avi file
    writeVideo(AviFileObj, Mov);  %can use frame or images as inputs, so parameter Mov can be image or frame type
end

% Close avi file & enable it
close(AviFileObj);
end

