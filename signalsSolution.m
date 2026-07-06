% reading the file and storing it
I1 = imread("cursed_schematic_05.png"); 

%using the median filter with 3x3 area to remove the salt and pepper noise
F1 = medfilt2(I1, [3, 3]); 

%using fft to convert the image into frequency medium 
F1 = im2double(F1); 
FFT_F1 = fft2(F1); 

%shifting it so that the 0 frequency is in the middle, or centering the
%image about 0 frequency
f1shifted = fftshift(FFT_F1); 

%finding absolute value because fft stores values in complex number form
mags = abs(f1shifted);

%finding the dimensions of the image and making a grid of those dimensions
[columns, rows] = size(I1); 
[xgrid, ygrid]  = meshgrid(1:rows, 1:columns); 

%creating a grid of distances from the center 
distances = sqrt((xgrid - rows/2).^2 + (ygrid - columns/2).^2); 

%ignoring the extremely low frequencies because they commonly have highest peaks,
%but we only require high peaks that due to noise in the image 
only_search = distances > 10; 
mag_search = mags .* only_search; 

%searching the image with lower frequencies removed to find the peaks
%formed due to noise 
[mval, mindex] = max(mag_search(:)); 
[peakx, peaky] = ind2sub(size(mag_search), mindex); 

%after we found the peaks we find the distance of those peaks from the
%center
R = sqrt((peakx - rows/2).^2 + (peaky - columns/2).^2); 

%after that we create filter that removes the frequencies in a small
%segment around the distance at which we found the peaks 
filter = (distances > R+6) | (distances < R-6);

f_filt = f1shifted .* filter; 

%we apply the inverse fft shift and fft functions to get the filtered image
filt_image_complex = ifftshift(f_filt); 
filt_image = real(ifft2(filt_image_complex));

%we apply a blue and white blueprint filter such that the areas which have
%higher intensity and are lighter will be white and the areas which have a
%darker color and lower intensity will be blue
blueprint_image = (cat(3, filt_image, filt_image, 1+filt_image*0)); 

%showing the image
imshow(blueprint_image, []); 