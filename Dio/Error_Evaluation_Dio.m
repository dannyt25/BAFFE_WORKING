% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Red ID      : 813817232
% % Date        : July 25, 2019
% % Description : This script evaluates the accuracy of the DIO algorithm
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


SNR_LENGTH = length(SNRZ);

% % Initialize Cells
% % Initialize Cells
PitchBAFFE   = cell(10,SNR_LENGTH);
PitchDIO     = cell(10,SNR_LENGTH);
PitchSWIPE   = cell(10,SNR_LENGTH);
PitchRAPT    = cell(10,SNR_LENGTH);
PitchHARVEST = cell(10,SNR_LENGTH);
Pv=cell(10,1);

for k=1:10    
    display(num2str(k));
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
        option.f0_floor     = fL;
        option.f0_floor     = fH;
        
        %************** Pitch BAFFE ******************
        tic
        [PitchBAFFE{k,n}, E1] = BAFFE_6(Sig_noisy_norm,fs,Tw,st,fL,fH,...
                                        Ength,Pth,J,1,Pv{k,1});
        time_measure.BAFFE = [time_measure.BAFFE toc];
        
        %************** Pitch Dio ********************
        tic
        pitch_dio = Dio(Sig_noisy_norm,fs);
        PitchDIO{k,n} = pitch_dio.f0(1:2:end);
        time_measure.DIO = [time_measure.DIO toc];

        %************** Pitch RAPT *******************
        tic
        pitch_rapt = fxrapt(Sig_noisy_norm,fs,'u');
        PitchRAPT{k,n} = pitch_rapt(:)';
        time_measure.RAPT = [time_measure.RAPT toc];

        %************** Pitch SWIPE *******************
        tic
        pitch_swipe = swipep(Sig_noisy_norm,fs,[fL fH],0.01,[],1/20,156/256,0.2);
        PitchSWIPE{k,n} = pitch_swipe(:)';
        time_measure.SWIPE = [time_measure.SWIPE toc];

        %************** Pitch Harvest *****************`**
        tic
        pitch_harv = harvest(Sig_noisy_norm,fs);
        PitchHARVEST{k,n} = pitch_harv.f0(1:2:end);
        time_measure.HARV = [time_measure.HARV toc];
    end
   
    L(k,1) = min([length(Pv{k,1}) length(PitchBAFFE{k,1}) length(PitchDIO{k,1})]);
    L(k,2) = min([length(Pv{k,1}) length(PitchBAFFE{k,1}) length(PitchRAPT{k,1})]);
    L(k,3) = min([length(Pv{k,1}) length(PitchBAFFE{k,1}) length(PitchHARVEST{k,1})]);
    L(k,4) = min([length(Pv{k,1}) length(PitchBAFFE{k,1}) length(PitchSWIPE{k,1})]);
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Compare with Dio
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % Concatinate the Ref
PITCH_REF = [];
for i = 1:10
    Pv{i,1} = Pv{i,1}(:)';
    PITCH_REF = [PITCH_REF Pv{i,1}(1:L(i,1))];
end

% % Concatinate DIO Pitch tracks
PITCH_EST_DIO = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_DIO{m,1} = [];
    for i = 1:10
        PITCH_EST_DIO{m,1} = [PITCH_EST_DIO{m,1} PitchDIO{i,m}(1:L(i,1))];
    end
end

% % Concatinate BAFFE Pitch tracks
PITCH_EST_BAFFE = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_BAFFE{m,1} = [];
    for i = 1:10
        PITCH_EST_BAFFE{m,1} = [PITCH_EST_BAFFE{m,1} PitchBAFFE{i,m}(1:L(i,1))];
    end
end

for m = 1:SNR_LENGTH
    % % Generate a random sequence fomr 1 to the length of all tracks
    rand_vect = randperm(length(PITCH_EST_BAFFE{m,1} ));
    sel = zeros(1,length(rand_vect));
    count = 1;
    for nn = 1:length(rand_vect)
        if( count <= 1000 ) 
            if( PITCH_EST_DIO{m,1}(rand_vect(nn))>20 ) 
                sel(rand_vect(nn)) = 1;
                count = count+1;
            end
        end
    end

    [GROSS_5(1,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.05 );
    [GROSS_20(1,m),~,FINE(1,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.2 );
    [GROSS_5(2,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_DIO{m,1}(sel==1), 0.05 );
    [GROSS_20(2,m),~,FINE(2,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_DIO{m,1}(sel==1), 0.2 );
end


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Compare with RAPT
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % Concatinate the Ref
PITCH_REF = [];
for i = 1:10
    Pv{i,1} = Pv{i,1}(:)';
    PITCH_REF = [PITCH_REF Pv{i,1}(1:L(i,2))];
end

% % Concatinate DIO Pitch tracks
PITCH_EST_RAPT = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_RAPT{m,1} = [];
    for i = 1:10
        PITCH_EST_RAPT{m,1} = [PITCH_EST_RAPT{m,1} PitchRAPT{i,m}(1:L(i,2))];
    end
end

% % Concatinate BAFFE Pitch tracks
PITCH_EST_BAFFE = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_BAFFE{m,1} = [];
    for i = 1:10
        PITCH_EST_BAFFE{m,1} = [PITCH_EST_BAFFE{m,1} PitchBAFFE{i,m}(1:L(i,2))];
    end
end

for m = 1:SNR_LENGTH
    % % Generate a random sequence fomr 1 to the length of all tracks
    rand_vect = randperm(length(PITCH_EST_BAFFE{m,1} ));
    sel = zeros(1,length(rand_vect));
    count = 1;
    for nn = 1:length(rand_vect)
        if( count <= 1000 ) 
            if( PITCH_EST_RAPT{m,1}(rand_vect(nn))>20 ) 
                sel(rand_vect(nn)) = 1;
                count = count+1;
            end
        end
    end

    [GROSS_5(3,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.05 );
    [GROSS_20(3,m),~,FINE(4,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.2 );
    [GROSS_5(4,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_RAPT{m,1}(sel==1), 0.05 );
    [GROSS_20(4,m),~,FINE(4,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_RAPT{m,1}(sel==1), 0.2 );
end


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Compare with Harvest
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % Concatinate the Ref
PITCH_REF = [];
for i = 1:10
    Pv{i,1} = Pv{i,1}(:)';
    PITCH_REF = [PITCH_REF Pv{i,1}(1:L(i,3))];
end

% % Concatinate DIO Pitch tracks
PITCH_EST_HARV = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_HARV{m,1} = [];
    for i = 1:10
        PITCH_EST_HARV{m,1} = [PITCH_EST_HARV{m,1} PitchHARVEST{i,m}(1:L(i,3))];
    end
end

% % Concatinate BAFFE Pitch tracks
PITCH_EST_BAFFE = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_BAFFE{m,1} = [];
    for i = 1:10
        PITCH_EST_BAFFE{m,1} = [PITCH_EST_BAFFE{m,1} PitchBAFFE{i,m}(1:L(i,3))];
    end
end

for m = 1:SNR_LENGTH
    % % Generate a random sequence fomr 1 to the length of all tracks
    rand_vect = randperm(length(PITCH_EST_BAFFE{m,1} ));
    sel = zeros(1,length(rand_vect));
    count = 1;
    for nn = 1:length(rand_vect)
        if( count <= 1000 ) 
            if( PITCH_EST_HARV{m,1}(rand_vect(nn))>20 ) 
                sel(rand_vect(nn)) = 1;
                count = count+1;
            end
        end
    end

    [GROSS_5(5,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.05 );
    [GROSS_20(5,m),~,FINE(5,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.2 );
    [GROSS_5(6,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_HARV{m,1}(sel==1), 0.05 );
    [GROSS_20(6,m),~,FINE(6,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_HARV{m,1}(sel==1), 0.2 );
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Compare with SWIPE
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % Concatinate the Ref
PITCH_REF = [];
for i = 1:10
    Pv{i,1} = Pv{i,1}(:)';
    PITCH_REF = [PITCH_REF Pv{i,1}(1:L(i,4))];
end

% % Concatinate DIO Pitch tracks
PITCH_EST_SWIPE = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_SWIPE{m,1} = [];
    for i = 1:10
        PITCH_EST_SWIPE{m,1} = [PITCH_EST_SWIPE{m,1} PitchSWIPE{i,m}(1:L(i,4))];
    end
end

% % Concatinate BAFFE Pitch tracks
PITCH_EST_BAFFE = cell(SNR_LENGTH,1);
for m = 1:SNR_LENGTH
    PITCH_EST_BAFFE{m,1} = [];
    for i = 1:10
        PITCH_EST_BAFFE{m,1} = [PITCH_EST_BAFFE{m,1} PitchBAFFE{i,m}(1:L(i,4))];
    end
end

for m = 1:SNR_LENGTH
    % % Generate a random sequence fomr 1 to the length of all tracks
    rand_vect = randperm(length(PITCH_EST_BAFFE{m,1} ));
    sel = zeros(1,length(rand_vect));
    count = 1;
    for nn = 1:length(rand_vect)
        if( count <= 1000 ) 
            if( PITCH_EST_SWIPE{m,1}(rand_vect(nn))>20 ) 
                sel(rand_vect(nn)) = 1;
                count = count+1;
            end
        end
    end

    [GROSS_5(7,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.05 );
    [GROSS_20(7,m),~,FINE(7,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_BAFFE{m,1}(sel==1), 0.2 );
    [GROSS_5(8,m),~,~]          = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_SWIPE{m,1}(sel==1), 0.05 );
    [GROSS_20(8,m),~,FINE(8,m)] = Gerr_DT( PITCH_REF(sel==1), PITCH_EST_SWIPE{m,1}(sel==1), 0.2 );
end

