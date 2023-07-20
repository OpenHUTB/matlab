
function y=getCurrentPath()
    y.folderPath=[pwd,filesep];



    tempFilePath=tempname(y.folderPath);
    fid=fopen(tempFilePath,'w');
    if fid==-1
        y.attribute.isWritable=false;
    else
        y.attribute.isWritable=true;
        fclose(fid);
        delete(tempFilePath);
    end
