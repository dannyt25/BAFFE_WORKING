% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Red ID      : 813817232
% % Date        : January 12, 2019
% % Description : This script evaluates the accuracy of the YAAPT algorithm
% % with the Keele Database as a reference.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clearvars -except SNRZ SRAEN time_measure ERROR
close all

load '../../EE697/Keele/Speech/synched_keele_db.mat'

Tw=25.6e-3;
fs=20000;
fL=50;
fH=500;
st=10e-3;
Lw=fix(Tw*fs);
sth=.15;
Ength=0.1;
J=0.1;
Pth=0.1;

% % YAAPT Parameters
voiced_unvoiced = 1;          % Whether to make voiced/unvoiced decisions 
figure_display  = 0;          % Output the figures
speed_grade     = 1;          % 1 = Performance, 2 = Moderate, 3 = Speed
Prm = struct(...    'frame_length',   25, ... % Length of each analysis frame (ms)
    'frame_length',   Tw*1000, ... % Length of each analysis frame (ms)
    'frame_lengtht',  Tw*1000, ... % Length of each analysis frame (ms)
    'frame_space',    st*1000, ... % Spacing between analysis frame (ms)
    'f0_min',         fL, ... % Minimum F0 searched (Hz)
    'f0_max',         fH, ... % Maximum F0 searached (Hz)
    'fft_length',   8192, ... % FFT length
    'bp_forder',     150, ... % Order of bandpass filter
    'bp_low',         50, ... % Low frequency of filter passband (Hz)
    'bp_high',      1500, ... % High frequency of filter passband (Hz)
    'nlfer_thresh1',0.75, ... % NLFER boundary for voiced/unvoiced decisions
    'nlfer_thresh2', 0.1, ... % Threshold for NLFER definitely unvocied
    'shc_numharms',    3, ... % Number of harmonics in SHC calculation
    'shc_window',     40, ... % SHC window length (Hz)
    'shc_maxpeaks',    4, ... % Maximum number of SHC peaks to be found
    'shc_pwidth',     50, ... % Window width in SHC peak picking (Hz)
    'shc_thresh1',   5.0, ... % Threshold 1 for SHC peak picking
    'shc_thresh2',  1.25, ... % Threshold 2 for SHC peak picking
    'f0_double',     150, ... % F0 doubling decision threshold (Hz)
    'f0_half',       150, ... % F0 halving decision threshold (Hz)
    'dp5_k1',         11, ... % Weight used in dynaimc program
    'dec_factor',      1, ... % Factor for signal resampling
    'nccf_thresh1', 0.25, ... % Threshold for considering a peak in NCCF
    'nccf_thresh2',  0.9, ... % Threshold for terminating serach in NCCF
    'nccf_maxcands',   3, ... % Maximum number of candidates found
    'nccf_pwidth',     5, ... % Window width in NCCF peak picking
    'merit_boost',  0.20, ... % Boost merit
    'merit_pivot',  0.99, ... % Merit assigned to unvoiced candidates in
                          ... % defintely unvoiced frames
    'merit_extra',   0.4, ... % Merit assigned to extra candidates
                          ... % in reducing F0 doubling/halving errors
    'median_value',    7, ... % Order of medial filter
    'dp_w1',        0.15, ... % DP weight factor for V-V transitions
    'dp_w2',         0.5, ... % DP weight factor for V-UV or UV-V transitions
    'dp_w3',         0.1, ... % DP weight factor of UV-UV transitions
    'dp_w4',         0.9, ... % Weight factor for local costs
    'end', -1);

SNR_LENGTH = length(SNRZ);

% % Initialize Cells
PitchYAAPT=cell(10,SNR_LENGTH);
Pv=cell(10,1);

for k=1:10    
    Sig = speech_sv{1,k};

    Nstart=1;
    Nend=length(Sig);

    Pv{k,1} = ref_sv{1,k};
    Pv{k,1}(Pv{k,1}==-1)=0;
    Pv{k,1}(Pv{k,1}<0)=0;
%     Pv{k,1}=abs(Pv{k,1});
    Pv{k,1}=20000./Pv{k,1};
    Pv{k,1}(Pv{k,1}==Inf)=0;
    Pv{k,1}(Pv{k,1}<30) = NaN;

    %********************* Signal Preparation ********************
    for n = 1:SNR_LENGTH
        Sig = speech_sv{1,k};
        SNR = SNRZ(n);

        ESig=Sig'*Sig/length(Sig);
        Enoise=ESig/(10^(SNR/10));
        nois=sqrt(Enoise)*randn(Nend-Nstart+1,1);
        Sig_noisy=Sig+nois;
        
        if( SRAEN==1 )
            Sig_noisy = filtfilt(fir1(150,[300 3400].*2./fs),1,Sig_noisy);
        end
        
        Sig_noisy_norm=Sig_noisy/max(abs(Sig_noisy));       % Normalization
        
        %************** Pitch YAAPT *****************`**
        tic
        [pitch1, nf1] = yaapt(Sig_noisy_norm,fs,voiced_unvoiced,Prm,figure_display,speed_grade);
        PitchYAAPT{k,n} = ptch_fix(pitch1);
        time_measure = [time_measure toc];
        
    end
   
    L(k) = min([length(Pv{k,1}) length(PitchYAAPT{k,1})]);
end

PITCH_REF = [];
for i = 1:10
    Pv{i,1} = Pv{i,1}(:)';
    PITCH_REF = [PITCH_REF Pv{i,1}(1:L(i))];
end

PITCH_EST = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST{m,1} = [];
    for i = 1:10
        PITCH_EST{m,1} = [PITCH_EST{m,1} PitchYAAPT{i,m}(1:L(i))];
    end
end

for m = 1:SNR_LENGTH
    [GROSS_5(m),~,~]        = Gerr_DT( PITCH_REF, PITCH_EST{m,1}, 0.05 );
    [GROSS_20(m),~,FINE(m)] = Gerr_DT( PITCH_REF, PITCH_EST{m,1}, 0.2 );
end
