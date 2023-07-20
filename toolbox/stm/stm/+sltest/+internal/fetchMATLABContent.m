function fileContent=fetchMATLABContent(testFilePath)
    fid=fopen(testFilePath,'r');
    fileContent=fscanf(fid,'%c');
    cleanFID=onCleanup(@()fclose(fid));
end