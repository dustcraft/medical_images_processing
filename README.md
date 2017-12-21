# Medical images processing

## Medical file format to avi

----
### 1.DICOM to AVI

dicom2avi function (which is a matlab program) convert dicom file to avi. It needs third party function -natsortfiles function (see http://cn.mathworks.com/matlabcentral/fileexchange/34464-customizable-natural-order-sort ) ,and this function is compiled with matlab 2016a.

----
### 2.NIFTI to AVI

NIfTI2avi.m function convert nii format file to avi or mp4 format. It needs third party function: load_nii.m, reslice_nii.m and view_nii.m (see http://cn.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image ) ,and this function is compiled with matlab 2016a.

----
## MGZ Processing

This folder contains several functions and files. <br>
The source code downloaded from [Xiangrui Li's program](https://cn.mathworks.com/matlabcentral/fileexchange/42997-dicom-to-nifti-converter--nifti-tool-and-viewer "Click to show source code"). And I modify his code to my use, including nii_tool.m (where I delete save nii function, and add nii parameter to return.) and dicm2nii.m (where I rename it to mgz_processing.m ). <br>


### Note:
I change mgz_processing.m function a lot. Its input parameter can only use mgz format, and output parameter can only use nii format. <br>
For the details, please see function and mgz_example.m.


