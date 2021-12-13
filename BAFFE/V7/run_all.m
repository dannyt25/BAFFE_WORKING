% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Date        : February 1, 2019
% % Description : This script runs and plots the error performance of the
% BAFFE and the YAAPT.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clc
clear all %#ok<*CLALL>
close all
% SNR Levels defined
SNRZ  = [Inf 35 30 25 20 15 10 5 0];
display('Running BAFFE') %#ok<*DISPLAYPROG>
run_baffe;
display('Running YAAPT')
SNRZ  = [Inf 35 30 25 20 15 10 5 0];
run_yaapt;
% display('Running Harvest')
% SNRZ  = [Inf 35 30 25 20 15 10 5 0];
% % run_harvest;
% display('Running Dio')
% SNRZ  = [Inf 35 30 25 20 15 10 5 0];
% % run_dio;
% display('Running SWIPE')
% SNRZ  = [Inf 35 30 25 20 15 10 5 0];
% % run_swipe;
% display('Running RAPT')
% SNRZ  = [Inf 35 30 25 20 15 10 5 0];
% run_rapt;
display('Plotting...')
plot_all;