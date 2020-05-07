function sizes = AvalancheDetector(sparseSpikes, deltaT_ms, rate, modality, varargin)
    % Plots probability of neuronal avalanches as function of avalanche
    % size, together with expontential relationship
    
    deltaT = deltaT_ms * rate / 1e3; % convert from ms to timesteps

    duration = length(sparseSpikes);
    k = false; % Switch for ongoing avalanche
    sizes = []; % Store avalanche sizes
    currentSize = 0; % Don't name a variable size !!!
    numElectrodes = size(sparseSpikes,2);
    recruitment = zeros(1,numElectrodes); % vector counting activated electrodes
    
    for timei = 1:deltaT:duration - deltaT
        frame = sparseSpikes(timei:timei+deltaT,:);
        avalancheIndicator = any(any(frame)); % any activity in frame
        switch modality
            case 'lifetime'
                sizeIndicator = avalancheIndicator; % any firing                
            case 'electrodes'
                [recruitment, newcomers] = CountRecruitment(frame, recruitment);
                sizeIndicator = newcomers; % newly recruited electrodes
            case 'firings'
                sizeIndicator = sum(sum(frame)); % number of firings
        end % switch
        if (avalancheIndicator && ~k)
            k = 1;
            currentSize = sizeIndicator;
        elseif (avalancheIndicator && k)
            currentSize = currentSize + sizeIndicator;
        elseif (~avalancheIndicator && k)
            k = 0;
            sizes = UpdateCounter(currentSize, sizes);
            currentSize = 0;
            recruitment(recruitment~=0) = 0; % reset recruitment
        end % if
    end % for
    
    if (nargin > 4)
        if (strcmp(varargin{1}, 'draw'))
            switch modality
                case 'lifetime'
                    exponent = 2;
                    xLabel = 'Avalanche lifetime (frames)';
                case 'electrodes'
                    exponent = 1.5;
                    xLabel = 'Avalanche size (#electrodes)';
                case 'firings'
                    exponent = 1.5;
                    xLabel = 'Avalanche size (#firings)';
            end % switch
            
            if (nargin > 5)
                DrawSingleDist(sizes, deltaT_ms, true, xLabel, exponent, varargin{2}, modality);
            else
                DrawSingleDist(sizes, deltaT_ms, true, xLabel, exponent);
            end % if
        end % if
    end % if
end % function