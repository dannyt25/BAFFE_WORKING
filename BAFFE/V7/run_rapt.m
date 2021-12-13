% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Red ID      : 813817232
% % Date        : July 25, 2019
% % Description : This script evaluates the error performance of RAPT.
% %               Both studio quality and telephone quality signals are
% %               tested in the presense of white noise and babble noise.
% % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


clearvars -except SNRZ
time_measure = [];
close all

%** First test studio quality signal with white noise**********************
SRAEN = 0;
display('Studio Quality, White Noise');
run ../../RAPT/Error_Evaluation_RAPT;

% Save error functions
ERROR.STUDIO_WHITE.GROSS5  = GROSS_5;
ERROR.STUDIO_WHITE.GROSS20 = GROSS_20;
ERROR.STUDIO_WHITE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

%** Test studio quality signal with babble noise***************************
SRAEN = 0; %#ok<*NASGU>
display('Studio Quality, Babble Noise');
run ../../RAPT/Error_Babble_Evaluation_RAPT;

% % Save error functions
ERROR.STUDIO_BABBLE.GROSS5  = GROSS_5;
ERROR.STUDIO_BABBLE.GROSS20 = GROSS_20;
ERROR.STUDIO_BABBLE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

%** Test telephone quality signal with white noise*************************
SRAEN = 1;
display('Telephone Quality, White Noise'); %#ok<*DISPLAYPROG>
run ../../RAPT/Error_Evaluation_RAPT;

% Save error functions
ERROR.TELE_WHITE.GROSS5  = GROSS_5;
ERROR.TELE_WHITE.GROSS20 = GROSS_20;
ERROR.TELE_WHITE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

%** Test telephone quality signal with babble noise************************
SRAEN = 1;
display('Telephone Quality, Babble Noise');
run ../../RAPT/Error_Babble_Evaluation_RAPT;

% % Save error functions
ERROR.TELE_BABBLE.GROSS5  = GROSS_5;
ERROR.TELE_BABBLE.GROSS20 = GROSS_20;
ERROR.TELE_BABBLE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

% Store Run Times
ERROR.TIMES = time_measure;
% Store SNR values used
ERROR.SNRZ  = SNRZ;
% Rename results struct
RAPT_RESULTS  = ERROR;
% Calculate average time
RAPT_AVG_TIME = mean(time_measure);

clearvars -except RAPT_RESULTS RAPT_AVG_TIME
save rapt_error_eval.mat
