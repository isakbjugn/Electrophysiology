% Spike detector

% --- Takes sampling rate (Hz), threshold (number of standard deviations),
% voltage data, and pos/neg phase detection.
% Outputs array of event times and amplitudes, event count, voltage
% threshold and spike rate.

function [events, c, thresh] = SpikeDetector(rate, Nsig, volt, isNeg)

% Parameters
t = 1e-3;     % Approx. duration of a spike (s)
n = rate*t;   % Number of samples spanning a spike

% Calculate median, sigma, threshold; return threshold
sig = std(volt);
if isNeg == 1
    thresh = median(volt) - Nsig*sig;
    if Nsig > 1.5
        threshOff = median(volt) - (Nsig/3)*sig;
    else
        threshOff = thresh;
    end
else
    thresh = median(volt) + Nsig*sig;
    if Nsig > 1.5
        threshOff = median(volt) + (Nsig/3)*sig;
    else
        threshOff = thresh;
    end
end


% Event detection
c = 0;   % Initialize event count
k = 0;   % Initialize switch index
events = zeros(floor(length(volt)/10), 3); % Improves performance
if isNeg == 1
    for i=1:length(volt)-n
        % If voltage is below detection threshold, add event to events
        % list, increment event count, and change switch index to 1
        if k == 0 && volt(i) <= thresh
            c = c+1;
            k = 1;
            e = volt(i:i+n);
            [M, index] = min(e);
            events(c, 1) = M;   % Max amplitude of event
            events(c, 2) = (index+i-2)/rate;   % Time of event (s)
            events(c, 3) = index+i-1;    % Index of event 
        % If switch index is on and voltage exceeds return threshold,
        % change switch index back to 0
        elseif k == 1 && volt(i) >= threshOff
            k = 0;
        end
    end
else
    for i=1:length(volt)-n
        % If voltage is above detection threshold, add event to events
        % list, increment event count, and change switch index to 1
        if k == 0 && volt(i) >= thresh
            c = c+1;
            k = k+1;
            e = volt(i:i+n);
            [M, index] = max(e);
            events(c, 1) = M;   % Max amplitude of event
            events(c, 2) = (index+i-2)/rate;   % Time of event (s)
            events(c, 3) = index+i-1;    % Index of event
        % If switch index is on and voltage is below return threshold,
        % change switch index back to 0
        elseif k == 1 && volt(i) <= threshOff
            k = 0;
        end
    end
end

events( ~any(events,2), : ) = []; % Improves performance

if c == 0
    events = zeros(1, 3);
end
