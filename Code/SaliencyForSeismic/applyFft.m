function dataF=applyFft(data,wsize_s,wsize_t)
%
% Compute 3-D FFT using non-overlapping windows
%
% dataF: 3-D FFT results
%
% data: video sequence data
% wsize_s: window size in x and y directions
% wsize_t: window size in t direction
%
%% Start of program
[M,N,T]=size(data);
hw_s=(wsize_s-1)/2;
hw_t=(wsize_t-1)/2;
szR=length(1:wsize_s:M);
szC=length(1:wsize_s:N);
dataF{1}=zeros(szR,szC,T,'single'); % Temporal component
dataF{2}=zeros(szR,szC,T,'single'); % Spatial component

% Mirror reflection for border condition; no overlapping in x and y
data1=EdgeMirror3(data,[0,0,hw_t]);

% Calculate weights according to spectral location
weightT=zeros(wsize_s,wsize_s,wsize_t,'single');
weightS=zeros(wsize_s,wsize_s,wsize_t,'single');
for i=1:wsize_s
    for j=1:wsize_s
        for k=1:wsize_t
            i0=i-1-hw_s;
            j0=j-1-hw_s;
            k0=k-1-hw_t;
            tmp=sqrt(i0^2+j0^2+k0^2);
            if tmp==0
                % Spectral center (i0=j0=k0=0) being DC value, discard
                weightT(i,j,k)=0;
                weightS(i,j,k)=0;
            else
                % Spectral value is to be divided between the components
                % according to its location in the spectrum
                weightT(i,j,k)=abs(k0/tmp);
                weightS(i,j,k)=sqrt(i0^2+j0^2)/tmp;
            end
        end
    end
end

for k=1:T
    i0=1;
    for i=1:wsize_s:M-wsize_s
        j0=1;
        for j=1:wsize_s:N-wsize_s
%             disp(['i: ' num2str(i) ' j: ' num2str(j) ' k: ' num2str(k)...
%                 ' M: ' num2str(M) ' N: ' num2str(N) ' T: ' num2str(T)]);
            % Prepare data cubes and apply 3D fft
            dataCube=data1(i:i+wsize_s-1,j:j+wsize_s-1,k:k+wsize_t-1);
            specCube=fftshift(fftn(dataCube));

            % Characterize spatial and temporal components
            specT=abs(specCube.*weightT); 
            specS=abs(specCube.*weightS);
            specTM=mean(specT(:));
            specSM=mean(specS(:));
            
            % Save spectral data
            dataF{1}(i0,j0,k)=specTM;
            dataF{2}(i0,j0,k)=specSM;
            
            j0=j0+1;
        end
        i0=i0+1;
    end
    
    % Normalize to range 0-1 for each frame
    tmp=dataF{1}(:,:,k);
    dataMax=max(tmp(:));
    dataMin=min(tmp(:));
    if dataMax==dataMin % Make sure not to divide by zero
        display(['applyFft.m: dataF{1}: k=' num2str(k) ', dataMax-dataMin=0']);
        dataF{1}(:,:,k)=tmp-dataMin;
    else        
        dataF{1}(:,:,k)=(tmp-dataMin)/(dataMax-dataMin);
    end
    
    tmp=dataF{2}(:,:,k);
    dataMax=max(tmp(:));
    dataMin=min(tmp(:));
    if dataMax==dataMin % Make sure not to divide by zero
        display(['applyFft.m: dataF{2}: k=' num2str(k) ', dataMax-dataMin=0']);
        dataF{2}(:,:,k)=tmp-dataMin;
    else        
        dataF{2}(:,:,k)=(tmp-dataMin)/(dataMax-dataMin);
    end
end
%% End of program
