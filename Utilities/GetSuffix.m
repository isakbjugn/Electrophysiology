function suffix = GetSuffix(filename)
    % Lets user add custom suffix to filename, to simplify storage and
    % location of .h5 files

    suffix = '';
    while true
        clc
        fprintf('Current base filename: %s%s \n', filename(1:10), suffix);
        disp('1 - Edit suffix')
        disp('0 - Proceed')
        reply = input('Choose action: ');
        switch reply
            case 1
                suffix = input('Suffix: ', 's');
                if (suffix ~= "")
                    suffix = ['-' suffix];
                end % if
            otherwise
                break;
        end % switch            
    end % while
end

