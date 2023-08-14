function remainingDirs=ne_cleanpackage(pkg,deleteAll,deletePlatformIndependent,deletePlatformDependent)











    cleanupVar=onCleanup(lCleanupFcn());


    pm_assert((nargin==2||nargin==4),'must provide 2 or 4 argument');

    if nargin==2&&~deleteAll
        deletePlatformIndependent=true;
        deletePlatformDependent=true;
    end


    pm_assert(~(nargin==4&&deleteAll),'delete all flag must be false if 4 arguments are provided');

    pkgName=pkg;

    libHelpers=ne_parselibrarypackage(pkgName);
    remainingDirs={};

    for idx=1:numel(libHelpers)
        item=libHelpers{idx};
        [genDir,basename]=ne_gendir(item.SourceFile);
        clear(item.SourceFile);




        if deleteAll
            if~any(strcmp(remainingDirs,genDir))
                if exist(genDir,'dir')
                    remainingDirs{end+1}=genDir;%#ok<AGROW>
                else
                    continue;
                end
            end
            delete(fullfile(genDir,[basename,'.*']));
        else

            platformIndptExt={};
            platformExt={};
            if deletePlatformIndependent
                platformIndptExt=lPlatformIndependentExtensions();
            end
            if deletePlatformDependent
                platformExt=lPlatformDependentExtensions();
            end
            deleteExt={platformIndptExt{:},platformExt{:}};%#ok<CCAT>
            for idxExt=1:numel(deleteExt)
                delete(fullfile(genDir,[basename,'.',deleteExt{idxExt}]));
            end
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


    ext={};
end

function ext=lPlatformDependentExtensions


    persistent pExt;

    if isempty(pExt)
        pExt={mexext,[mexext,'.md5']};
    end

    ext=pExt;

end

function cleanupFcn=lCleanupFcn

    warnstate=warning('off','MATLAB:DELETE:FileNotFound');
    function restore()
        warning(warnstate);
    end
    cleanupFcn=@restore;

end
