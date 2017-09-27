function [ ] = dicom2avi( )
%% convert dicom files to avi
% Author: YSL; E-mail: ysl1abx@gmail.com
clc;

%note:
%If image is a grayscale or true-color image, map is empty.

%% get file part
%batch process
path = uigetdir('C:\', 'Select dataset path' );  %get the dicom file folder

if isequal(path,0)
   disp('User selected Cancel');
   errordlg('not a path selected, the program will exit','Error! Please slect a file path');
   error('Program exception');
else
   disp(['User selected ; ', path]);
end

pause(1);

A = dir(fullfile(path,'*.dcm'));% change to your image style which you want to change, the default of this program is dicom type

if isequal(isempty(A),1)
   disp('Not contain any files');
   errordlg('not a correct selection, the program will exit','Error! Please slect the right postfix');
   error('Program exception');
else
   disp('processing... ');
end

N = natsortfiles({A.name}); % sort file names into order
%% save type part
savepath = uigetdir('C:\', 'Select save path' );  %set the save folder

if isequal(savepath,0)
   disp('User selected Cancel');
   errordlg('not a path selected, the program will exit','Error! Please slect a save path');
   error('Program exception');
else
   disp(['User selected ; ', savepath]);
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
  
ConvertFrameNum = numel(N); %get the number of files
TF = true;

for k = 1 : ConvertFrameNum
    %get files one by one
    direction = fullfile(path,N{k});
    %can also read dicom file from its information data, but the image will
    %display other information besides image
    metadata = dicominfo(direction,'UseDictionaryVR', TF);%get information of dicom file. delete the parameter, if matlab2010a, such as: metadata = dicominfo(fullfile(path, name))

    %image information sample:
    %Filename: [1x62 char]
    %FileModDate: '18-Dec-2000 11:06:43'
    %FileSize: 525436
    %Format: 'DICOM'
    %FormatVersion: 3
    %Width: 512
    %Height: 512
    %BitDepth: 16
    %ColorType: 'grayscale'
    %SelectedFrames: []
    %FileStruct: [1x1 struct]
    %StartOfPixelData: 1140
    %FileMetaInformationGroupLength: 192
    %FileMetaInformationVersion: [2x1 uint8]
    %MediaStorageSOPClassUID: '1.2.840.10008.5.1.4.1.1.7'
    [Y,MAP] = dicomread(metadata);

    %uint16 to uint8
    M = mat2gray(Y);
    %resize to unified size
    T = imresize(M,[wid,lent],'bicubic');
    JpegImg = mat2gray(T);
    [l,m,n] = size(JpegImg);
    
    if (strcmp(Compression_mode,'Grayscale AVI'))
        if (n == 1)
            Mov = JpegImg;
        else
            JpegImg = rgb2gray(JpegImg);
            Mov = JpegImg; 
        end
    elseif (strcmp(Compression_mode,'Indexed AVI'))
        if (n == 1)
            [X,map] = gray2ind(JpegImg,256); %add index
            Mov = im2frame(X,map);                  
        else
            JpegImg = rgb2gray(JpegImg);
            [X,map] = gray2ind(JpegImg,256);
            Mov = im2frame(X,map);           
        end
    elseif (strcmp(Compression_mode,'Uncompressed AVI')) || (strcmp(Compression_mode,'Motion JPEG AVI')) || (strcmp(Compression_mode,'MPEG-4'))
        if (n == 1)
            [X, map] = gray2ind(JpegImg, 256);
            Mov = im2frame(X,map);
        else
            Mov = im2frame(JpegImg,MAP);
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

