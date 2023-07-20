


function isConsistent=checksumConsistencyCheck(CachedChecksum,CurrentChecksum)
    isConsistent=~isempty(CachedChecksum)&&...
    ~isempty(CurrentChecksum)&&...
    isequal(CurrentChecksum,CachedChecksum);
end
