function sim_curve = SalSIM_cmpr(Ground_Truth,AC_Boundary )
% load Ground_Truth.mat
% load AC_Boundary.mat

Ground_Truth = bwperim(Ground_Truth);
AC_Boundary = bwperim(AC_Boundary);
AC_Boundary(end-1:end,:) = 0;


% addpath funcs

SS_GT = Ground_Truth;

[rows, cols] = size(SS_GT);

bdAll = bwboundaries(SS_GT);
bdPoints = bdAll{1};

gTruth = zeros(rows, cols);
for i = 1:length(bdPoints)
   gTruth(bdPoints(i,1), bdPoints(i,2)) = 1;
end
gTruth(end,:) = 0;
% figure,imshow(gTruth);

result = AC_Boundary;
result(end,:) = 0;
% figure,imshow(result);

% Trace all points of the salt-dome boundary in "gTruth"
pts_gt = pointOrder(gTruth);

% Trace all points of the salt-dome boundary in "result"
pts_dt = pointOrder(result);

dist = [];

% Compare the segments of salt-dome boundaries
len = 20; % Number of points in each segment of pts_gt

for i = 1+round(len/2):len/2:length(pts_gt)-round(len/2)


    seg1 = pts_gt(i-round(len/2):i+round(len/2),:);

    % According to the beginning and ending points of seg1 to determine the
    % beginning and ending points of seg2
    [~, seg2_beginIdx] = min(sum(abs(pts_dt - repmat(seg1(1,:), length(pts_dt), 1)), 2));
    [~, seg2_endIdx] = min(sum(abs(pts_dt - repmat(seg1(end,:), length(pts_dt), 1)), 2));

    maxIdx = max(seg2_beginIdx, seg2_endIdx);
    minIdx = min(seg2_beginIdx, seg2_endIdx);
    seg2 = pts_dt(minIdx:maxIdx,:);
    
    % Calculate the Frechet Distance between seg1 and seg2
    dist = [dist; DiscreteFrechetDist(seg1, seg2)];
end

%%

% Distance between the beginning points of "gTruth" and "result"
[Row_gt, Col_gt] = ind2sub([rows, cols], find(gTruth(:) == 1));
beginCol_gt = Col_gt(1);
beginCols_gt = find(Col_gt == beginCol_gt);
beginRow_gt = Row_gt(beginCols_gt(end));
endRow_gt = Row_gt(end);
endCol_gt = Col_gt(end);
lengthCol_gt = endCol_gt - beginCol_gt + 1;

% Distance between the ending points of "gTruth" and "result"
[Row_dt, Col_dt] = ind2sub([rows, cols], find(result(:) == 1));
beginCol_dt = Col_dt(1);
beginCols_dt = find(Col_dt == beginCol_dt);
beginRow_dt = Row_dt(beginCols_dt(end));
endRow_dt = Row_dt(end);
endCol_dt = Col_dt(end);
lengthCol_dt = endCol_dt - beginCol_dt + 1;

distBegin = sqrt((beginRow_gt - beginRow_dt).^2 + (beginCol_gt - beginCol_dt).^2);
distEnd = sqrt((endRow_gt - endRow_dt).^2 + (endCol_gt - endCol_dt).^2);

lambda_Begin = abs((beginCol_gt - beginCol_dt + 1))/lengthCol_gt;
lambda_End = abs((endCol_dt - endCol_gt +  1))/lengthCol_gt;

% Statistical results of the distances between segments
distMean = mean(dist);
distStd = std(dist);
distMax = max(dist);
penalty = distBegin*lambda_Begin + distEnd*lambda_End;

%%
alpha = 0.01;
beta = 0.003;

alpha = 0.006;
beta = 0.0015;

idx1 = exp(-alpha*(distMean+distStd));
idx2 = exp(-beta*(distMax+penalty));
idx = exp(-alpha*(distMean + distStd)-beta*(distMax + penalty));
distAll = distMax;

sim_curve = idx;





