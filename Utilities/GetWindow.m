function window = GetWindow(spikeMatrix, fs)
    % Lets user enter time window for creating raster plot of firing
    % activity, or reverts to default values
    
    duration = length(spikeMatrix) / fs; % fs = 1e4 = 10000
    fprintf('Duration of recording: %.2f s\n', duration);
    fprintf('Input start and end time in seconds:\n');
    tStart = input('Start: ');
    tStart = tStart * fs; % 1e4 because sampling rate 10,000Hz
    if (isempty(tStart) || tStart < 1)
        tStart = 1;
    end
    tEnd = input('End: ') * fs;
    if isempty(tEnd)
        tEnd = length(spikeMatrix);
    elseif (tEnd < tStart)
        tEnd = min([length(spikeMatrix), tStart + 10*fs]);
    end
    window = [tStart tEnd]; % Time window
end % function