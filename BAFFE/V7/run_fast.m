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
SNRZ  = [30 0];

display('Running BAFFE') %#ok<*DISPLAYPROG>
run_baffe;
% display('Running YAAPT')
% run_yaapt;
display('Plotting...')
% plot_all;