function pts = pointOrder(bw)

[rows, cols] = size(bw);
% Coordinates of each point on the labeled boundary
bd = find(bw == 1);
[bdSub(:,1), bdSub(:,2)] = ind2sub([rows,cols],bd);

% Identify the beginning point of the labeled boundary
% Located at the left-bottom
[~, tmp_c] = ind2sub([rows, cols], find(bw(:) == 1));
tmp_c = tmp_c(1);
tmp_r = find(bw(:,tmp_c)==1, 1, 'last');
ptsLB = [tmp_r, tmp_c];

center = ptsLB;    % begins from the point on the left-bottom
bdPatchPts = [];
for i = 1:length(bd)

    diffPos = sum( abs( bdSub-repmat(center,size(bdSub,1),1) ),2 );
    
    if isempty(bdSub(diffPos == 1 | diffPos == 2,:))
        break; % to the end of the trace
    else
        nextPtsCandi = sortrows([bdSub(diffPos == 1 | diffPos == 2,:),...
        diffPos(diffPos == 1 | diffPos == 2)],3);
        nextPts = nextPtsCandi(1,1:2); % select the next center
        bdPatchPts = [bdPatchPts;nextPts];
    end
    
    center = nextPts;
    % Remove the processed point from bdSub
    bdSub(diffPos == 0,:) = [];
end
pts = bdPatchPts;