function ne_protectpackage(pkg,map,treatMissingAsOutOfDate,forceUpdate,postProtect)




















    persistent EXTMAP;
    if isempty(EXTMAP)
        EXTMAP=struct('ssc','sscp',...
        'm','p');
    end

    if nargin<5
        postProtect=@(~,~)true;
    end

    c=onCleanup(lCleanup());

    parseLibraryPackage=ne_private('ne_parselibrarypackage');
    libHelpers=parseLibraryPackage(fullfile(pwd,pkg));
    for idx=1:numel(libHelpers)
        libHelper=libHelpers{idx};

        sourceFile=libHelper.SourceFile;
        [fileDir,fileBase,fileExt]=fileparts(sourceFile);
        if any(strcmp(fileBase,{'lib','sl_postprocess'}))
            continue;
        end




        if~isfield(EXTMAP,fileExt(2:end))
            continue;
        end

        if lIsSourceOutOfDate(sourceFile,EXTMAP,treatMissingAsOutOfDate,forceUpdate)
            if~isfield(map,fileExt(2:end))
                error('ne_protectlibrary:NOFUN',...
                'Cannot protect %s since there is no protection function',sourceFile);
            end
            protectedFile=fullfile(fileDir,[fileBase,'.',EXTMAP.(fileExt(2:end))]);
            protectFcn=map.(fileExt(2:end));
            delete(protectedFile);
            protectFcn(sourceFile,'-inplace');
            postProtect(sourceFile,protectedFile);
        end

    end

end

function isOutOfDate=lIsSourceOutOfDate(srcFile,EXTMAP,treatMissingAsOutOfDate,forceUpdate)




    [fileDir,fileBase,fileExt]=fileparts(srcFile);

    if~isfield(EXTMAP,fileExt(2:end))
        isOutOfDate=false;
        return;
    end

    if isstruct(treatMissingAsOutOfDate)
        if isfield(treatMissingAsOutOfDate,fileExt(2:end))
            treatMissingAsOutOfDate=treatMissingAsOutOfDate.(fileExt(2:end));
        else
            error('ne_protectpackage:NOFLAG',...
            'Cannot determine if ''%s'' is out of date',srcFile);
        end
    end

    pFile=fullfile(fileDir,[fileBase,'.',EXTMAP.(fileExt(2:end))]);
    pFileAttr=dir(pFile);
    srcFileAttr=dir(srcFile);

    pm_assert(~isempty(srcFileAttr),'Source file %s not found',srcFile);



    if treatMissingAsOutOfDate
        isOutOfDate=forceUpdate||(isempty(pFileAttr)||(pFileAttr.datenum<srcFileAttr.datenum));
    else
        isOutOfDate=~isempty(pFileAttr)&&(pFileAttr.datenum<srcFileAttr.datenum);
    end
end

function cleanupFcn=lCleanup()
    warnState=warning('off','MATLAB:DELETE:FileNotFound');
    function cleanFcn()
        warning(warnState);
    end
    cleanupFcn=@cleanFcn;
end

