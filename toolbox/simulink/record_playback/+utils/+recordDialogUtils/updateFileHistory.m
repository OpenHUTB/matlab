function updateFileHistory(blkHdl,fileName)
    view=get_param(blkHdl,'view');
    recordFileHistory=view.fileHistory;

    existingPath=false;
    for index=1:recordFileHistory.Size()
        if string(recordFileHistory(index))==fileName
            recordFileHistory.removeAt(index);
            recordFileHistory.insertAt(fileName,int32(1));
            existingPath=true;
            break;
        end
    end

    if~existingPath
        recordFileHistory.insertAt(fileName,int32(1));
        if recordFileHistory.Size()>6
            recordFileHistory.removeAt(recordFileHistory.Size());
        end
    end
end