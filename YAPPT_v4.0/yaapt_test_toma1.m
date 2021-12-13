clc
clear all
close all

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Red ID      : 813817232
% % Date        : January 7, 2016
% % Description : This script tests the open source YAAPT algorithm for
% %               pitch tracking.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


% % Input Parameters
voiced_unvoiced = 1;          % Whether to make voiced/unvoiced decisions 
figure_display  = 0;          % Output the figures
speed_grade     = 1;          % 1 = Performance, 2 = Moderate, 3 = Speed
Prm = struct(...    'frame_length',   25, ... % Length of each analysis frame (ms)
    'frame_length',   35, ... % Length of each analysis frame (ms)
    'frame_lengtht',  35, ... % Length of each analysis frame (ms)
    'frame_space',    10, ... % Spacing between analysis frame (ms)
    'f0_min',         50, ... % Minimum F0 searched (Hz)
    'f0_max',        500, ... % Maximum F0 searached (Hz)
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

[samples, fs1] = audioread('sample/f1nw0000pes_short.wav');
tic
[pitch1, nf1] = yaapt(samples, fs1, voiced_unvoiced, Prm, figure_display, speed_grade);
toc
% pitch1 = ptch_fix(pitch1);
% toc
t = ( 0:length(samples)-1) ./ fs1;

figure;
subplot(2,1,1)
plot(t,samples)
subplot(2,1,2)
plot(pitch1)





