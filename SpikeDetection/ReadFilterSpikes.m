%% Reads data from file, applies filter, performs spike detection

function [spikeMatrix, varargout] = ReadFilterSpikes(pathname, filename, savename, Nsig, well)
    % Produces spike matrix, recording rate and event cell array from .h5
    % file. Analysis can be performed on different wells depending on the
    % well parameter. Reference is by default not included in analysis of
    % single well, but included when analyzing all wells together.

    % Set up stuff
    fullfile = [pathname filename];
    
    % Initialize array of electrodes of interests (selectrodes)
    allElectrodes = 1:60;
    includeRef = 0; % Whether to include reference electrode
    
    switch well
        case 1
            selecNum = [15 23:26 31:32 34 39:40];
        case 2
            selecNum = [1:3 5 9:12 18:19 42:43 49:52 56:60];
        case 3
            selecNum = [22 27:30 35:36 38 46 54];
        case 4 % tunnel case
            selecNum = allElectrodes;
        otherwise % wells only case
            tunnels = [6:8 13:14 16:17 20:21 33 37 41 44:45 47:48 53 55];
            selecNum = setdiff(allElectrodes, tunnels);     
    end % switch

    % Array of electrode numbers in order
    numElectrodes = length(selecNum); % 10 for wells 1 and 3, 21 for 2
    if (any(well == [1 2 3]))
        numElectrodes = numElectrodes + includeRef;
    end % if
    
    % Electrodes sorted by number
    elecNum = [12:17 21:28 31:38 41:48 51:58 61:68 71:78 82:87];
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


    % Read and spike trains
    % Initialize variables
    events = cell(numElectrodes, 1);
    numEvents = zeros(numElectrodes, 1);
    threshold = zeros(numElectrodes, 1);
    spikeMatrix = zeros(length(time), numElectrodes); % zeros(length(time), 60);

    % Read data, filter, and apply event detection
    data_labels = h5read(filename, h5path, [1 1], [length(time) 60]);
    j = 0;
    for i = 1:60
        if (i==4)
            if (~includeRef && any(well == [1 2 3]))
                continue
            end % if
            index = find(strcmp('Ref', label));            
        elseif (~any(selecNum == i))
            % Skip electrodes not in current well            
            continue;
        else
            e = elecStr(i);
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
    fprintf('\n');

    % Write events to spikeMatrix
    for el = 1:numElectrodes
        channel = events{el,1};
        [numSpikes, ~] = size(channel);
        if (~any(channel))
            % Skip electrode (reference) without events, otherwise crash
            continue;
        end % if
        for ev_idx = 1:numSpikes            
            idx = channel(ev_idx, 3);
            spikeMatrix(idx, el) = 1; % True spike at event index
        end % for ev_idx
    end % for el

    % Convert spikeMatrix to sparse matrix
    spikeMatrix = sparse(spikeMatrix);

    % Save
    savefile = ['Data\' savename];
    save(savefile, 'spikeMatrix', 'events', 'rate', 'threshold', 'Nsig', '-v7.3');
    
    if nargout == 2
        varargout{1} = rate;
    elseif nargout == 3
        varargout{1} = rate;
        varargout{2} = events;
    end % if    

end % function