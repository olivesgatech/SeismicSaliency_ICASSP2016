% Detect saliency for Salt Domes

%% Start of program

clear all
clc

% Parameters
wsize_s = 5;            % spatial window size (x and y) for center-surround comparison
wsize_t = 5;            % temporal window size (t) for c-s comparison
wsize_fs = 5;           % spatial window size (x and y) for fft
wsize_ft = 5;           % temporal window size (t) for fft
hw_t=(wsize_t-1)/2;     % Half window size (t) for c-s comparison
hw_ft=(wsize_ft-1)/2;   % Half window size (t) for fft
segLength = 351;        % # of frames to be processed at one time
count0=0;
count=0;
nSeg=0;

% load seismic data
load salt2_inline.mat;
thres = 8000;
Data = zeros(size(salt2_inline));
for slice = 1:size(salt2_inline,3)
    Data(:,:,slice) = (seisNormalize(salt2_inline(:,:,slice), thres)+1)/2;
end

% Normalize and take the mean from every slice
jStop = size(Data,3);
for j=1:size(Data,3)
    count=count+1;
    
    tmp=Data(:,:,count);
    stdTmp=std(tmp(:));
    if stdTmp==0 % Normalize, make sure not to divide by zero
        display(['determineSaliencyForSaltDome.m: slice=' num2str(j) ', std=0']);
        Data(:,:,count)=single(tmp-mean(tmp(:)));
    else
        Data(:,:,count)=single((tmp-mean(tmp(:)))/stdTmp);
    end
    
    if (count-count0)==(segLength+hw_t+hw_ft)... % Extra data at border for accuracy
            || j==jStop
        
        % Calculate FFT
        tic;
        DataSpectral=applyFft(Data,wsize_fs,wsize_ft);
        disp(['Calulating FFT: ' num2str(toc) 'sec']);
        
        % Compute space-time saliency
        tic;
        wS=0.5; wT=0.5; % To be improved with adaptive weights
        salMapTmp = calcSalMap(DataSpectral,wsize_s,wsize_t,wS,wT);
        for k = 1:size(salMapTmp,3)
            salMap(:,:,k) = imresize(salMapTmp(:,:,k),[size(Data,1) size(Data,2)],'bilinear');
        end
        disp(['Calculating saliency map: ' num2str(toc) 'sec']);
        
        % Save saliency map for the segment
        if (j==jStop)
            salMap=salMap(:,:,count0+1:count);
        else
            salMap=salMap(:,:,count0+1:count0+segLength);
        end
        
        
        % Reset data matrices and counters, keeping some data for next segment
        if (j~=jStop)
            Data=Data(:,:,count-2*hw_t-2*hw_ft+1:count);
            count0=hw_t+hw_ft;
            count=2*hw_t+2*hw_ft;
        end
    end
end

salMapNormalized = 1*(salMap-min(salMap(:)))/max(salMap(:));

%% End of program