function folder=getDefaultProjectFolder()




    folder=matlab.internal.project.creation.getDefaultFolder();



    found=exist(folder,'dir')==7;
    if(found&&~iCanWriteInFolder(folder))...
        ||(~found&&~mkdir(folder))

        folder=tempdir;
        warning(message('SimulinkProject:Demo:CannotWriteToWorkFolder'));
    end

end

function writable=iCanWriteInFolder(folder)

    writable=true;
    tempFile=tempname(folder);
    cleanUpHandle=onCleanup(@()iDeleteItExists(tempFile));
    try
        iWriteEmptyFile(tempFile);
    catch WriteError %#ok<NASGU>
        writable=false;
    end

end

function iDeleteItExists(file)

    if(exist(file,'file'))
        delete(file);
    end

end


function iWriteEmptyFile(file)

    fid=fopen(file,'w');
    fprintf(fid,"*");
    cleanUpHandle=onCleanup(@()fclose(fid));
end

