function [Ftrack,Prob]=BAFFE_7(signal,fs,Tw,st,fL,fH,Ength,Pth,J)
% *****************************************************************************
% The BAFFE_6 function tracks the pitch or fundemental frequency of a
% signal. It utlizes the NACF to generate pitch candidates and an optimized,
% streaming algorithm for selecting the pitch track.
% 
%
% Inputs:
% signal    :  Input Signal
% fs        :  Sampling frequency (Hz)
% Tw        :  Window's length (sec)
% st        :  Window's Frame step (sec)
% fL        :  Smallest searched F0 (Hz)
% fH        :  Largest searched F0 (Hz)
% Ength     :  Minimum energy threshold for V/U decision(typical value : 0.1)
% Pth       :  Autocorrelation peak threshold (typical value : 0.1)
% J         :  Maximum allowable transition cost
%
% Outputs:
% Ptrack    :  Pitch track
% Prob      :  Confidence
%
%
%  SDSU Signal Processing Research Lab
%  Danny Toma, 06/27/2019
%  Ashkan Ashrafi, 7/21/2015
%
%
% *****************************************************************************

signal=signal(:);
% ************* Parameters ****************************************************
Lw=fix(Tw*fs);            % Discrete length of Window
sw=fix(st*fs);            % Discrete length of step
NN=length(signal);        % The length of the signal
Ns=fix((NN-Lw)/sw);       % Number of frames in the signal
Nfreqs=6;                 % Number of frequency candidates per frame

% ************* Variable Initialization ***************************************
Freqs1=zeros(Nfreqs,Ns);
Score1=zeros(Nfreqs,Ns);

% ************* Pre Filtering *************************************************
% A 100th order FIR filter with a cutoff frequency of 3 times the highest
% searchable frequency. The filter uses a gausian window.
Nfil=100;                           % Filter Order
Wind=gausswin(Nfil+1);              % Window Type
h_gaus=fir1(Nfil,3*fH/(fs/2),Wind); % Filter Generated
X=filtfilt(h_gaus,1,signal);        % Zero phase filter implementation

% % Scale input signal
X=X/max(abs(X));

% ************* Energy Track **************************************************
hfir=fir1(100,[fL/(fs/2) 3.*fH/(fs/2)],'band');
EngFi=SegEng(signal,sw,Lw,Ns,hfir);

% An Adjustable threshold is computed based on the minimum of EngFi
Ength_adj = Ength+2*min(EngFi);

% ************* Probability of Voicing ****************************************
Eng_clip = EngFi;
% Clip the energy signal and normalize
Eng_clip(Eng_clip>Ength_adj) = Ength_adj;
Eng_clip = Eng_clip'./Ength_adj;
E_vuv = log2(1+Eng_clip);
E_vuv = ( E_vuv - min(E_vuv) )./( max(E_vuv) - min(E_vuv) );

% ************* Initialize Weighted Histogram *********************************
ff_hist = (fL+0.5):(fH-1);
ss_hist = zeros(1,length(ff_hist));

% ************* Initialize a Smoothing Filter *********************************
% This FIR filter is used to smooth the ACF for peak detection
h_nacf = fir1(24,4*fH/(fs/2));

