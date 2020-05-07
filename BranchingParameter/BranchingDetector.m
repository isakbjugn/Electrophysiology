function avgDescendants = BranchingDetector(sparseSpikes, deltaT_ms, rate)
    % Detects branching event and calculates average branching for that
    % specific time bind width.
    
    deltaT = deltaT_ms * rate / 1e3; % convert from ms to timesteps

    duration = length(sparseSpikes);
    k = false; % Switch for ongoing avalanche
    s = false; % Switch for avalanche onset
    descendants = []; % Store avalanche sizes
    ancestors = 0;
    for timei = 1:deltaT:duration - deltaT
        frame = sparseSpikes(timei:timei+deltaT,:);
        NElectrodes = sum(sum(frame));
        if (NElectrodes && ~k)
            k = 1;
            s = 1; % This is start of avalanche
            ancestors = NElectrodes;
        elseif (NElectrodes && k && s)
            descendants = [descendants NElectrodes/ancestors];
            s = 0; % No longer start of avalanche
        elseif (~NElectrodes && k)
            k = 0;
        end % if
    end % for
    
    avgDescendants = mean(descendants);
end % function