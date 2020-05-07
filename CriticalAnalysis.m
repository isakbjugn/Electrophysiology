%% Tool for assessing critical behavior in recordings

% Add to path all the subdirectories in the toolbox
clc, clear;
topdir = fileparts(which(mfilename));
addpath(genpath(topdir));

% Specifications
fs = 1e4; % sampling frequency

while 1
    
    clc;
    fprintf('Welcome to the Criticality Analyzer\n');
    disp('1 - Load spiking matrix')
    disp('2 - Perform spike detection on .h5 file')
    disp('3 - Total analysis of .h5 file')
    disp('0 - Exit')
    reply = input('Choose method: ');
    if isempty(reply)
        reply = -1;
    end
    
    switch reply
        case 1
            % Load .dat file, results from previous analysis
            [filename, pathname] = uigetfile('Data\*.mat','Select MAT file with spike trains');
            load(filename);
            fullfile = [pathname, filename];
            savename = filename(1:end-4);
            break;
        case 2
            % Load .h5 file
            [filename, pathname] = uigetfile('Data\*.h5','Select HDF5 file with recording');
            if ~filename % Exit script if user canceled the open file dialog
                return
            end
            
            fullfile = [pathname, filename];            
            suffix = GetSuffix(filename);            
            Nsig = input('Enter threshold, N sigmas: ');
            [well, append] = GetWell(Nsig);
            savename = [filename(1:10) suffix append];
            [spikeMatrix, rate, events] = ReadFilterSpikes(pathname, filename, savename, Nsig, reply);
            
            disp('--- Spike detection completed ---')
            pause(1)
            break;
        case 3
            % Scan .h5 file across sigma thresholds and wells
            TotalAnalysis();
            return;
    end % switch
end % while

while 1
    
    clc;
    fprintf('Recording: %s \n',fullfile);
    disp('1 - Rasterplot')
    disp('2 - Fit to power law')
    disp('3 - Test to power law')
    disp('4 - Scan to power law')
    disp('5 - Average IEI')
    disp('6 - Branching parameter')
    disp('0 - Exit')
    reply = input('Choose method: ');
    if isempty(reply)
        reply = -1;
    end
    
    switch reply
        case 1
            % Create rasterplot of spike trains
            window = GetWindow(spikeMatrix, fs); % Get time window
            rasterplot(spikeMatrix, window, savename);
            
        case 2
            % Find avalanche distribution with optimal bin width
            modality = GetModality();
            deltaT_ms = GetBinWidthMS(events);
            avalancheSizes = AvalancheDetector(spikeMatrix, deltaT_ms, rate, modality, 'draw', savename, modality);
            
        case 3
            % Find avalanche distribution from chosen bin width
            modality = GetModality();
            deltaT_ms = input('Set a frame width (ms): ');
            avalancheSizes = AvalancheDetector(spikeMatrix, deltaT_,s, rate, 'lifetime', 'draw');
            
        case 4
            % Find avalanche distribution from scan scross bin widths
            modality = GetModality();
            AvalancheScan(spikeMatrix, rate, modality, savename);
            
        case 5
            % Calculate average IEI
            avgIEI = CalculateIEI(events);
            disp(avgIEI);
            pause(1)
            
        case 6
            % Plot branching parameter as function of bin width
            BranchingParameter(spikeMatrix, rate, savename);
            
        case 0
            % Clear workspace and exit
            clc;
            reply = input('Clear workspace on exit? [Y/n] ','s');
            if isequal(reply,'N') || isequal(reply,'n')
                return
            end
            clear;
            return
        otherwise % Do nothing
    end % switch
end
                




