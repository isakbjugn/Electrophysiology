function Hd = o2ButterBP300to3k(sampFreq)
%4OBUTTERBP300-3K Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.1 and the Signal Processing Toolbox 7.3.
% Generated on: 26-Oct-2018 13:36:53

% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = sampFreq;  % Sampling Frequency

N   = 2;     % Order
Fc1 = 300;   % First Cutoff Frequency
Fc2 = 3000;  % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');

% [EOF]
