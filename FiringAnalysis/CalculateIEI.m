function avgIEI = CalculateIEI(events)
    % Calculates average inter-event interval across all electrodes, in
    % units of milliseconds
    
    eventTimes = [];
    numElectrodes = size(events, 1);
    for el = 1:numElectrodes
        if (isempty(events{el}))
            % Remove reference
            continue;
        elseif (events{el}(1,3) == 0)
            % Remove reference
            continue;
        end % if
        
        eventTimes = [eventTimes; events{el}(:,2)];
    end % for
    uniqueEventTimes = unique(eventTimes);
    uniqueEventTimes = sort(uniqueEventTimes);
    IEI = diff(1e3*uniqueEventTimes);
    avgIEI = mean(IEI(IEI <= 100));
end % function