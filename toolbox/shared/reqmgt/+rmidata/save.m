function savedFilePath=save(modelH,varargin)

    modelH=convertStringsToChars(modelH);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    savedFilePath='';

    if ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end

    if~slreq.data.ReqData.exists()
        return;
    end

    if rmisl.isComponentHarness(modelH,true)
        mainModel=Simulink.harness.internal.getHarnessOwnerBD(modelH);
        modelH=get_param(mainModel,'Handle');
    end
    artifactPath=get_param(modelH,'FileName');
    if isempty(artifactPath)

        return;
    end
    prevFileName=get_param(modelH,'PreviousFileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
    if isempty(linkSet)&&~isempty(prevFileName)
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(prevFileName);
    end

    if isempty(linkSet)
        return;
    end
    obs2clean=rmidata.embeddedObjCache('get',modelH);
    if~isempty(obs2clean)
        rmidata.cleanEmbeddedLinks(obs2clean);
    end
    if~isempty(prevFileName)&&~strcmp(prevFileName,artifactPath)
        wasDirty=linkSet.dirty;
        hasChanges=true;
        slreq.utils.renameLinkSet(prevFileName,artifactPath);

        if~wasDirty
            slreq.data.ReqData.getInstance.forceDirtyFlag(linkSet,false);
        end
    else
        hasChanges=linkSet.dirty;
        wasDirty=hasChanges;
    end

    if~hasChanges
        if~isempty(varargin)&&ischar(varargin{1})
            hasChanges=~strcmp(linkSet.filepath,varargin{1});
        elseif~slreq.utils.isEmbeddedLinkSet(linkSet.filepath)&&...
            exist(linkSet.filepath,'file')~=2
            [isInstalled,isLicensed]=rmi.isInstalled();
            hasChanges=isInstalled&&isLicensed;
        end
    end

    if hasChanges
        if wasDirty
            unsavedReqSets=linkSet.getUnsavedDependeeReqSets();
            goAhead=isempty(unsavedReqSets)||slreq.utils.saveWithPrompt(unsavedReqSets,linkSet.artifact);
        else
            goAhead=true;
        end

        if goAhead
            linkSet.save(varargin{:});
            savedFilePath=linkSet.filepath;
        end
    end

end






