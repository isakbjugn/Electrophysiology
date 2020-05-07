function [activeElectrodes, newcomers] = CountRecruitment(frame, alreadyRecruited)
    % Counts the number of electrodes that are recruited during a timebin
    % of an avalanche, determined by whether that electrode has, or
    % previously has had, any activity
    
    activeElectrodes = alreadyRecruited;
    for el = 1:size(frame,2)
        if (any(frame(:,el)))
            activeElectrodes(el) = 1;
        end % if
    end % for
    newcomers = sum(activeElectrodes) - sum(alreadyRecruited);
end % function