function[reqs,names,sources]=getReqsFromDD(vars)




    persistent lastCheckNoData
    if isempty(lastCheckNoData)
        lastCheckNoData=' ';
    end

    reqs=[];
    names={};
    sources={};
    isDD=strcmp({vars.SourceType},'data dictionary');
    if any(isDD)
        idx=find(isDD);
        for i=idx
            if strcmp(vars(i).Source,lastCheckNoData)
                continue;
            elseif~dictHasRmiData(vars(i).Source)
                lastCheckNoData=vars(i).Source;
                continue;
            end
            ddEntryStr=[vars(i).Source,'|Global.',vars(i).Name];
            ddReqs=rmide.getReqs(ddEntryStr);
            if~isempty(ddReqs)
                reqs=[reqs;ddReqs];%#ok<AGROW>
                names(end+1:end+length(ddReqs))={vars(i).Name};
                sources(end+1:end+length(ddReqs))={vars(i).Source};
            end
        end
    end
end

function tf=dictHasRmiData(ddFileName)

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(ddFileName);
    if~isempty(linkSet)
        tf=true;
    else

        if~rmiut.isCompletePath(ddFileName)
            ddFileName=which(ddFileName);
            if isempty(ddFileName)
                tf=false;
                return;
            end
        end

        [ddPath,ddBase,ddExt]=fileparts(ddFileName);

        linkFile=rmimap.StorageMapper.defaultLinkPath(ddPath,ddBase,ddExt);
        if exist(linkFile,'file')==2
            tf=true;
            return;
        end

        legacyLinkFiles=rmimap.StorageMapper.legacyLinkPaths(ddPath,ddBase,ddExt);
        for idx=1:numel(legacyLinkFiles)
            if exist(legacyLinkFiles{idx},'file')==2
                tf=true;
                return;
            end
        end

        legacyReqFile=rmimap.StorageMapper.legacyReqPath(artDir,artBase,artExt);
        tf=(exist(legacyReqFile,'file')==2);
    end
end


