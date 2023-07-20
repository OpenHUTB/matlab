


function success=SaveToFile(svgString,filename)
    fileHandle=fopen(filename,'wt');
    if(fileHandle==-1)
        success=false;
        warning('Unable to open file to write!');
        return;
    end
    fileCL=onCleanup(@()fclose(fileHandle));

    splitString=strsplit(svgString,'\\n');
    for i=splitString
        fprintf(fileHandle,'%s\n',i{1});
    end
    success=true;
end