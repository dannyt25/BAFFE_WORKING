% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Red ID      : 813817232
% % Date        : July 25, 2019
% % Description : This script evaluates the accuracy of the Harvest algorithm
% % with the Keele Database as a reference.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clearvars -except SNRZ SRAEN time_measure ERROR
close all

load '../../EE697/Keele/Speech/synched_keele_db.mat'

[babble_44_1,fs_44_1] = audioread('../Babble/Party.wav');
GCD = gcd(fs_44_1,20E+3);
babble = resample(babble_44_1,20E+3/GCD,fs_44_1/GCD);

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


SNR_LENGTH = length(SNRZ);

% % Initialize Cells
PitchHARVEST=cell(10,SNR_LENGTH);
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

        N_SPEECH = length(Sig);
        N_BABBLE = length(babble);
        N_START  = randi(N_BABBLE-N_SPEECH);
        N_END    = N_START+N_SPEECH-1;
        Sbab = babble(N_START:N_END);
        Ebab = var(Sbab);
        ESig=var(Sig);
        Enoise=ESig/(10^(SNR/10));
        nois=sqrt(Enoise/Ebab)*Sbab;
        Sig_noisy=Sig(:)+nois(:);
        
        if( SRAEN==1 )
            Sig_noisy = filtfilt(fir1(150,[300 3400].*2./fs),1,Sig_noisy);
        end
        
        Sig_noisy_norm=Sig_noisy/max(abs(Sig_noisy));       % Normalization
        
        %************** Pitch Harvest *****************`**
        tic
        pitch_harv = harvest(Sig_noisy_norm,fs);
        PitchHARVEST{k,n} = pitch_harv.f0(1:2:end);
        time_measure = [time_measure toc];
    end
   
    L(k) = min([length(Pv{k,1}) length(PitchHARVEST{k,1})]);
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
        PITCH_EST{m,1} = [PITCH_EST{m,1} PitchHARVEST{i,m}(1:L(i))];
    end
end

for m = 1:SNR_LENGTH
    [GROSS_5(m),~,~]        = Gerr_DT( PITCH_REF, PITCH_EST{m,1}, 0.05 );
    [GROSS_20(m),~,FINE(m)] = Gerr_DT( PITCH_REF, PITCH_EST{m,1}, 0.2 );
end
