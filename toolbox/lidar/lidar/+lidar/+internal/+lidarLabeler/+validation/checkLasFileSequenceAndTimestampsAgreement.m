function checkLasFileSequenceAndTimestampsAgreement(lasSequence,timestamps)








    assert((iscellstr(lasSequence)||isa(lasSequence,'matlab.io.datastore.FileDatastore'))&&...
    (isduration(timestamps)||isa(timestamps,'double')),'Unexpected inputs');

    if isa(lasSequence,'matlab.io.datastore.FileDatastore')
        lasSequence=lasSequence.Files;
    end

    if numel(timestamps)~=numel(lasSequence)
        error(message('lidar:groundTruthLidar:inconsistentTimestamps'));
    end

end
