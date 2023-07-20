function checkPointCloudSequenceAndTimestampsAgreement(ptCSequence,timestamps)








    assert((iscellstr(ptCSequence)||isa(ptCSequence,'matlab.io.datastore.FileDatastore'))&&...
    (isduration(timestamps)||isa(timestamps,'double')),'Unexpected inputs');

    if isa(ptCSequence,'matlab.io.datastore.FileDatastore')
        ptCSequence=ptCSequence.Files;
    end

    if numel(timestamps)~=numel(ptCSequence)
        error(message('vision:groundTruthDataSource:inconsistentTimestampsForPointCloud'));
    end

end
