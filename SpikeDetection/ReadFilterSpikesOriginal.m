%% Reads data from file, applies filter, performs spike detection

function [spikeMatrix, varargout] = ReadFilterSpikesOriginal(pathname, filename, savename, Nsig)

    %% Set up stuff
    fullfile = [pathname filename];

    % Array of electrode numbers in order
    elecNum = [12:17 21:28 31:38 41:48 51:58 61:68 71:78 82:87].';
    % Electrodes sorted by number
    elecStr = string(elecNum);
    isNeg = 1;

    % File info
    [rate, durSec, label, exponent, conver, info] = h5fileinfo(fullfile);
    % label holds electrode number in the order they're read
    h5path = info.Groups.Groups(1).Groups(1).Groups(1).Name;
    h5path = [h5path, '/ChannelData'];

    % Butterworth filter
    Hd = o2ButterBP300to3k(rate);

    % Time array
    tStart = 0;
    deltaT = 1/rate;
    tEnd = durSec-deltaT;
    time = tStart:deltaT:tEnd;
    time = time.';


    %% Read and spike trains
    % Initialize variables
    events = cell(60, 1);
    numEvents = zeros(60, 1);
    threshold = zeros(60, 1);
    spikeMatrix = zeros(length(time), 60);

    % Read data, filter, and apply event detection
    data_labels = h5read(filename, h5path, [1 1], [length(time) 60]);
    for i = 1:60
        if i == 4
            index = find(strcmp('Ref', label));
        else
            e = elecStr(i);
            % Retrieve electrode number from elecNum
            index = find(strcmp(e, label));
            % Retrieve index of electrode e
        end
        data = data_labels(:,index);
        voltRaw = double(data)*conver*10^(double(exponent))*1e6;      % µV
        volt(:,i) = filter(Hd, voltRaw);
        %[ev, c, thresh, spikeRate] = EventDetector(rate, Nsig, volt(:,i), isNeg);SpikeDetector
        [ev, c, thresh] = SpikeDetector(rate, Nsig, volt(:,i), isNeg);
        events{i} = ev;
        numEvents(i) = c;
        threshold(i) = thresh;
        % FR(i) = spikeRate;
    end

    %% Write events to spikeMatrix
    for el = 1:60
        channel = events{el,1};
        [numSpikes, ~] = size(channel);
        if (~any(channel))
            ref = el;
            continue;
        end % if
        for ev_idx = 1:numSpikes            
            idx = channel(ev_idx, 3);
            spikeMatrix(idx, el) = 1; % True spike at event index
        end % for ev_idx
    end % for el

    %% Convert spikeMatrix to sparse matrix
    spikeMatrix = sparse(spikeMatrix);

    %% Save
%     Save .mat file
%     savefile = [char(filename(1:(length(filename)-3))) '-' char(string(Nsig)) 'sig'];
%     savefile = [char(filename(1:9)) '-' char(string(Nsig)) 'sig'];
%     savefile = ['Data\' char(filename(1:10)) '-' char(string(Nsig)) 'sig'];    
    savefile = ['Data\' savename];
    save(savefile, 'spikeMatrix', 'events', 'rate', 'threshold', 'Nsig', '-v7.3');
    
    if nargout == 2
        varargout{1} = rate;
    end % if    

end % function