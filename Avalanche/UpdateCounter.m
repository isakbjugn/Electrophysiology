function counter = UpdateCounter(int, counter)
    % Increments the count of occurences of int in counter variable
    % counter, or creates said element if it does not yet exist
    
    if length(counter) < int
        counter(int) = 1;
    else
        counter(int) = counter(int) + 1;
    end % if
end % function