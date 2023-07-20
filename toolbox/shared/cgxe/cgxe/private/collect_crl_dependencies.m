function auxInfo=collect_crl_dependencies(tflControl,targetDirName,auxInfo)







    if isempty(auxInfo)
        auxFileEmpty=struct('FileName',{},'FilePath',{},'Group',{});
        auxPathEmpty=struct('FilePath',{},'Group',{});
        auxInfo=struct('sourceFiles',auxFileEmpty,...
        'includeFiles',auxFileEmpty,...
        'includePaths',auxPathEmpty,...
        'linkObjects',auxFileEmpty,...
        'linkFlags',auxFileEmpty);
    end

    if~isempty(targetDirName)
        tflControl.runFcnImpCallbacks(targetDirName);
    end
    hitCache=tflControl.HitCache;
    numEnts=length(hitCache);
    S=@(name)struct('FileName',name,'FilePath','','Group','TFL');
    SP=@(name,pname)struct('FileName',name,'FilePath',pname,'Group','TFL');
    P=@(path)struct('FilePath',path,'Group','TFL');
    for idx=1:numEnts
        if hitCache(idx).RecordedUsageCount~=0
            hit=hitCache(idx);
            name=hit.Implementation.SourceFile;


            if~isempty(name)&&~isGpuCoderSimEntry(hit)
                auxInfo.sourceFiles(end+1)=S(name);
            end
            for i=1:numel(hit.AdditionalSourceFiles)
                name=hit.AdditionalSourceFiles{i};
                if~isempty(name)
                    auxInfo.sourceFiles(end+1)=S(name);
                end
            end
            for i=1:numel(hit.AdditionalHeaderFiles)
                name=hit.AdditionalHeaderFiles{i};
                if~isempty(name)
                    auxInfo.includeFiles(end+1)=S(name);
                end
            end
            for i=1:numel(hit.AdditionalIncludePaths)
                name=RTW.expandToken(hit.AdditionalIncludePaths{i});

                if~isempty(name)
                    auxInfo.includePaths(end+1)=P(name);
                end
            end
            for i=1:numel(hit.AdditionalLinkObjs)
                name=hit.AdditionalLinkObjs{i};
                pname=RTW.expandToken(hit.AdditionalLinkObjsPaths{i});
                if~isempty(name)
                    auxInfo.linkObjects(end+1)=SP(name,pname);
                end
            end
            for i=1:numel(hit.AdditionalLinkFlags)
                name=hit.AdditionalLinkFlags{i};
                if~isempty(name)
                    auxInfo.linkFlags(end+1)=S(name);
                end
            end
        end
    end

    function output=isGpuCoderSimEntry(entry)
        output=false;
        gpuCoderTableUids={'private_cuda_sim_tfl_table_tmw.mat:None',...
        'private_cuda_cpu_sim_tfl_table_tmw.mat:None'};
        for i=1:numel(gpuCoderTableUids)
            if strcmp(entry.UID,gpuCoderTableUids{i})
                output=true;
                return;
            end
        end