% ************* Fundamental Frequency Candidate Selection *********************
for m=1:Ns
    % Perform Normalized Autocorrelation Function and find peaks
    [corT,~,CorPP]=nacf_peak_det(X((m-1)*sw+1:(m-1)*sw+Lw),Lw-1,ones(1,Lw),1,h_nacf);
    corT  = corT(:);
    CorPP = CorPP(:);

    % Extract the Scores
    Merit=corT(CorPP);

    % Proceed to next iteration if there are no peaks found
    if length(CorPP)<1
        Score1(:,m)=zeros(Nfreqs,1);
        Freqs1(:,m)=zeros(Nfreqs,1);
        continue;
    end

    % Subtract to account for Matlab indexing
    CorPP = CorPP - 1;
    % Select peaks between lag of fL and lag of fh. Also, the
    % peak must be above the peak threshold
    Sel=CorPP < fs/fL & CorPP > fs/fH & Merit > Pth;

    % Convert lag to frequency
    F_CAND=fs./CorPP(Sel);

    Sc=Merit(Sel);
    Sc=Sc(:);
    F_CAND=F_CAND(:);

    if length(F_CAND)>=1
        % % Sort candidates by peak
        [Sco,Is]=sort(Sc(:),'descend');

        % % Truncate  Frequency and Score Matricies
        % % if more than Nfreqs are detected
        if length(Is)>=Nfreqs
            Le=Nfreqs;
        else
            Le=length(Is);
        end
        Score1(:,m)=[Sco(1:Le);zeros(Nfreqs-Le,1)];
        Freqs1(:,m)=[F_CAND(Is(1:Le));zeros(Nfreqs-Le,1)];
    else
        Score1(:,m)=zeros(Nfreqs,1);
        Freqs1(:,m)=zeros(Nfreqs,1);
    end
    
    % % Generate histogram of Frequency Candidates
    for ii = 1:1
        if( Freqs1(ii,m)~=0 )
            if( EngFi(m) >= Ength_adj )
                f_ii = fix(Freqs1(ii,m)) == (ff_hist-0.5);
                ss_hist(f_ii) = ss_hist(f_ii) + Score1(ii,m);
            end
        end
    end
    
    % Perform the "weighted" aspect of the Weighted Autocorrelation ON DISCRETE SAMPLES
    sel_cand = Score1(:,m)~=0;
    Score1(sel_cand,m) = Score1(sel_cand,m).*...
	                     (Lw./(Lw - fs./Freqs1(sel_cand,m)));
    % Clip WACF for values greater than 1
    Score1(Score1(sel_cand,m)>1,m) = 1;   
end


% ************* Adjust Scores based on histogram ******************************
% Smooth the histogram and find the peak
[~,m_fcand]      = max(medfilt1(ss_hist,10));
Score1(Score1>0) = Score1(Score1>0).*(1-0.5.*abs(ff_hist(m_fcand) - Freqs1(Score1>0))./ff_hist(m_fcand));
Score1(Score1<=0) = 0;
Freqs1(Score1==0) = 0;

% ************* Remove calculated Zero scores *********************************
[~,I_RESORT] = sort(Score1>0,'descend');
for m = 1:Ns
    Score1(:,m) = Score1(I_RESORT(:,m),m);
    Freqs1(:,m) = Freqs1(I_RESORT(:,m),m);
end
% ************* Find Onset and Offset Frames **********************************
[Onsetf,Offsetf]=ood(EngFi >= Ength_adj);

% % Initialize frame and score tracks
Frame_track = cell(1,length(Onsetf));
Score_frame = cell(1,length(Onsetf));
JMP         = cell(1,length(Onsetf));
          
% ************* Pitch Tracking ************************************************
for k=1:length(Onsetf)
    % ******* Insert segmented windows for tracks *****************************
    FFss=Freqs1(:,Onsetf(k):Offsetf(k));
    SCss=Score1(:,Onsetf(k):Offsetf(k));

    % ******* Generate a weighted function from energy track ******************
    Ess = exp_weighted_func(E_vuv(Onsetf(k):Offsetf(k)));
    [~,C_E] = max(Ess);
    
    if(length(C_E) > 1)
        C_E = C_E(1);
    end

    % ******* Find all possible frame tracks **********************************
    [Frame_track{k},Score_frame{k},JMP{k}]= find_frame_track_euclidean(FFss,SCss,J,C_E);    

    % ******* Find the track with the greatest merit **************************
    ftrack_est(Onsetf(k):Offsetf(k))=Frame_track{k};

    % ******* Store the Probability of Voicing ********************************
    Prob(Onsetf(k):Offsetf(k))=Score_frame{k};
    EMPTY_FRAME(Onsetf(k):Offsetf(k)) = JMP{k};
end

% ******* Interpolate Unreliable Frames ***************************************
EMPTY_FRAME = conv(~EMPTY_FRAME,[1 1 1]);
EMPTY_FRAME = ~(EMPTY_FRAME(2:end-1) >= 3);
n1 = 1:length(EMPTY_FRAME);
ftrack_est = ftrack_est(:);EMPTY_FRAME=EMPTY_FRAME(:);n1=n1(:);
fsmooth = interp1(n1(~EMPTY_FRAME),ftrack_est(~EMPTY_FRAME),n1,'linear');
fsmooth(isnan(fsmooth)) = mean(ftrack_est);
% Filter the linearly interpolated signal
fsmooth = filtfilt(fir1(20,0.1),1,fsmooth);
ftrack_est = ftrack_est(:);fsmooth = fsmooth(:);EMPTY_FRAME=EMPTY_FRAME(:);
ftrack_est(~EMPTY_FRAME) = fsmooth(~EMPTY_FRAME);

