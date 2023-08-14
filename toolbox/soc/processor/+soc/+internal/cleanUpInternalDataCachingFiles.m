function cleanUpInternalDataCachingFiles(varargin)




    filesToDelete={...
    'socb_sim_in_progress.lock',...
    'soc_DCBInfo.txt',...
    'soc_RTBRateInfo.txt',...
    'taskStates.txt'};
    for i=1:numel(filesToDelete)
        if exist(filesToDelete{i},'file')
            delete(filesToDelete{i});
        end
    end
end

