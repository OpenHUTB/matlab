function clean_and_update_checksum_data(infoFileName,cksumDir,usedChecksums,accessInfoStruct)
    if nargin<4
        accessInfoStruct=[];
        autoInfer=false;
    else
        autoInfer=true;
    end

    matfileName=fullfile(cksumDir,[infoFileName,'.mat']);
    threshold=cgxe('Options');
    if numel(usedChecksums)>threshold.maxFileThreshold&&~autoInfer

        cgxe('Options','maxFileThreshold',2*numel(usedChecksums));
        threshold.maxFileThreshold=2*numel(usedChecksums);
    end

    if exist(matfileName,'file')==2
        S=load(matfileName);
        accessInfoMap=S.accessInfoMap;
        if S.maxChecksumFiles>threshold.maxFileThreshold
            cgxe('Options','maxFileThreshold',S.maxChecksumFiles);
            threshold.maxFileThreshold=S.maxChecksumFiles;
        end
    else
        accessInfoMap=containers.Map('KeyType','char','ValueType','any');
    end



    utRealTime=etime(clock,datevec('01-Mar-2004'));
    for i=1:numel(usedChecksums)
        if isempty(accessInfoStruct)
            if isKey(accessInfoMap,usedChecksums{i})
                accessInfo=accessInfoMap(usedChecksums{i});
                accessInfo.accessCount=accessInfo.accessCount+1;
            else
                accessInfo.creationTime=utRealTime;
                accessInfo.accessCount=1;
            end
            accessInfo.lastAccessTime=utRealTime;
        else
            accessInfo.creationTime=accessInfoStruct{i}.creationTime;
            accessInfo.accessCount=accessInfoStruct{i}.accessCount;
            accessInfo.lastAccessTime=accessInfoStruct{i}.lastAccessTime;
        end
        accessInfoMap(usedChecksums{i})=accessInfo;
    end


    try
        dirChecksumFiles=dir(fullfile(cksumDir,'*.mat'));
        usedChecksumFiles=strcat(usedChecksums,'.mat');
        unusedChecksumFiles=setdiff({dirChecksumFiles.name},usedChecksumFiles);
        unusedChecksums=regexprep(unusedChecksumFiles,'\.mat$','');
        unusedChecksums=setdiff(unusedChecksums,infoFileName);



        if numel(dirChecksumFiles)>threshold.maxFileThreshold
            for i=1:numel(unusedChecksums)
                accessInfo=accessInfoMap(unusedChecksums{i});
                if utRealTime-accessInfo.lastAccessTime>threshold.maxFileDaysOldThreshold*24*60*60
                    delete_checksum_artifacts(cksumDir,unusedChecksums{i});
                    remove(accessInfoMap,unusedChecksums{i});
                end
            end
        end


    catch ME
    end

    try
        maxChecksumFiles=threshold.maxFileThreshold;
        save(matfileName,'accessInfoMap','maxChecksumFiles');
    catch ME
    end


    function delete_checksum_artifacts(cksumDir,cksum)
        cksumfiles=dir(fullfile(cksumDir,sprintf('*%s*',cksum)));
        for i=1:numel(cksumfiles)
            if cksumfiles(i).isdir
                rmdir(fullfile(cksumDir,cksumfiles(i).name),'s');
            else
                delete(fullfile(cksumDir,cksumfiles(i).name));
            end
        end

        function val=is_top_model_in_mdl_ref_hierarchy(modelName)
            val=true;
            if(strcmp(get_param(modelName,'ModelReferenceTargetType'),'SIM')&&...
                strcmp(get_param(modelName,'ModelReferenceSimTargetType'),'Normal'))
                mdlrefPath=get_param(modelName,'ModelReferenceNormalModeVisibilityBlockPath');
                if~isempty(mdlrefPath)

                    topParent=bdroot(mdlrefPath.getBlock(1));
                    val=strcmp(modelName,topParent);
                end
            end
