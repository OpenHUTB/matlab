function checkImageSequenceAndTimestampsAgreement(imgSequence,timestamps)








    assert((iscellstr(imgSequence)||isa(imgSequence,'matlab.io.datastore.ImageDatastore'))&&...
    (isduration(timestamps)||isa(timestamps,'double')),'Unexpected inputs');

    if isa(imgSequence,'matlab.io.datastore.ImageDatastore')
        imgSequence=imgSequence.Files;
    end

    if numel(timestamps)~=numel(imgSequence)
        error(message('vision:groundTruthDataSource:inconsistentTimestamps'));
    end

end
