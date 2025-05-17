% Exercise 3.19 Solution
% Student Name: Ahmed G. A. Qaddoura
% Student ID: 120234321
% Date: May 2025
% MATLAB Version: R2025a

% Clear workspace and close all figures
clear; clc; close all;

% Create necessary directories
if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('figures', 'dir'), mkdir('figures'); end

% Define parameters
Fs = 10000;  % Sampling frequency (10 kHz)

% Load the speech data
matfile = 'data/ex3M2.mat';
if ~exist(matfile, 'file')
    fprintf('Error: ex3M2.mat file not found in the data folder.\n');
    return;
end

% Add data path and load audio
addpath('data');
load(matfile, 'we_be_10k');
y = double(we_be_10k(:));  % Ensure column vector
N = length(y);

% Uncomment to listen to the audio
% sound(y, Fs);

%% Part A: Create spectrograms with different parameters

% Spectrogram creation function
function create_spectrogram(signal, fs, window_dur_ms, frame_dur_ms, title_str, filename_base)
    % Convert durations to samples
    win_samples = round(window_dur_ms * fs / 1000);
    frame_samples = round(frame_dur_ms * fs / 1000);
    
    % Create and save spectrogram
    figure;
    spec = specgram_hw3p20(signal, win_samples, frame_samples, fs);
    sgtitle(title_str, 'FontSize', 12);
    saveas(gcf, ['figures/' filename_base '.png']);
    saveas(gcf, ['figures/' filename_base '.fig']);
end

% Generate spectrograms with different parameters
create_spectrogram(y, Fs, 20, 1, 'Spectrogram with 20 ms Window / 1 ms Frame (Narrowband)', 'spectrogram_20ms_1ms');
create_spectrogram(y, Fs, 5, 1, 'Spectrogram with 5 ms Window / 1 ms Frame (Wideband)', 'spectrogram_5ms_1ms');
create_spectrogram(y, Fs, 30, 1, 'Spectrogram with 30 ms Window / 1 ms Frame (Very Narrowband)', 'spectrogram_30ms_1ms');
create_spectrogram(y, Fs, 3, 1, 'Spectrogram with 3 ms Window / 1 ms Frame (Very Wideband)', 'spectrogram_3ms_1ms');
create_spectrogram(y, Fs, 20, 5, 'Spectrogram with 20 ms Window / 5 ms Frame', 'spectrogram_20ms_5ms');
create_spectrogram(y, Fs, 3, 0.5, 'Spectrogram with 3 ms Window / 0.5 ms Frame Interval', 'spectrogram_3ms_0.5ms');
create_spectrogram(y, Fs, 30, 5, 'Spectrogram with 30 ms Window / 5 ms Frame Interval', 'spectrogram_30ms_5ms');

%% Part B: VOT Modification - Change voiced plosive "b" to approach "p"

% Separate "we" and "be" segments (boundary at ~0.9s)
be_start_idx = round(0.9 * Fs);
we = y(1:be_start_idx-1);
be = y(be_start_idx:end);

% Visualize the "be" segment
figure;
subplot(2,1,1);
plot((0:length(be)-1)/Fs, be);
title('Waveform of "be"');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

% Create spectrogram of "be"
subplot(2,1,2);
win_samples_be = round(5 * Fs / 1000);    % 5 ms window
frame_samples_be = round(1 * Fs / 1000);  % 1 ms frame
specgram_hw3p20(be, win_samples_be, frame_samples_be, Fs);
sgtitle('Waveform and Spectrogram of "be" (5 ms Window)');
saveas(gcf, 'figures/be_waveform_and_spectrogram.png');
saveas(gcf, 'figures/be_waveform_and_spectrogram.fig');

% Visualize the "be" segment for burst and voice onset identification
figure;
plot((0:length(be)-1)/Fs, be);
title('Select burst and voice onset points in "be"');
xlabel('Time (s)');
[time_points, ~] = ginput(2);  % User selects two points
burst_idx = round(time_points(1) * Fs);
voice_onset_idx = round(time_points(2) * Fs);

% Increase VOT by adding silence between burst and voice onset
vot_increase = 0.03; % 30ms
silence_samples = round(vot_increase * Fs);
be_modified = [be(1:burst_idx); zeros(silence_samples,1); be(voice_onset_idx:end)];

% Create enhanced version with pre-voicing removal
be_enhanced = be_modified;
pre_voicing_end = burst_idx - round(0.02 * Fs); % Estimate pre-voicing area (20ms before burst)
if pre_voicing_end < 1
    pre_voicing_end = 1;
