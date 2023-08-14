function setupWorkerCache
%SETUPWORKERCACHE enables parallel simulation of a model that is linked to
% a data dictionary. This function creates a temporary data dictionary
% cache for each worker in a parallel pool so that each worker can use the
% dictionary data independently.
%
%    See also cleanupWorkerCache.

%   Copyright 2014 The MathWorks, Inc.

% Note that the current dictionary cache must be the default cache
% before calling this function. This is because cleanupWorkerCache
% restores the cache to its default.

worker = getCurrentWorker;
if ~isempty(worker)
    
    % verify that we are starting with the default cache
    if strcmp(Simulink.dd.defaultCachePath, Simulink.dd.cachePath)
        cacheFile = Simulink.data.dictionary.workerCacheFile;
        Simulink.dd.setCachePath(cacheFile);
    else
        DAStudio.error('SLDD:sldd:CacheNotDefaultInWorker');
    end

    
end

end

