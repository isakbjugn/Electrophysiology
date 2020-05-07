function modality = GetModality()
    % Lets user choose which avalanche size modality to analyze with
    % respect to 
    
    clc;
    disp('Possible avalanche size modalities:');
    disp('1 - Number of electrodes')
    disp('2 - Number of firings')
    disp('3 - Lifetime')
    disp('4 - Scan to power law')
    choice = input('Choose modality: ');
    switch choice
        case 1
            modality = 'electrodes';
        case 2
            modality = 'firings';
        case 3
            modality = 'lifetime';
    end % switch
end % function