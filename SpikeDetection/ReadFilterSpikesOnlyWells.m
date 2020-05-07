%% Reads data from file, applies filter, performs spike detection

function [spikeMatrix, varargout] = ReadFilterSpikesOnlyWells(pathname, filename, savename, Nsig)

    %% Set up stuff
    fullfile = [pathname filename];

    % Array of electrode numbers in order
    elecNum = [12:17 21:28 31:38 41:48 51:58 61:68 71:78 82:87].';
    tunnelNum = [6, 7, 8, 13, 14, 16, 17, 20, 21, 33, 37, 41, 44,...
        45, 47, 48, 53, 55];
    numElectrodes = length(elecNum) - length(tunnelNum); % = 42
    tunnelStr = string(tunnelNum);
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
    events = cell(numElectrodes, 1);
    numEvents = zeros(numElectrodes, 1);
    threshold = zeros(numElectrodes, 1);
    spikeMatrix = zeros(length(time), numElectrodes); % zeros(length(time), 60);

    % Read data, filter, and apply event detection
    data_labels = h5read(filename, h5path, [1 1], [length(time) 60]);
    j = 0;
    for i = 1:60
        if i == 4
            index = find(strcmp('Ref', label));
        else
            e = elecStr(i);
            if (any(tunnelStr == e))
                % Skip electrodes in tunnels
                continue;
            end % if
            % Retrieve electrode number from elecNum
            index = find(strcmp(e, label));
            % Retrieve index of electrode e
        end
        j = j + 1;
        data = data_labels(:,index);
        voltRaw = double(data)*conver*10^(double(exponent))*1e6;      % µV
        volt(:,j) = filter(Hd, voltRaw);
        %[ev, c, thresh, spikeRate] = EventDetector(rate, Nsig, volt(:,i), isNeg);SpikeDetector
        [ev, c, thresh] = SpikeDetector(rate, Nsig, volt(:,j), isNeg);
        events{j} = ev;
        numEvents(j) = c;
        threshold(j) = thresh;
        % FR(i) = spikeRate;
    end

    %% Write events to spikeMatrix
    for el = 1:numElectrodes % = 42
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
%     savefile = ['Data\' char(filename(1:10)) '-' char(string(Nsig)) 'sig-onlyWells'];
    savefile = ['Data\' savename];
    save(savefile, 'spikeMatrix', 'events', 'rate', 'threshold', 'Nsig', '-v7.3');
    
    if nargout == 2
        varargout{1} = rate;
    end % if    

end % function