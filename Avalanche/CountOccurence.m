function [indeces, values] = CountOccurence(sizes, if_relative)
    % Used by DrawSingleDist and AvalancheScan to count how many times
    % specific avalanche sizes/durations occur in sizes vector. Note: Two
    % ways to normalize. The second noramlization option is better when
    % plotting multiple distributions together.

    indeces = [];
    values = [];
    for i = 1:length(sizes)
        currentSize = sizes(i);
        if currentSize
            indeces = [indeces i];
            values = [values currentSize];
        end % if
    end % for
    
    if if_relative
        % Normalize, so PDF sums to 1
%         numAvalanche = sum(values);
%         values = values./numAvalanche;
        
        % or: Normalize, so PDF starts at 1
        values = values./values(1);        
    end % if
end % function