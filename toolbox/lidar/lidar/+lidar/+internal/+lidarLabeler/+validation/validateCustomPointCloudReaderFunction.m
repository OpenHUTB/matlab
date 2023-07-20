function validateCustomPointCloudReaderFunction(readerFunctionHandle,sourceName,timestamps)











    assert(isa(readerFunctionHandle,'function_handle')||ischar(sourceName)||...
    isduration(timestamps),'Unexpected inputs');

    try
        pointCloud=readerFunctionHandle(sourceName,timestamps(1));
    catch ME
        throwAsCaller(ME);
    end


    if~isa(pointCloud,'pointCloud')
        error(message('lidar:labeler:expectedPointCloud'));
    end

end