function [well, append] = GetWell(Nsig)
    % Lets user choose which well(s) to analyze

    disp('Available subjects of analysis')
    disp('1 - Well 1')
    disp('2 - Well 2')
    disp('3 - Well 3')
    disp('4 - All wells, including tunnels')
    disp('5 - All wells, excluding tunnels')
    well = input('Choose subject: ');

    switch well
        case {1, 2, 3}
            append = ['-W' char(string(well)) '-' char(string(Nsig)) 'sig'];
        case 4
            append = ['-WT-' char(string(Nsig)) 'sig'];
        otherwise
            append = ['-WO-' char(string(Nsig)) 'sig'];
    end % switch
end

