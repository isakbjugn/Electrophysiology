function BranchingParameter(sparseSpikes, rate, varargin)
    % Calculates branching parameter of network activity, using
    % increasingly larger time bins.

    figure;
    frameLengths = [1 2 4 8 16 32];
    frameString = sprintf('%d ', frameLengths);
    fprintf('These frame lengths are scanned: %s\n', frameString)
    branching = [];
    
    for deltaT = frameLengths
        avgDescentants = BranchingDetector(sparseSpikes, deltaT, rate);
        branching(deltaT) = avgDescentants;
    end % for
    [indeces, values] = CountOccurence(branching, false);
%     bar(indeces, values);
    plot(indeces, values, '-d', 'LineWidth', 1, 'MarkerFaceColor', [1 1 1]);
%     set(gca, 'YScale', 'log')
%     set(gca, 'XScale', 'log')
    ylabel('Branching parameter')
    xlabel('Frame width')
    title('Branching parameter');
    
    if (nargin > 2)
        filename = varargin{1};
        savefile = ['Electrophysiology\Branching\' filename];
        saveas(gcf,savefile,'svg');
        saveas(gcf,savefile,'epsc');
    end % if
end % function