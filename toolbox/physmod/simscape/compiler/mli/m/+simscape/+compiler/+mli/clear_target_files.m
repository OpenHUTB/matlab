function clear_target_files(dirName,moduleNames)




    moduleCFiles=[];
    moduleHFiles=[];


    for idx=1:length(moduleNames)
        moduleName=moduleNames{idx};
        curCFiles=dir([dirName,filesep,moduleName,'_*.c']);
        curHFiles=dir([dirName,filesep,moduleName,'_*.h']);
        moduleCFiles=[moduleCFiles;curCFiles];%#ok
        moduleHFiles=[moduleHFiles;curHFiles];%#ok
    end


    mCFiles=dir([dirName,filesep,'sscwrapper*.c']);
    mHFiles=dir([dirName,filesep,'sscwrapper*.h']);
    mrtCFiles=dir([dirName,filesep,'rt*.c']);
    mrtHFiles=dir([dirName,filesep,'rt*.h']);

    allfiles=[moduleCFiles;moduleHFiles;mCFiles;...
    mHFiles;mrtCFiles;mrtHFiles];


    for fileIdx=1:length(allfiles)

        deleteFile=false;

        file=[allfiles(fileIdx).folder,filesep,allfiles(fileIdx).name];

        fid=simscape.compiler.support.open_file_for_read(file);

        line=fgetl(fid);
        if ischar(line)&&contains(line,'Simscape target specific file')
            deleteFile=true;
        end

        fclose(fid);

        if deleteFile
            builtin('delete',file);
        end
    end

