function binWidth = GetBinWidth(events, rate)
    % Calculates bin with from average inter-event interval, counted in
    % timesteps, not ms!
    
    avgIEI = CalculateIEI(events);
    binWidth = round(avgIEI*1e-3*rate);
    if binWidth == 0
        binWidth = 1;
    end
end % function