end
be_enhanced(1:pre_voicing_end) = 0; % Remove pre-voicing

% Save audio files
audiowrite('data/be_original.wav', be, Fs);
audiowrite('data/be_modified.wav', be_modified, Fs);
audiowrite('data/be_enhanced.wav', be_enhanced, Fs);

% Compare original and modified waveforms
figure;
subplot(3,1,1);
plot((0:length(be)-1)/Fs, be);
title('Original "be" Waveform (voiced /b/)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(3,1,2);
plot((0:length(be_modified)-1)/Fs, be_modified);
title('Modified "be" with Increased VOT (approaching /p/)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot((0:length(be_enhanced)-1)/Fs, be_enhanced);
title('Enhanced "pe" with Pre-voicing Removal');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

saveas(gcf, 'figures/be_comparison.png');
saveas(gcf, 'figures/be_comparison.fig');

% Compare spectrograms
figure;
subplot(3,1,1);
specgram_hw3p20(be, win_samples_be, frame_samples_be, Fs);
title('Original "be" Spectrogram (voiced /b/)');

subplot(3,1,2);
specgram_hw3p20(be_modified, win_samples_be, frame_samples_be, Fs);
title('Modified "be" Spectrogram with Increased VOT');

subplot(3,1,3);
specgram_hw3p20(be_enhanced, win_samples_be, frame_samples_be, Fs);
title('Enhanced "pe" Spectrogram with Pre-voicing Removal');

saveas(gcf, 'figures/be_spectrogram_comparison.png');
saveas(gcf, 'figures/be_spectrogram_comparison.fig');

%% Part C: Phoneme Swapping - Interchange "b" and "w"

% Identify phoneme boundary for /w/ in "we"
figure; plot((0:length(we)-1)/Fs, we); title('Select end of /w/ in "we"');
[w_end_time, ~] = ginput(1);
w_end_idx = round(w_end_time * Fs);

% Identify phoneme boundary for /b/ in "be"
figure; plot((0:length(be)-1)/Fs, be); title('Select end of /b/ in "be"');
[b_end_time, ~] = ginput(1);
b_end_idx = round(b_end_time * Fs);

% Swap phonemes using precise boundaries
we_to_be = [be(1:b_end_idx); we(w_end_idx+1:end)];
be_to_we = [we(1:w_end_idx); be(b_end_idx+1:end)];

% Save swapped audio
audiowrite('data/we_to_be.wav', we_to_be, Fs);
audiowrite('data/be_to_we.wav', be_to_we, Fs);

% Compare original and swapped waveforms
figure;
subplot(2,2,1);
plot((0:length(we)-1)/Fs, we);
title('Original "we" Waveform');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,2,2);
plot((0:length(be)-1)/Fs, be);
title('Original "be" Waveform');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,2,3);
plot((0:length(we_to_be)-1)/Fs, we_to_be);
title('"we" to "be" Waveform');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,2,4);
plot((0:length(be_to_we)-1)/Fs, be_to_we);
title('"be" to "we" Waveform');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;
saveas(gcf, 'figures/swapped_waveforms.png');
saveas(gcf, 'figures/swapped_waveforms.fig');

% Compare spectrograms
figure;
subplot(2,2,1);
specgram_hw3p20(we, win_samples_be, frame_samples_be, Fs);
title('Original "we" Spectrogram');

subplot(2,2,2);
specgram_hw3p20(be, win_samples_be, frame_samples_be, Fs);
title('Original "be" Spectrogram');

subplot(2,2,3);
specgram_hw3p20(we_to_be, win_samples_be, frame_samples_be, Fs);
title('"we" to "be" Spectrogram');

subplot(2,2,4);
specgram_hw3p20(be_to_we, win_samples_be, frame_samples_be, Fs);
title('"be" to "we" Spectrogram');
saveas(gcf, 'figures/swapped_spectrograms.png');
saveas(gcf, 'figures/swapped_spectrograms.fig');

% Summarize findings
fprintf('\n--- Key Findings on Phoneme Swapping ---\n');
fprintf('1. Interchanging /b/ and /w/ affects word perception\n');
fprintf('2. Success depends on accurate phone boundary detection\n');
fprintf('3. Formant transitions are critical for perception\n');
fprintf('4. Initial phoneme identity significantly impacts lexical recognition\n'); 