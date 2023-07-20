function cacheFile = workerCacheFile
%WORKERCACHEFILE returns the name of a worker-unique dictionary cache file
%   Composes a file path in the temporary directory with a name unique to
%   the current worker.
%
%    See also setupWorkerCache, cleanupWorkerCache.

%   Copyright 2014 The MathWorks, Inc.

cacheFile = '';
worker = getCurrentWorker;
if ~isempty(worker)
    cacheFile = [tempname '_ddcache.slddc'];
end

end

