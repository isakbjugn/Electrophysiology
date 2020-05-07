function AvalancheScan(spikeMatrix, rate, modality, varargin)
    % Calculates distribution of neuronal avalanches, using increasingly
    % higher time bins. Modality is a string, indicating whether avalanche
    % size is measured in duration of number of electrodes activated

    figure;
    if_relative = true;
    frameLengths = [1 2 4 8 16 32];
    frameString = sprintf('%d ', frameLengths);
    fprintf('Scanned frame widths: %s\n', frameString)    
    
    maxIndex = 0;
    
    for deltaT = frameLengths
        sizes = AvalancheDetector(spikeMatrix, deltaT, rate, modality);
        [indeces, values] = CountOccurence(sizes, if_relative);
        plot(indeces, values, '-d', 'LineWidth', 1, 'MarkerFaceColor', [1 1 1])
        hold on
        
        % Retrieve end point to draw power law
        if (indeces(end) > maxIndex)
            maxIndex = indeces(end);
        end % if
    end % for
    
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
    
    % Draw power law
%     fplot(@(x) x^(-exponent), '--', 'LineWidth', 1.5)
    indeces = 1:1:RoundPower(maxIndex);
    powerLaw = indeces.^(-exponent);
    plot(indeces, powerLaw, '--', 'LineWidth', 1.5);
    
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    ylabel('p(size)', 'FontSize', 16);
    xlabel(xLabel, 'FontSize', 16);
    title('Avalanche size distribution', 'FontSize',20);
    
    if (~if_relative)
        ylabel('Number of avalanches', 'FontSize',16);
    end % if
    
    Nframes = length(frameLengths);
    Legend = cell(Nframes, 1);
    for i = 1:Nframes
        Legend{i} = [char(string(frameLengths(i))) ' ms'];
    end % for
    
    legend(Legend)
    
    if (nargin > 3)
        filename = varargin{1};
        savefile = ['Electrophysiology\' char(upper(modality(1)))...
            char(modality(2:end)) '\' filename];
        set(gcf, 'WindowState', 'maximized');
        saveas(gcf,savefile,'svg');
        saveas(gcf,savefile,'epsc');
    end % if 
end % function