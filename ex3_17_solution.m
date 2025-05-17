% Exercise 3.17 Solution
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
Fs = 10000;             % Sampling frequency (10 kHz)
Nfft = 1024;            % FFT points 
window_durations = [25, 10]; % Window durations in ms
window_colors = {'b', 'r'};  % Colors for plotting
windowed_signals = cell(length(window_durations), 1);  % To store windowed signals

% Load the speech data
matfile = 'data/ex3M1.mat';
if ~exist(matfile, 'file')
    fprintf('Error: ex3M1.mat file not found in the data folder.\n');
    return;
else
    load(matfile, 'speech1_10k');
end

% Prepare signal data
x = double(speech1_10k(:));  % Ensure column vector
N = length(x);
t = (0:N-1)/Fs;

% Plot and save the speech waveform
figure;
plot(t, x);
xlabel('Time (s)'); ylabel('Amplitude');
title('Speech Waveform (speech1\_10k)');
grid on;
saveas(gcf, 'figures/speech_waveform.png');
saveas(gcf, 'figures/speech_waveform.fig');

% Apply window and compute FFT
figure;
subplot(5,1,1);
plot(t, x);
title('Original Signal');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

for i = 1:length(window_durations)
    % Convert ms to samples and create Hamming window
    win_len = round(window_durations(i) * Fs / 1000);
    w = hamming(win_len, 'periodic');
    
    % Center window on signal
    center_idx = floor(N/2);
    start_idx = center_idx - floor(win_len/2) + 1;
    end_idx = start_idx + win_len - 1;
    
    % Create time vector for plotting window
    t_win = (start_idx:end_idx)/Fs;
    
    % Plot Hamming window
    subplot(5,1,i*2);
    plot(t_win, w);
    title(sprintf('%d ms Hamming Window', window_durations(i)));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
    
    % Apply window and plot windowed signal
    windowed_signal = x(start_idx:end_idx) .* w;
    subplot(5,1,i*2+1);
    plot(t_win, windowed_signal);
    title(sprintf('%d ms Windowed Signal', window_durations(i)));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
    
    % Save the windowed signal for FFT
    windowed_signals{i} = windowed_signal;
end
saveas(gcf, 'figures/windowed_signals.png');
saveas(gcf, 'figures/windowed_signals.fig');

% Compute and plot FFT with different window durations
figure;
hold on;

for i = 1:length(window_durations)
    % Compute FFT using previously windowed signal
    windowed_signal = windowed_signals{i};
    X = fft(windowed_signal, Nfft);
    
    % Compute and plot log-magnitude spectrum
    mag = abs(X(1:Nfft/2+1));
    mag_db = 20*log10(mag + eps);
    f = (0:Nfft/2) * Fs / Nfft;
    
    plot(f, mag_db, window_colors{i}, 'LineWidth', 1.5, ...
         'DisplayName', sprintf('%d ms', window_durations(i)));
end

% Add labels and legend
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Log-Magnitude Spectrum with Different Window Durations');
legend('show');
grid on;

% Save spectral plot
saveas(gcf, 'figures/log_magnitude_spectrum.png');
saveas(gcf, 'figures/log_magnitude_spectrum.fig');

% Print analysis summary
fprintf('\n--- Discussion on Spectral Estimates for Pitch Estimation ---\n');
fprintf('The 25 ms window provides a better spectral estimate for pitch estimation.\n');
fprintf('Reasons:\n');
fprintf('1. The 25 ms window covers approximately one full glottal cycle for typical male voices\n');
fprintf('2. Longer windows provide better frequency resolution, which is essential for accurate pitch estimation\n');
fprintf('3. Sharper spectral peaks in the 25 ms window make it easier to identify harmonics and fundamental frequency\n');
fprintf('4. The 10 ms window has poorer frequency resolution, resulting in broader spectral peaks\n');
fprintf('5. While the 10 ms window provides better time resolution, for pitch estimation frequency resolution is more important\n'); 