function ssc_cleanimpl(varargin)






    [fileDir,libraryName]=ssc_screeninput('ssc_clean',varargin{:});
    originalDir=cd(fileDir);
    BuildDirCleanup=onCleanup(@()cd(originalDir));

    mdlName=[libraryName,'_lib'];
    if bdIsLoaded(mdlName)
        pm_error('physmod:simscape:simscape:ssc_clean:LibraryInUse',libraryName,mdlName);
    end

    try
        disp(pm_message('physmod:simscape:simscape:ssc_clean:CleanLibrary',libraryName,mdlName));
        warnstat=warning('query','all');
        warning('off','MATLAB:DELETE:FileNotFound');
        warning('off','MATLAB:DELETE:Permission');

        isInternalPackage=ne_private('ne_isinternalpackage');
        if isInternalPackage(fileDir,libraryName)
            pm_error('physmod:simscape:simscape:ssc_clean:InternalPackage',libraryName);
        end
        cleanFcn=@lClean;
        cleanFcn(['+',libraryName]);
        warning(warnstat);
    catch e
        warning(warnstat);
        rethrow(e);
    end

end



function lClean(pkg)





    lValidateRunningModels();

    pm_clear;


    cleanPackage=ne_private('ne_cleanpackage');
    remainingDirsMl=cleanPackage(pkg,true);


    cleanSimulinkLibrary=nesl_private('nesl_cleanpackage');
    remainingDirsSl=cleanSimulinkLibrary(pkg);


    remainingDirs=unique({remainingDirsMl{:},remainingDirsSl{:}});%#ok<CCAT>


    if~isempty(remainingDirs)
        str='';
        for idx=1:numel(remainingDirs)
            if exist(remainingDirs{idx},'dir')
                str=sprintf('%s%s\n',str,remainingDirs{idx});
            end
        end
        if~isempty(str)
            pm_error('physmod:simscape:simscape:ssc_clean:CouldNotDeleteDirs',str);
        end
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
        pm_error('physmod:simscape:simscape:ssc_clean:ModelsRunning',runningMdlsStr);
    end

end



