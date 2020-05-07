function rasterplot( sparseSpikes, window, varargin)
    % Creates raster plot of firing activity in tim window.
    % Copied from MEA Toolbox

    % varargin = [filename, Nsig]

    lineLength = 0.3;
    tStart = window(1);
    tEnd = window(2);
    duration = tEnd - tStart + 1;
    numElectrodes = size(sparseSpikes, 2);
    labels = 1:numElectrodes; % labels = 1:60;

    figure;
%     M = cell(length(sparseSpikes),2);
    M = cell(length(duration),2);
    emptyTimeStamps = false(1,duration);
    
    for timei = tStart:1:tEnd
        if ~any(sparseSpikes(timei,:))
            emptyTimeStamps(timei-tStart+1) = true;
            continue
        end
        spikingElectrodes = find(sparseSpikes(timei,:));
        
        % Store y-values
        M{timei,1} = [spikingElectrodes - lineLength; spikingElectrodes + lineLength];
        % Just makes a 2x60 array of spike times in s, x-values ?
        M{timei,2} = repmat([timei*1e-4; timei*1e-4],1,size(M{timei,1},2));
        % Initialises y-values for raster plot lines ?
        if all(emptyTimeStamps)
            return
        end
    end % for
    
    for timei = tStart:1:tEnd
        if emptyTimeStamps(timei-tStart+1)
            continue
        end % if 
        line(M{timei,2},M{timei,1},'Color','k')
    end % for
    
    set(gca,'YTick', 1:numElectrodes);
    set(gca,'YTickLabel', string(labels));
    ylabel('Source Channel','FontSize',16);
    % --- Code from McsTimeStampStream plot end ---
    
    xlabel('Time [s]','FontSize',16);
    title('Rasterplot','FontSize',20);
    ylim([0 length(labels)+1]);
    
    durString = ['-' char(string(round(duration/10))) 'ms'];
    if (duration > 9995)
        durString = ['-' char(string(round(duration/10000))) 's'];
    end % if
    
    if (nargin > 2)
        filename = varargin{1};
        savefile = ['Electrophysiology\Rasterplot\' filename durString];
        set(gcf, 'WindowState', 'maximized');
        saveas(gcf,savefile,'svg');
        saveas(gcf,savefile,'epsc');
    end % if
end % function

