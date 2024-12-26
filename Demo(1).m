 
clc;
clear all;

%% load data
addpath(genpath(pwd));
%-------------------------------------
% % % % % pavia
load ./data/pavia.mat   % referenced image
S = X(1:256,1:256,:);

% % % % % Harvard
% load  ./data/HarvardUniversity.mat
% S=ref(1:512,1:512,1:31);

% % % % % realZYdata64
% load  ./data/semirealZYdata64.mat
% S = HR_HSI(1:512,1:512,1:31)

%--------------------------------------
S=double(S);
S=S/max(S(:));
HR_HSI = S;
[M, N, B] =size(HR_HSI);
HR_HSI2 = hyperConvert2D(HR_HSI); 
sd =64; % Spatial downsampling
% % 
load ./data/L.mat
R=L(:,1:B);
% % % 
% load  ./data/P_N_V2.mat
% R =P(:,1:B);
% % 
for i=1:size(R,1)
    sum1=sum(R(i,:));
    for j=1:size(R,2)
        R(i,j)=R(i,j)/sum1;
    end
end
% % 
% % 
%% simulation HSI and MSI

MSI2 = R*HR_HSI2;
MSI = reshape (MSI2', M,N,size(MSI2,1));
psf =  fspecial('gaussian',7,2);
% psf =  fspecial('average');
% psf =  fspecial('laplacian');

HR_blur = imfilter(HR_HSI,psf ,'same'); 
HSI = HR_blur(1:sd:end, 1:sd:end,:);
[m, n, B]=size(HSI);
HSI2 = (reshape (HSI,m*n,B))';

% MSI2 = hyperConvert2D(MSI);



%% fusion  ours

t1=clock;   
[Z2] =  GIMO( HSI, MSI,R);
t1=etime(clock,t1)

displayHRHSIBandsAsRGB(Z2);

[psnr41,rmse41, ergas41, sam41, uiqi41, ssim41, DD41, CC41] = quality_assessment(double(im2uint8(S)), double(im2uint8(Z2)), 0, 1.0/sd);
% fprintf('Quality indices hybrid:\nPSNR=%2.3f REMSE=%2.3f ERGAS=%2.3f SAM=%2.3f UIQI=%2.3f SSIM=%2.3f DD=%2.3f CC=%2.3f\n', ...
fprintf('Quality indices:\n \n %2.3f \n %2.3f \n %2.3f \n %2.3f \n %2.3f \n %2.3f\n ', ...
psnr41,rmse41,ergas41,sam41,uiqi41,ssim41)


