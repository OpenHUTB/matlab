function validateCustomReaderFunction(readerFunctionHandle,sourceName,timestamps)











    assert(isa(readerFunctionHandle,'function_handle')||ischar(sourceName)||...
    isduration(timestamps),'Unexpected inputs');

    try
        img=readerFunctionHandle(sourceName,timestamps(1));
    catch ME
        throwAsCaller(ME);
    end


    if~((ismatrix(img)||(ndims(img)==3&&size(img,3)==3)))
        error(message('vision:groundTruthDataSource:expected2DOrRGB'));
    end

end
