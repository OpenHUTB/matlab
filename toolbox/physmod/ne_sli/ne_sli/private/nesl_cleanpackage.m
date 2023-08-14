function remainingDirs=nesl_cleanpackage(pkg,mdlName)







    c=onCleanup(lCleanup());

    libraryName=pkg(2:end);

    if nargin==1
        mdlName=[libraryName,'_lib'];
    end

    if~isempty(mdlName)
        if bdIsLoaded(mdlName)
            pm_error('physmod:ne_sli:nesl_cleanpackage:LibraryInUse',libraryName,mdlName);
        end
    end

    try
        pm_clear;

        if~isempty(mdlName)
            pmsl_deletemodel=pmsl_private('pmsl_deletemodel');
            pmsl_deletemodel(mdlName);
        end
        remainingDirs=lDeleteSscprjDirs(pkg);
    catch e
        rethrow(e);
    end

end


function remainingDirs=lDeleteSscprjDirs(pkgName)


    parseLibraryPackage=ne_private('ne_parselibrarypackage');
    libHelpers=parseLibraryPackage(pkgName);
    remainingDirs={};

    for idx=1:numel(libHelpers)
        item=libHelpers{idx};
        getGenDir=ne_private('ne_gendir');
        [genDir,basename]=getGenDir(item.SourceFile);
        clear(item.SourceFile);




        if~any(strcmp(remainingDirs,genDir))
            if exist(genDir,'dir')
                remainingDirs{end+1}=genDir;%#ok<AGROW>
            else
                continue;
            end
        end

        deleteExt=lPlatformIndependentExtensions();
        for idxExt=1:numel(deleteExt)
            delete(fullfile(genDir,[basename,'.',deleteExt{idxExt}]));
        end
        dirContents=dir(genDir);
        if isempty(dirContents)||isequal({dirContents.name},{'.','..'})
            status=rmdir(genDir);
            if status
                remainingDirs(strcmp(remainingDirs,genDir))=[];%#ok<AGROW>
            end
        end
    end

end


function ext=lPlatformIndependentExtensions


    persistent pExt;

    if isempty(pExt)
        pExt={'pmdlg'};
    end

    ext=pExt;

end

function cleanupFcn=lCleanup()
    warnState=warning('off','MATLAB:DELETE:FileNotFound');
    function cleanFcn()
        warning(warnState);
    end
    cleanupFcn=@cleanFcn;
end



