function DrawSingleDist(sizes, binWidth, relative, xLabel, exponent, varargin)
    % Draws single avalanche size distribution based on sizes vector.
    % Relative parameter states whether distribution is normalized.
    % Theoretical distribution is plotted based on exponent parameter.
    % Varargin controls whether plot is saved to file
    
    [indeces, values] = CountOccurence(sizes, relative);
    
    figure;
    plot(indeces, values, '-d', 'LineWidth', 1, 'MarkerFaceColor', [1 1 1])
    hold on
    
    indeces = 1:1:RoundPower(indeces(end));
    powerLaw = indeces.^(-exponent);
    plot(indeces, powerLaw, '--', 'LineWidth', 1.5);
    
    Legend = cell(2,1);
    Legend{1} = [char(string(binWidth)) ' ms'];
    a = sprintf('\alpha');
    Legend{2} = ['Power law, \alpha = ' char(string(exponent))];
    legend(Legend)
    
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    ylabel('p(size)')
    xlabel(xLabel) % 'Avalanche length (frames)'
    title('Avalanche size distribution');
    
    if (~relative)
        ylabel('Number of avalanches')
    end % if
    
    % Functionality to save to file
    if (nargin > 6)
        filename = varargin{1};
        modality = varargin{2};
        savefile = ['Electrophysiology\' char(upper(modality(1)))...
            char(modality(2:end)) '\' filename '-avgIEI'];
%         set(gcf, 'WindowState', 'maximized');
        saveas(gcf,savefile,'svg');
        saveas(gcf,savefile,'epsc');
    end % if
end % function



