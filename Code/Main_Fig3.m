%% Seismic Saliency
% ===============================================================================
%  Please, cite the following papers in your publication if you use this script.
% ===============================================================================
% M. Shafiq, T. Alshawi, Z. Long, and G. AlRegib, "SalSi: A New Seismic Attribute For Salt Dome Detection,"
% IEEE Intl. Conf. on Acoustics, Speech and Signal Processing (ICASSP), 
% Shanghai, China, Mar. 20-25, 2016.

% M. Shafiq, T. Alshawi, Z. Long, and G. AlRegib, “The role of visual saliency in the automation
% of seismic interpretation,” Geophysical Prospecting, 2017.

% If you have found any bugs or have any questions/suggestions, 
% please contact amirshafiq@gatech.edu 

%% Saliency based SD Detection
%% Init
clc
clear
close all

% Add path
addpath('Functions')
addpath('Mat Files')

%% Read Saliency Video
load salMapAllSlices

%% Read Seismic database
load  salt2_inline.mat;
SS_dataset = salt2_inline;
clear salt2_inline
load SD_Aqrawi
load SD_Oslu
load SD_2DGoT
load SD_3DGoT

%% Saliency based Salt Dome detection
Th_arr       = 0.04:0.01:0.25;
[~, TOI_ind] = find(Th_arr == 0.14);

SS_UT_num    = [120,135,180,210];
Disp_Overlay = 1;
Fr_ind       = 1;

%% Frame Loop
for SS_loop = 1:length(SS_UT_num)   % Frame_start:Frame_stop;

    SS_Num = SS_UT_num(SS_loop);
    % Frame under Test
    SS_UT   = salMapNormalized(:,:,SS_Num);
    IUT     = SS_dataset(:,:,SS_Num);
    IUT_Enh = (seisNormalize(IUT, 8000)+1)/2; 
    
    % Load Ground Truth
    load(['Ground_Truth_SS', num2str(SS_Num)],'-mat')
    Ground_Truth  = GT_SS;
    Ground_TruthB  = bwperim(Ground_Truth);
    Ground_TruthB(137,:) = false;
    SD_GT_ones    =  length(find(Ground_TruthB == true));
    SD_GT_zeros   =  length(find(Ground_TruthB == false));

    % Variable Init
    True_Pos_Rate           = zeros (1,length(Th_arr));    
    False_Pos_Rate          = zeros (1,length(Th_arr)); 
    True_Neg_Rate           = zeros (1,length(Th_arr)); 
    False_Neg_Rate          = zeros (1,length(Th_arr)); 
  
    ROC_ind = 1;
    % Convert to Binary Image
    Th_FUT = im2bw(SS_UT, 0.14);                      
    % Connect Points of Image
    Sal_OP = imclose(Th_FUT, strel('disk',5));  

    [ TP, FP, TN, FN ]   = ROC_calc( Sal_OP, Ground_TruthB);
    True_Pos_Rate (ROC_ind) = TP / (TP + FN);   % Sensitivity, Recall
    False_Neg_Rate(ROC_ind) = FN / (TP + FN);   % Miss rate, 1-True_Pos_Rate
    False_Pos_Rate(ROC_ind) = FP / (TN + FP);   % Fall out,  1-True_neg_Rate
    True_Neg_Rate (ROC_ind) = TN / (TN + FP);   % Specificity,

    % Calculate Frechet Similarity
    close_oper    = 10;   % Closing operator length
    Dil_oper      = 10;   % Dilation operator length

    Salt_Dome_sal = Extract_sal_SD_v02(close_oper, Dil_oper, Sal_OP, 0);
    Frech_sim_sal = SalSIM_cmpr(Ground_Truth,Salt_Dome_sal);
    fprintf('Frec_Sim b/w Sal and GT of SS#%d is ==> %f \n',SS_Num, Frech_sim_sal);

    Sal_temp = imdilate(Sal_OP, strel('disk',15));
    Sal_temp = imerode(Sal_temp, strel('disk',20));
    Sal_temp = imerode(Sal_temp, strel('disk',2));
    Sal_temp = imdilate(Sal_temp, strel('disk',3));

    if Disp_Overlay
        figure
        False_Color_SS = cat(3, IUT_Enh, IUT_Enh, IUT_Enh);
        imshow(IUT_Enh,[])
        hold on
        Color_sel = cat(3, zeros(size(IUT_Enh)), ones(size(IUT_Enh)), zeros(size(IUT_Enh)));
        h = imshow(Color_sel);
        Sal_Show = double(Sal_temp*0.4);
        set(h, 'AlphaData', Sal_Show)

        % Active Contour
        % 2D GoT
        Salt_Dome_2D    = SD_2DGoT(:,:,SS_Num);
        contour(Salt_Dome_2D, [0.5 0.5],'c','LineWidth',2);
        % 3D GoT
        Salt_Dome_3D    = SD_3DGoT(:,:,SS_Num);
        contour(Salt_Dome_3D, [0.5 0.5],'b','LineWidth',2);
        % Oslu
        Oslu_SD = SD_Oslu(:,:,SS_Num);
        contour(Oslu_SD, [0.5 0.5],'y','LineWidth',2);
        % Aqrawi
        Aqrawi_SD = SD_Aqrawif(:,:,SS_Num);
        contour(Aqrawi_SD, [0.5 0.5],'m','LineWidth',2);
        % Ground Truth
        contour(Ground_Truth,[0.5,0.5],'r','linewidth',2)
        hold off
        title(['Seismic Section #inline', num2str(SS_Num)], 'FontSize', 16 , 'fontname','Book Antiqua');  
    end
    ROC_ind = ROC_ind + 1;

    % Save ROC curves
    Fr_ind = Fr_ind + 1;
    pause(0.01)
end
