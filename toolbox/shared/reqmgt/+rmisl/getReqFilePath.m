function out=getReqFilePath(slModel,isInteractive)

    out={};
    reqFile=[];

    if nargin<2
        isInteractive=false;
    end

    [mdlDir,mdlName]=fileparts(slModel);

    if isempty(mdlDir)
        try
            if strcmp(get_param(mdlName,'hasReqInfo'),'on')

                return;
            else
                mdlPath=get_param(mdlName,'FileName');
                reqFile=checkForReqFile(mdlPath);
            end
        catch ex %#ok<NASGU>

            if exist(mdlName,'file')==4
                reqFile=checkForReqFile(which(mdlName));
            end
        end
    elseif exist(slModel,'file')

        reqFile=checkForReqFile(slModel);
    end

    if~isempty(reqFile)
        if isInteractive
            rmidata.saveIfHasChanges(mdlName);
        else
            try
                modelH=get_param(mdlName,'Handle');
                if slreq.hasChanges(modelH)
                    MSLDiagnostic('Slvnv:rmidata:map:DependencyOutOfDate',reqFile,mdlName).reportAsWarning;
                end
            catch ex %#ok<NASGU>

            end
        end
    end
    linkSets=checkExternalMATLABCode(mdlName);
    if~isempty(reqFile)
        out=[{reqFile},linkSets];
    else
        out=linkSets;
    end
end


function linkFile=checkForReqFile(mdlPath)
    linkPath=rmimap.StorageMapper.getInstance.getStorageFor(mdlPath);

    linkFile=[];
    if exist(linkPath,'file')==2
        linkFile=linkPath;
    else
        if(strcmpi(linkPath((end-4):end),'.slmx'))
            [fDir,fName,fExt]=fileparts(mdlPath);
            oldReqFile=rmimap.StorageMapper.legacyReqPath(fDir,fName,fExt);
            if exist(oldReqFile,'file')==2
                linkFile=oldReqFile;
            end
        end
    end
end


function linkSets=checkExternalMATLABCode(modelName)
    linkSets={};
    try
        info=sfprivate('getRebuildInfoForMFiles',modelName,'rtw');
        if~isempty(info)&&isfield(info,'resolved')&&isfield(info.resolved,modelName)
            resolvedInfo=info.resolved.(modelName);
            resolvedFcnInfo=resolvedInfo.resolvedFunctionsInfo;
            if~isempty(resolvedFcnInfo)
                reqData=slreq.data.ReqData.getInstance();
                for n=1:length(resolvedFcnInfo)
                    extFun=resolvedFcnInfo(n).resolved;

                    extFun=regexprep(extFun,'^\[.+\]','');
                    dataLinkSet=reqData.getLinkSet(extFun);
                    if~isempty(dataLinkSet)
                        linkSets{end+1}=dataLinkSet.filepath;%#ok<AGROW>
                    end
                end
            end
        end
    catch

    end
end
