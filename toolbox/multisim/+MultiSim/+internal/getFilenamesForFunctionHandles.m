function fileNames=getFilenamesForFunctionHandles(fh)






    fh=fh(~cellfun(@isempty,fh));




    [~,ia,~]=unique(cellfun(@char,fh,'UniformOutput',false));
    fh=fh(ia);


    fileNames=unique(cellfun(@getFileForFunction,fh,...
    'UniformOutput',false));
end

function fileName=getFileForFunction(fh)
    validateattributes(fh,{'function_handle'},{'scalar'});
    fhinfo=functions(fh);
    fileName=fhinfo.file;
end