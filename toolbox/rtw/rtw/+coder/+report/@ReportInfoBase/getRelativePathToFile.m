function out=getRelativePathToFile(cFileName,htmlFileName)




    if isempty(cFileName)
        out='';
        return;
    end
    basePath=fileparts(htmlFileName);
    if isempty(basePath)
        basePath=pwd;
    end
    out=rtwprivate('rtwGetRelativePath',cFileName,basePath);

    if strcmp(out,cFileName)&&ismember(filesep,cFileName)
        out=coder.report.internal.fileURL(out,'');
    end
end
