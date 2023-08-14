







function computeFilesCheckSum(dirNames,excludeSubDirs,excludeFiles)
mlock


    userHomeDir=connector.internal.userdir();
    dirNames=[dirNames,userHomeDir];


    persistent FILESHASHVAL;

    validDirs=[];

    for d=dirNames
        [~,isvalid]=system('if test -d'+string(d)+'; then echo "exist"; fi');
        if contains(isvalid,"exist")
            validDirs=[validDirs,d];
        end
    end
    dirs=strjoin(validDirs);


    excludeCommand="";
    constructExcludeCommand(excludeSubDirs,excludeFiles);

    commandToRun="find "+dirs+" "+excludeCommand+" -type f -exec md5sum {} \; ";

    [~,cmdout]=system(commandToRun+" | cut -b-32 | sort | md5sum");


    if isempty(FILESHASHVAL)
        FILESHASHVAL=cmdout;
        return
    end

    if strcmp(FILESHASHVAL,cmdout)
        return
    else
        [~,cmdout]=system(commandToRun);
        error("checksum mistach for one or more files:"+cmdout)
    end

    function constructExcludeCommand(excludeSubDirs,excludeFiles)
        lenDirs=length(excludeSubDirs);
        lenFiles=length(excludeFiles);
        for k=1:lenDirs
            if k==1
                excludeCommand=" -path '"+excludeSubDirs{k}+"'";
            else
                excludeCommand=excludeCommand+" -o -path '"+excludeSubDirs{k}+"'";
            end
        end

        for k=1:lenFiles
            if excludeCommand~=""
                excludeCommand=excludeCommand+" -o -name "+excludeFiles{k};
            else
                excludeCommand=" -name "+excludeFiles{k};
            end
        end
        if excludeCommand~=""
            excludeCommand="! \( "+excludeCommand+" \)";
        end
    end
end