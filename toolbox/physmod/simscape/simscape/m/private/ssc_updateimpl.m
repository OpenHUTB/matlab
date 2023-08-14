function ssc_updateimpl(varargin)






    [fileDir,libraryName]=ssc_screeninput('ssc_update',varargin{:});
    originalDir=cd(fileDir);
    BuildDirCleanup=onCleanup(@()cd(originalDir));

    try
        warnstat=warning('query','all');
        warning('off','MATLAB:DELETE:FileNotFound');
        warning('off','MATLAB:DELETE:Permission');


        isInternalPackage=ne_private('ne_isinternalpackage');
        if isInternalPackage(fileDir,libraryName)
            pm_error('physmod:simscape:simscape:ssc_update:InternalPackage',libraryName);
        end

        updateFcn=@lUpdate;
        updateFcn(['+',libraryName]);
        warning(warnstat);
    catch e
        warning(warnstat);
        rethrow(e);
    end
end


function lUpdate(pkg)





    lValidateRunningModels();

    pm_clear;

    [~,fileBase]=fileparts(pkg);

    pm_assert(strcmp(fileBase(1),'+'),'%s doesn''t start with a ''+''',fileBase);

    parseLibraryPackage=ne_private('ne_parselibrarypackage');
    libHelpers=parseLibraryPackage(pkg);

    update_script=fullfile(toolboxdir('physmod'),'simscape','simscape','scripts','updateBranches.pl');

    for idx=1:numel(libHelpers)

        [~,srcFileName,srcExt]=fileparts(libHelpers{idx}.SourceFile);
        if any(strcmp(srcFileName,{'sl_postprocess','lib'}))||strcmp(srcExt,'.sscx')||strcmp(srcExt,'.sscp')
            continue;
        end





        clear(libHelpers{idx}.SourceFile);


        copyfile(libHelpers{idx}.SourceFile,strcat(libHelpers{idx}.SourceFile,'.bak'));


        perl(update_script,libHelpers{idx}.SourceFile);

        clear(libHelpers{idx}.SourceFile);
    end


end

function lValidateRunningModels()


    openMdls=find_system('type','block_diagram');
    runningMdlsIndex=cellfun(@pmsl_ismodelrunning,openMdls);
    if any(runningMdlsIndex)
        runningMdls=openMdls(runningMdlsIndex);
        runningMdlsStr='';
        for idx=1:numel(runningMdls)
            runningMdlsStr=sprintf('%s''%s''\n',runningMdlsStr,runningMdls{idx});
        end
        pm_error('physmod:simscape:simscape:ssc_update:ModelsRunning',runningMdlsStr);
    end

end





