function validateTimestamps(timestamps)




    if~(isduration(timestamps)||isa(timestamps,'double'))...
        ||~isvector(timestamps)
        error(message('vision:groundTruthDataSource:InvalidTimestamps'));
    end

    if~issorted(timestamps)&&numel(unique(timestamps))~=numel(timestamps)
        error(message('vision:groundTruthDataSource:badTimestamps'));
    end

end

