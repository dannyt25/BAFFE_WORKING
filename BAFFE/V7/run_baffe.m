% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Red ID      : 813817232
% % Date        : January 4, 2019
% % Description : This script evaluates the error performance of the BAFFE.
% %               Both studio quality and telephone quality signals are
% %               tested in the presense of white noise and babble noise.
% % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % RUNTIME ESTIMATE IS 10 Mins
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clearvars -except SNRZ
close all
time_measure = [];

%** First test studio quality signal with white noise**********************
SRAEN = 0;
display('Studio Quality, White Noise');
Error_Evaluation;

% Save error functions
ERROR.STUDIO_WHITE.GROSS5  = GROSS_5;
ERROR.STUDIO_WHITE.GROSS20 = GROSS_20;
ERROR.STUDIO_WHITE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

%** Test studio quality signal with babble noise***************************
SRAEN = 0; %#ok<*NASGU>
display('Studio Quality, Babble Noise');
Error_Babble_Evaluation;

% % Save error functions
ERROR.STUDIO_BABBLE.GROSS5  = GROSS_5;
ERROR.STUDIO_BABBLE.GROSS20 = GROSS_20;
ERROR.STUDIO_BABBLE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

%** Test telephone quality signal with white noise*************************
SRAEN = 1;
display('Telephone Quality, White Noise'); %#ok<*DISPLAYPROG>
Error_Evaluation;

% Save error functions
ERROR.TELE_WHITE.GROSS5  = GROSS_5;
ERROR.TELE_WHITE.GROSS20 = GROSS_20;
ERROR.TELE_WHITE.FINE    = FINE;
clearvars -except ERROR SNRZ SRAEN time_measure

%** Test telephone quality signal with babble noise************************
SRAEN = 1;
display('Telephone Quality, Babble Noise');
Error_Babble_Evaluation;

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
BAFFE_RESULTS  = ERROR;
% Calculate average time
BAFFE_AVG_TIME = mean(time_measure);

clearvars -except BAFFE_RESULTS BAFFE_AVG_TIME
% save baffe_error_eval.mat