Ftrack = ftrack_est(:)';

% *****************************************************************************
% ******************************* FUNCTIONS ***********************************
% *****************************************************************************
 function [TR,SCO,JFRM]=find_frame_track_euclidean(FF,SC,Jump,C_E)
% This function finds the lowest cost frequency track. Formally, it is where the
% Dual-Path Pitch Selection (DPPS) process occurs.
%
% INPUTS:
% FF       :   Frequency matrix (Each column has frequencies of each frame
% SC       :   Scores of the frequencies in freq matrix
% Jump     :   Maximum frequency jump allowed
% EE       :   Energy Track (Scaled from 0 to 1)
% OUTPUT:
%
% TR       :   The selected tracks
% SCO      :   Scores of the selected tracks
% JFRM     :   Jumped Frames
%
%
% By Ashkan Ashrafi
% 7/21/2015
% San Diego, CA
%
% Updated 02/05/2019
% Danny Toma
% Changed the tracking cost to the euclidean distance.

% Initialize Matricies
[~,M]=size(FF);
TR=zeros(1,M);
SCO=zeros(1,M);
JFRM = ones(1,M);

p=C_E;
TR(p)=FF(1,p);
SCO(p)=SC(1,p);

% Forward Loop
for r=p:M-1
    % Calculate the percentage difference between the
    % current cartesian point, and the forward looking points.
    f_err = abs((FF(:,r+1)-TR(r))./(TR(r)+eps));
    % Calculate the normalized euclidean distance
    euc_dist = sqrt(f_err.^2)./(SC(:,r+1)+eps);
    euc_dist(FF(:,r+1) == 0) = max(euc_dist);

    if min(euc_dist) < Jump
        % Find the minimum cost from the current point
        F_ind=find(euc_dist==min(euc_dist),1,'first');
        TR(r+1) =FF(F_ind,r+1);
        SCO(r+1)=SC(F_ind,r+1);
    else
        % Assign the previous frequency, but with a score of zero
        TR(r+1)=TR(r);
        SCO(r+1)=SCO(r).*0.5;
        JFRM(r+1) = 0;
    end
end

% Backward Loop
for r=p:-1:2
    % Calculate the percentage difference between the
    % current cartesian point, and the backward looking points.
    f_err = abs((FF(:,r-1)-TR(r))./(TR(r)+eps));
    % Calculate the normalized euclidean distance
    euc_dist = sqrt(f_err.^2)./(SC(:,r-1)+eps);
    euc_dist(FF(:,r-1) == 0) = max(euc_dist);

    if min(euc_dist) < Jump
        % Find the minimum cost from the current point
        F_ind=find(euc_dist==min(euc_dist),1,'first');
        TR(r-1)=FF(F_ind,r-1);
        SCO(r-1)=SC(F_ind,r-1);
    else
        % Assign the previous frequency, but with a score of zero
        TR(r-1)=TR(r);
        SCO(r-1)=SCO(r).*0.5;
        JFRM(r-1) = 0;
    end
end

% Scale based on seed frame
SCO   = SCO;


function [E_GAUS,I] = exp_weighted_func(ENG_INPUT)
% Generates an exponentially weighted function (as a gausian) with the
% center located at the point in which the mean occurs of a given segment
% of speech.
%
% INPUTS:
% ENG_INPUT : Energy Track
%
% E_GAUS    : Gausian, exponentially weighted function
% I         : Index for center of E_GAUS

% Normalize the energy
e_hist = ENG_INPUT./sum(ENG_INPUT);

% Compute the weighted average of the frame index
L_E = length(e_hist);
e_mean = e_hist(:)'*(1:L_E)';

% Compute the spread of the gausian function
if( e_mean < (L_E+1)/2 )
   e_sigma = sqrt(-(1-e_mean)^2./(2.*log(0.1)));
else
   e_sigma = sqrt(-(L_E-e_mean)^2./(2.*log(0.1)));
end 

% generate the gausian function
e_n = 1:L_E;
I = round(e_mean);
if( (I<1) || (I>L_E) )
    I = 1;
end
E_GAUS = exp(-((e_n-e_mean)./(sqrt(2).*e_sigma)).^2);

function EngFi=SegEng(x,sw,Lw,Ns,hfir)
% Finds the energy of each segment of the signal
%
% Inputs :
% x      :  The signal of the segment
% sw     :  Frame step in samples
% Lw     :  Frame length in samples
% Ns     :  Number of frames
% hfir   :  Band-pass filter impulse response
%           
% Outputs:  
% EngFi  :  Energy Ratio
%
% By Ashkan Ashrafi
% 7/21/2015
% San Diego, CA

% Initialze vectors
Eng=zeros(Ns,1);
Eng_filtered_ratio=zeros(Ns,1);

% Perform a median filter
x = medfilt1(x,10);

% Loop for each frame
for m=1:Ns
    z=x((m-1)*sw+1:(m-1)*sw+Lw);
    z=z-mean(z);
    zh=filter(hfir,1,z);
    Eng(m)=z'*z;
    Eng_filtered_ratio(m)=(zh'*zh);
end

% Compute the energy ratio
EngFi=Eng_filtered_ratio/mean(Eng_filtered_ratio);
EngFi=EngFi(:);

function [Onset,Offset]=ood(eng)
% The function finds the onset and offsets of the segments for pitch
% extraction.
%
% By Ashkan Ashrafi
% 7/21/2015
% San Diego, CA
% 
% Modified by Danny Toma - 7/03/2018

% Find potential onsets and offsets
eng = eng(:)';
% Remove utterances that are less than 3 frames
eng = conv(eng,[1 1 1]);
eng = eng(2:end-1)>=3;
% % Calcuate rising and falling edges of the energy track
B_engs=diff([0 uint8(eng)]>0);
Ons=find(B_engs==1);
Of=find(B_engs==-1)-1;

% Initialize loop variables
Onset  = zeros(1,length(Of));
Offset = zeros(1,length(Of));

% First onset is ALWAYS the first frame
Onset(1) = 1;
for ii = 1:(length(Of)-1)
    % Define the width of a frame as the center of the unvoiced region.
    % This way, we can encapsulate the voiced segment.
    Offset(ii)  = fix( (Of(ii)+Ons(ii+1))./2 );
    Onset(ii+1) = Offset(ii) + 1;
end
% Final offset is ALWAYS the last frame
Offset(end) = length(eng);

function [xcn,scl,peakz]=nacf_peak_det(X,M,W_IN,ZERO_MEAN,H)
% This function finds the NACF of a single window. Then, it
% Finds and returns the local maxima of the frame. A smoothing
% function is applied to prevent the detection of false peaks.
%
% Inputs :
% X         :  Signal Input
% M         :  Maximum delay
% W_IN      :  Window to use with ACF (must be N elements)
% ZERO_MEAN :  Remove DC Offset
% H         :  Smoothing filter for peak detection
%           
% Outputs:  
% xcn       :  Normalized ACF
% scl       :  Scale (or Energy)
% peakz     :  Peak Indicies

% DC can be removed
X=X(:);
if ZERO_MEAN == 1
    x=X-mean(X);
else
    x = X;
end

% Init the length of the frame
N=length(x);

% When no window is provided, use a rect window
if nargin < 3
   w=rectwin(N);
else
   w = W_IN;
end

if length(w) ~= N
    error('Length of Window is differernt than length of input signal');
end

% Calculate the required length of FFT.
Nfft=2^fix(log2(N)+1);

% Compute FFT, IFFT, and scale.
XF=fft(x,Nfft);
xc=ifft(XF.*conj(XF));
scl = xc(1);
xcn=xc(1:M)/xc(1);
% xcn1 = filtfilt(xcn,1,H);

% Smooth the NACF
xcn1 = conv(xcn,H);
xcn1 = xcn1(((length(H)-1)/2):(end-(length(H)-1)/2));

% Detect the selected peaks
x_diff = [0 diff(xcn1(:)')] > 0;
selz = diff(x_diff)==-1;
n1 = 1:M;
peakz = n1(selz);



