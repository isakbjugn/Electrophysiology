function binWidth = GetBinWidthMS(events)
    % Calculates bin with from average inter-event interval, counted in ms
    
    avgIEI = CalculateIEI(events);
    binWidth = round(avgIEI);
    if binWidth == 0
        binWidth = 1;
    end % if
end % function