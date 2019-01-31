function dataN = seisNormalize(data, thres)
% SEISNORMALIZE first truncates the intensity of seismic signals from 
% [min(data(:)), max(data(:))] to [-thres,thres] and then normalize the 
% interval to [-1,1]. The purpose of this function is to show more details
% of seismic image. 

data1 = data;
tmp = find(abs(data(:))>thres);
data1(tmp) = sign(data(tmp)).*thres;
data2 = data1./thres;    % normalization to [-1,1]                 
dataN = data2;