function [salMap,salMapT,salMapS]=calcSalMap(dataF,wsize_s,wsize_t,wS,wT)
%
% Calculate saliency map for video combining spatial and temporal saliency
%
% salMap: calculated overall salience maps
% salMapT: calculated temporal salience maps
% salMapS: calculated spatial salience maps
%
% dataF: fft data from video frames
% wsize_s: window size in x and y directions
% wsize_t: window size in t direction
% wS: weight for spatial saliency
% wT: weight for temporal saliency
%
%% Start of program
salMapT=calcSalMap1(dataF{1},wsize_s,wsize_t);
salMapS=calcSalMap1(dataF{2},wsize_s,wsize_t);

salMap=wT*salMapT+wS*salMapS;
%% End of program

function salMap=calcSalMap1(dataF,wsize_s,wsize_t)
%
% Calculate saliency map for video data
%
% salMap: saliency map
%
% dataF: fft data from video frames
% wsize_s: window size in x and y directions
% wsize_t: window size in t direction
%
% Code modified on the basis of Seo's code for LARK/Self-Resemblance:
% Seo, H., Milanfar, P. (2009), “"Static and space-time visual saliency 
% detection by self-resemblance", Journal of Vision (2009) 9(12):15, 1-27.
%
%% Start of program
hw_s=(wsize_s-1)/2;
hw_t=(wsize_t-1)/2;

% Mirror reflection for borders
dataF1=EdgeMirror3(dataF,[hw_s,hw_s,hw_t]);   

% All center values
Center=reshape(dataF,[size(dataF,1)*size(dataF,2)*size(dataF,3) 1]);

% Calculate saliency map
salMap=zeros(size(dataF,1)*size(dataF,2)*size(dataF,3),1,'single');
for i=1:wsize_s
    for j=1:wsize_s
        for k=1:wsize_t
            if i==hw_s+1 && j==hw_s+1 && k==hw_t+1 % Self; skip
                continue;
            else
                % Compute similarity between a center and neighbors
                temp1=Center-reshape(dataF1(i:i+size(dataF,1)-1,...
                    j:j+size(dataF,2)-1,k:k+size(dataF,3)-1),...
                    [size(dataF,1)*size(dataF,2)*size(dataF,3) 1]);
                salMap=salMap+abs(temp1);
            end
        end
    end
end
salMap=salMap/(wsize_s^2*wsize_t-1);
salMap=reshape(salMap,[size(dataF,1) size(dataF,2) size(dataF,3)]);
%% End of program