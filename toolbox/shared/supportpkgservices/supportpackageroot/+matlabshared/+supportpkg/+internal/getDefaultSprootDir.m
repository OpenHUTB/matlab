function defaultDirValue=getDefaultSprootDir()
    overrideDefaultDir=matlabshared.supportpkg.internal.getOverrideDefaultSprootDir();
    if~isempty(overrideDefaultDir)
        defaultDirValue=overrideDefaultDir;
        return;
    end
    mlrelease=matlabshared.supportpkg.internal.getCurrentRelease();
    relTag=matlabshared.supportpkg.internal.util.getReleaseTag(mlrelease,'matchcase');

    spPkgLabel='SupportPackages';

    if ispc
        spRootSubPath=fullfile('MATLAB',spPkgLabel,relTag);

        programData=getenv('PROGRAMDATA');

        if~isempty(programData)
            defaultDirValue=fullfile(programData,spRootSubPath);
        else
            driveLetter=localGetDriveLetter(localGetTmpLoc());
            defaultDirValue=localConstructDefaultRootWithDriveLetter(driveLetter,spRootSubPath);
        end
    else
        spFolder_unix=fullfile(spPkgLabel,relTag);

        upath=userpath;
        upath=regexp(upath,pathsep,'split');
        upath(cellfun(@isempty,upath))=[];

        if numel(upath)~=1||~isdir(upath{1})
            defaultDirValue=fullfile(system_dependent('getuserworkfolder','default'),spFolder_unix);
        else
            defaultDirValue=fullfile(upath{1},spFolder_unix);
        end
    end
end


function tmp_dir=localGetTmpLoc()

    if ispc
        tmp_dir=getenv('TEMP');
    else
        tmp_dir='';
    end

    if(isempty(tmp_dir))
        tmp_dir=getenv('TMP');
    end

    if(isempty(tmp_dir))
        if ispc
            tmp_dir=pwd;
        else
            tmp_dir='/tmp/';
        end
    end

    if(tmp_dir(end)~=filesep)
        tmp_dir=[tmp_dir,filesep];
    end
end


function value=localGetDriveLetter(inputDir)

    validateattributes(inputDir,{'char','string'},{'nonempty','scalartext'});
    value='';
    if(ispc()&&~isempty(inputDir)&&strcmp(inputDir(2),':'))
        value=inputDir(1);
    end
end


function defaultRoot=localConstructDefaultRootWithDriveLetter(driveLetter,spRootSubPath)

    validateattributes(driveLetter,{'char','string'},{'scalartext'});
    validateattributes(spRootSubPath,{'char','string'},{'nonempty','scalartext'});
    if~isempty(driveLetter)
        defaultRoot=fullfile([driveLetter,':'],spRootSubPath);
    else
        defaultRoot=fullfile('C:',spRootSubPath);
    end
end