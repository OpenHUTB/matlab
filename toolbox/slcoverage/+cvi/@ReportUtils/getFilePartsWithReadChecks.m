function[path,fileName,ext]=getFilePartsWithReadChecks(filename,neededExt)






    fullFileName=cvi.ReportUtils.appendFileExtAndPath(filename,neededExt);
    [path,fileName,ext]=fileparts(fullFileName);

    if~strcmpi(ext,neededExt)
        error(message('Slvnv:simcoverage:ioerrors:BadExtensionRead',neededExt));
    end

    txtHandle=fopen(fullFileName,'r');
    if(txtHandle==-1),
        error(message('Slvnv:simcoverage:ioerrors:UnableToOpenForReading',fullFileName));
    end
    fclose(txtHandle);