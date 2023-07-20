function cleanupWorkerCache
%CLEANUPWORKERCACHE restores default data dictionary cache settings when 
% you are finished parallel simulation of a model that is linked to a data
% dictionary. Use this function to undo the temporary changes made by the
% setupWorkerCache function.
%
%    See also setupWorkerCache.

%   Copyright 2014 The MathWorks, Inc.

worker = getCurrentWorker;
if ~isempty(worker)
    % restore the default cache
    defaultCache = Simulink.dd.defaultCachePath;
    Simulink.dd.setCachePath(defaultCache);
    
    % delete the cache created by setupWorkerCache
    cacheFile = Simulink.data.dictionary.workerCacheFile;
    if (~isempty(cacheFile)) && exist(cacheFile, 'file')
        delete(cacheFile);
    end
end

end

