function TotalAnalysis()   
    fs = 10000;
    
    % Input file
    clc;
    fprintf('Welcome to the Total Analyzer\n');
    [filename, pathname] = uigetfile('Data\*.h5','Select HDF5 file with recording');
    if ~filename % Exit script if user canceled the open file dialog
        return
    end

    suffix = GetSuffix(filename);
    NsigMin = input(['Lower ' char(963) ' threshold: ']);
    NsigMax = input(['Upper ' char(963) ' threshold: ']);
    
    for Nsig = NsigMin:NsigMax
        for well = [1 2 3 5] % Option: Limit to specific well
            if (well == 5)
                append = ['-WO-' char(string(Nsig)) 'sig'];
                disp('- Analyzing all wells, excluding tunnels -');
            else
                append = ['-W' char(string(well)) '-' char(string(Nsig)) 'sig'];
                fprintf('- Analyzing well %i -\n', well);
            end % if
            savename = [filename(1:10) suffix append];
            [spikeMatrix, rate, events] = ReadFilterSpikes(pathname, filename, savename, Nsig, well);
            
            % Produce rasterplot
%             window = [1 10*fs]; % Time window
%             rasterplot(spikeMatrix, window, savename);

            % Plot avalanche size distribution, optimal bin width
            deltaT_ms = GetBinWidthMS(events);
            AvalancheDetector(spikeMatrix, deltaT_ms, rate, 'electrodes', 'draw', savename);
            
            
            % Produce avalanche distribution from active sites
%             AvalancheScan(spikeMatrix, events, rate, 'electrodes', savename);
%             AvalancheScan(spikeMatrix, events, rate, 'lifetime', savename);
%             AvalancheScan(spikeMatrix, events, rate, 'firings', savename);

            % Calculate kappa parameter
            % Not implemented
            
        end % for
    end % for
    disp('- Total analysis completed-');
end % function


