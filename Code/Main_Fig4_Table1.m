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
% Init
clc
clear
close all

%% Add path
addpath('Functions')
addpath('Mat Files')

%% Read Saliency Video
load salMapAllSlices

%% Read Seismic database
load  salt2_inline.mat;
SS_dataset = salt2_inline;
clear salt2_inline

%% Saliency based Salt Dome detection
Thres_start = 0.04; 
Thres_inc   = 0.01; 
Thres_stop  = 0.25;
Th_Interest = 0.14;     

Th_arr       = Thres_start:Thres_inc:Thres_stop;
[~, TOI_ind] = find(Th_arr == Th_Interest);

% Frame variables
Frame_start  = 210;
Frame_stop   = Frame_start;
Frame_arr    = Frame_start:Frame_stop;
TP_Frame     = zeros(length(Th_arr),length(Frame_start:Frame_stop));
FP_Frame     = zeros(length(Th_arr),length(Frame_start:Frame_stop));
Frech_sim_sal= zeros(length(Th_arr),length(Frame_start:Frame_stop));
Fr_ind       = 1;

SS_UT_num      = [120,135,180,210];
Dataset_offset = 249;

Display_Performance_Curves = 1;
Display_ROC = 1;


%% Frame Loop
for SS_loop = 1:length(SS_UT_num)   % Frame_start:Frame_stop;

    Fr_Num = SS_UT_num(SS_loop);
    % Frame under Test
    FUT     = salMapNormalized(:,:,Fr_Num);
    IUT     = SS_dataset(:,:,Fr_Num);
    IUT_Enh = (seisNormalize(IUT, 8000)+1)/2; 
    
    % Load Ground Truth
    load(['Ground_Truth_SS', num2str(Fr_Num)],'-mat')
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

    for Th_loop = Thres_start:Thres_inc:Thres_stop 
        % Convert to Binary Image
        Th_FUT = im2bw(FUT, Th_loop);                      
       
        % Connect Points of Image
        Sal_OP = imclose(Th_FUT, strel('disk',5));  
        
        % ROC values
        [ TP, FP, TN, FN ]   = ROC_calc( Sal_OP, Ground_TruthB);

        True_Pos_Rate (ROC_ind)    = TP / (TP + FN);   % Sensitivity, Recall
        False_Neg_Rate(ROC_ind)    = FN / (TP + FN);   % Miss rate, 1-True_Pos_Rate
        False_Pos_Rate(ROC_ind)    = FP / (TN + FP);   % Fall out,  1-True_neg_Rate
        True_Neg_Rate (ROC_ind)    = TN / (TN + FP);   % Specificity,
        
        % Calculate Frechet Similarity
        close_oper    = 10;   % Closing operator length
        Dil_oper      = 10;   % Dilation operator length
        
        Salt_Dome_sal = Extract_sal_SD_v02(close_oper, Dil_oper, Sal_OP, 0);
        Frech_sim_sal(ROC_ind, Fr_ind) = SalSIM_cmpr(Ground_Truth,Salt_Dome_sal);
        fprintf('Calculating Saliency of SS#%d @ Threshold %f \n',Fr_Num, Th_loop);
    
        %% Overlaying Salient boundary on SS
        Sal_temp = imdilate(Sal_OP, strel('disk',15));
        Sal_temp = imerode(Sal_temp, strel('disk',20));
        Sal_temp = imerode(Sal_temp, strel('disk',2));
        Sal_temp = imdilate(Sal_temp, strel('disk',3));
        ROC_ind = ROC_ind + 1;
    end
    
    % Save ROC curves
    TP_Frame(:,Fr_ind) = True_Pos_Rate;
    FP_Frame(:,Fr_ind) = False_Pos_Rate;

    Fr_ind = Fr_ind + 1;
    pause(0.01)
end

%% Display ROC

if Display_ROC
    ROC_fig = figure;
    plot([1; FP_Frame(:,1); 0], [1;TP_Frame(:,1); 0], '-*b','linewidth',2,'MarkerSize',10)
    hold on
    plot([1; FP_Frame(:,2); 0], [1;TP_Frame(:,2); 0], '-^r','linewidth',2,'MarkerSize',10)
    plot([1; FP_Frame(:,3); 0], [1;TP_Frame(:,3); 0], '-+m','linewidth',2,'MarkerSize',10)
    plot([1; FP_Frame(:,4); 0], [1;TP_Frame(:,4); 0], '-ok','linewidth',2,'MarkerSize',8)
    plot([0,1],[0,1], '--r','linewidth',2)
    hold off
    axis([0 1 0 1])
    legend(['Seismic Section inline # ',num2str(SS_UT_num(1)+Dataset_offset)], ['Seismic Section inline # ',num2str(SS_UT_num(2)+Dataset_offset)], ...
           ['Seismic Section inline # ',num2str(SS_UT_num(3)+Dataset_offset)], ['Seismic Section inline # ',num2str(SS_UT_num(4)+Dataset_offset)])
    xl_text = 'False Positive Rate (1 - Specificity)';
    yl_text = 'True Positive Rate (Sensitivity)';
    set(get(gca,'xlabel'),'string',xl_text,'fontsize',24, 'fontname','Book Antiqua')
    set(get(gca,'ylabel'),'string',yl_text,'fontsize',24, 'fontname','Book Antiqua')
    set(gca,'fontsize',24,'fontname','Book Antiqua')  % set axis font size
    title('ROC Curves', 'FontSize', 24 , 'fontname','Book Antiqua');
    axis square
    box on
end

    AUC_Sal(1) = areaundercurve(FP_Frame(:,1)',TP_Frame(:,1)');
    AUC_Sal(2) = areaundercurve(FP_Frame(:,2)',TP_Frame(:,2)');
    AUC_Sal(3) = areaundercurve(FP_Frame(:,3)',TP_Frame(:,3)');
    AUC_Sal(4) = areaundercurve(FP_Frame(:,4)',TP_Frame(:,4)');
    AUC_Sal_op = [AUC_Sal(1) AUC_Sal(2) AUC_Sal(3) AUC_Sal(4)];

    for Print_loop = 1:4
        fprintf('Area Under ROC curve @ Seismic Section %d using AUC   is ==> %f \n', SS_UT_num(Print_loop)+Dataset_offset, AUC_Sal_op(Print_loop));
    end

    