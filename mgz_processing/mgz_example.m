function [  ] = mgz_example( )
%% Demonstrate how to use mgz_processing function.
%  Will convert a brainmask.mgz file (which download from ADNI) to image
%  and nii format 3D-matrix.
% mgz_processing function only support nii format as input.

% Author: Yan Song-lin, PhD
%         Computer Network Information Center
%         Chinese Academy of Sciences
%         Beijing, China
% E-mail: ysl1abx@gmail.com
% Copyright (c) 2017, December 
% All rights reserved.
% Compiled by matlab 2016a

workDir = '002_S_0729';
fname = strcat(workDir, '\brainmask.mgz');
[name, file_details, nii_data, original_data] = mgz_processing(fname, '002_S_0729', '.nii'); % if you want to save nii file, it will save in 002_S_0729 folder.

image = original_data(:,:,128);
figure,imshow(image);title('gray image');
%nii = nii_tool('load', '002_S_0729\brainmask.nii'); % if you has already saved data as nii format, you can read it. 
%savefname = '002_S_0729\sample.mat';
%save(savefname, 'image', '-v7'); % save matrix as mat format
pause(1);

end

