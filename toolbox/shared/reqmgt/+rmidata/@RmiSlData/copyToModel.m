function[total_linked,total_links]=copyToModel(this,modelH,varargin)





    if~this.hasData(modelH)
        error(message('Slvnv:rmidata:RmiSlData:NoDataForModel',get_param(modelH,'Name')));
    end




    filterSettings=rmi.settings_mgr('get','filterSettings');
    if~isfield(filterSettings,'linkedOnly')
        filterSettings.linkedOnly=true;
    end
    originalFilters=filterSettings;
    filterSettings.enabled=false;
    filterSettings.linkedOnly=false;
    rmi.settings_mgr('set','filterSettings',filterSettings);


    allObjs=rmisl.getObjWithReqs(modelH);
    total_linked=length(allObjs);
    total_links=0;


    staleHarnessHandles=[];
    total_linked_in_harness=0;

    if Simulink.harness.internal.hasActiveHarness(modelH)
        error(message('Slvnv:rmidata:export:CantExportWhenHarnessOpen',openHarnessInfo(1).name));
    end

    harnessInfo=Simulink.harness.find(modelH);

    for i=1:length(harnessInfo)
        total_linked_in_harness=total_linked_in_harness+countLinkedItemsInHarness(harnessInfo(i));
    end


    if total_linked==0&&total_linked_in_harness==0
        rmi.settings_mgr('set','filterSettings',originalFilters);
        if isempty(varargin)
            set_param(modelH,'hasReqInfo','on');
            rmidata.storageModeCache('set',modelH,false);
        end
        return;
    end




    if isempty(varargin)
        otherModel='';
        isGUI=true;
    else
        otherModel=varargin{1};
        isGUI=varargin{2};
        thisModelName=get_param(modelH,'Name');
    end



    annotationAction=0;
    linkedAnnotations=rmidata.checkForLinkedAnnotations(modelH,false,isGUI);
    if~isempty(linkedAnnotations)
        if isGUI

            if isempty(otherModel)
                reply=questdlg({...
                getString(message('Slvnv:rmidata:RmiSlData:CannotCopyAnnotationLinks')),...
                getString(message('Slvnv:rmidata:RmiSlData:SkipOrMove'))},...
                getString(message('Slvnv:rmidata:RmiSlData:ProblemCopyingLinks')),...
                getString(message('Slvnv:rmidata:RmiSlData:Move')),...
                getString(message('Slvnv:rmidata:RmiSlData:Skip')),...
                getString(message('Slvnv:rmidata:RmiSlData:Cancel')),...
                getString(message('Slvnv:rmidata:RmiSlData:Move')));
            else
                reply=questdlg({...
                getString(message('Slvnv:rmidata:RmiSlData:CannotCopyAnnotationLinks')),...
                getString(message('Slvnv:rmidata:RmiSlData:SkipOrMove'))},...
                getString(message('Slvnv:rmidata:RmiSlData:ProblemCopyingLinks')),...
                getString(message('Slvnv:rmidata:RmiSlData:Move')),...
                getString(message('Slvnv:rmidata:RmiSlData:Skip')),...
                getString(message('Slvnv:rmidata:RmiSlData:Move')));
            end
            if isempty(reply)
                if isempty(otherModel)
                    MSLDiagnostic('Slvnv:rmidata:RmiSlData:CanceledByUser').reportAsWarning;
                    rmi.settings_mgr('set','filterSettings',originalFilters);
                    return;
                else

                    MSLDiagnostic('Slvnv:rmidata:RmiSlData:SkippingLinksOnAnnotations').reportAsWarning;
                    annotationAction=-1;
                end
            elseif strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Skip')))
                annotationAction=-1;
            elseif strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Move')))
                annotationAction=1;
            else
                rmi.settings_mgr('set','filterSettings',originalFilters);
                return;
            end
        else

            MSLDiagnostic('Slvnv:rmidata:RmiSlData:SkippingLinksOnAnnotations').reportAsWarning;
            annotationAction=-1;
        end
    end


    for i=1:total_linked



        objH=allObjs(i);
        if isa(objH,'double')&&floor(objH)==objH
            isSf=true;
        else
            isSf=false;
        end


        [reqs,groupReqCnt]=getReqsForItem(this,objH,isSf,modelH);


        if isempty(otherModel)
            targetObjH=objH;
        else
            targetObjH=findMatchingObj(objH,isSf,thisModelName,otherModel);
        end

        if setReqsForItem(targetObjH,isSf,modelH,reqs,groupReqCnt,annotationAction)
            total_links=total_links+length(reqs);
        end
    end


    if~isempty(harnessInfo)
        [staleHarnessHandles,total_links]=moveHarnessLinks(this,modelH,harnessInfo,total_links,annotationAction);
    end




    rmi.settings_mgr('set','filterSettings',originalFilters);




    if isempty(otherModel)
        set_param(modelH,'hasReqInfo','on');
        rmidata.storageModeCache('set',modelH,false);
        this.discard(modelH);
        if~isempty(staleHarnessHandles)
            for i=1:length(staleHarnessHandles)
                rmidata.storageModeCache('remove',staleHarnessHandles(i),false);
                this.discard(staleHarnessHandles(i));
            end
        end
    else
        set_param(get_param(otherModel,'Handle'),'hasReqInfo','on');
    end

    if isempty(otherModel)&&~isempty(linkedAnnotations)

        if strcmp(get_param(modelH,'ReqHilite'),'on')
            for i=1:length(linkedAnnotations)
                set_param(linkedAnnotations(i),'HiliteAncestors','fade');
            end
            rmisl.highlight(modelH);
        end
    end

    total_linked=total_linked+total_linked_in_harness;
end

function count=countLinkedItemsInHarness(harnessInfo)
    myID=[harnessInfo.model,':',harnessInfo.uuid];
    linkedIds=rmimap.getNodeIds(myID,true);
    count=length(linkedIds);
end

function[staleHarnessHandles,total_links]=moveHarnessLinks(this,modelH,harnessInfo,total_links,annotationAction)
    staleHarnessHandles=[];
    mdlName=get_param(modelH,'Name');
    harnessSubroots=rmidata.RmiSlData.getSubrootIDs(mdlName,'linktype_rmi_simulink');
    for i=1:length(harnessSubroots)
        [ownerPath,harnessName,isExternal,ownerType]=openHarnessById(harnessInfo,harnessSubroots{i});
        if isempty(ownerPath)
            continue;
        end
        isSubsystemHarness=strcmp(ownerType,'Simulink.Subsystem');
        if isSubsystemHarness
            Simulink.harness.internal.setBDLock(modelH,false);
        end
        harnessH=get_param(harnessName,'Handle');
        harnessID=[mdlName,harnessSubroots{i}];
        linkedIds=rmimap.getNodeIds(harnessID,true);

        sigBuilderDone='';
        for j=length(linkedIds):-1:1
            oneId=linkedIds{j};

            if strcmp(oneId,sigBuilderDone)
                continue;

            elseif any(oneId=='.')
                sigBuilderId=strtok(oneId,'.');
                if strcmp(sigBuilderId,sigBuilderDone)
                    continue;
                end
                [reqs,groups]=this.getSubIds(harnessID,sigBuilderId);
                if isempty(reqs)
                    groupReqCnt=[];
                else
                    lastGroup=max(groups);
                    groupReqCnt=zeros(1,lastGroup);
                    for k=1:lastGroup
                        groupReqCnt(k)=sum(groups==k);
                    end
                end


                sigBuilderDone=sigBuilderId;

            else
                sigBuilderId='';
                groupReqCnt=[];
                reqs=rmimap.RMIRepository.getInstance.getData(harnessID,oneId);
            end

            if~isempty(reqs)


                if isempty(sigBuilderId)
                    sid=rmisl.harnessIdToEditorName([harnessID,oneId],false);
                else
                    sid=rmisl.harnessIdToEditorName([harnessID,sigBuilderId],false);
                end
                try
                    objH=Simulink.ID.getHandle(sid);
                    if isa(objH,'Stateflow.Object')
                        objH=objH.Id;
                        isSf=true;
                    else
                        isSf=false;
                    end
                catch

                    continue;
                end


                if setReqsForItem(objH,isSf,harnessH,reqs,groupReqCnt,annotationAction)
                    total_links=total_links+length(reqs);
                end
            end
        end
        staleHarnessHandles(end+1)=harnessH;%#ok<AGROW>
        if isSubsystemHarness
            Simulink.harness.internal.setBDLock(modelH,true);
        end
        close_system(harnessName,isExternal);
    end
end

function[reqs,groupReqCnt]=getReqsForItem(this,objH,isSf,modelH)
    if~isSf&&rmisl.is_signal_builder_block(objH)
        [groupReqCnt,~,reqs]=this.getSubGroups(objH);
    else
        [~,id]=rmidata.getRmiKeys(objH,isSf);
        reqs=this.repository.getData(modelH,id);
        groupReqCnt='';
    end
end

function success=setReqsForItem(targetObjH,isSf,modelH,reqs,groupReqCnt,annotationAction)
    success=true;
    if~isSf
        if~isempty(groupReqCnt)
            setStructReqs(targetObjH,false,modelH,reqs,-1,-1,groupReqCnt);
        elseif annotationAction~=0&&strcmp(get_param(targetObjH,'type'),'annotation')
            if annotationAction>0

                targetParentDiagram=get_param(targetObjH,'Parent');
                targetParentH=get_param(targetParentDiagram,'Handle');
                targetParentReqsStr=rmi.getRawReqs(targetParentH,isSf);
                targetParentReqs=rmi.parsereqs(targetParentReqsStr);
                setStructReqs(targetParentH,false,modelH,[targetParentReqs;reqs]);
            else

                success=false;
            end
        else

            setStructReqs(targetObjH,false,modelH,reqs);
        end
    else

        setStructReqs(targetObjH,true,modelH,reqs);
    end
end

function[ownerPath,harnessName,isExternal,ownerType]=openHarnessById(allHarnessInfo,harnessID)
    match=find(strcmp({allHarnessInfo(:).uuid},harnessID(2:end)));
    if length(match)~=1
        ownerPath='';
        harnessName='';
        return;
    end
    harnessName=allHarnessInfo(match).name;
    ownerPath=allHarnessInfo(match).ownerFullPath;
    isExternal=allHarnessInfo(match).saveExternally;
    ownerType=allHarnessInfo(match).ownerType;
    Simulink.harness.open(ownerPath,harnessName);
end


function dstObj=findMatchingObj(srcH,isSf,srcMdlName,dstMdlName)
    [modelName,objKey]=rmidata.getRmiKeys(srcH,isSf);
    if strcmp(modelName,srcMdlName)
        if strcmp(objKey,':')
            dstKey=dstMdlName;
        else
            dstKey=[dstMdlName,objKey];
        end
    else
        error(message('Slvnv:rmidata:RmiSlData:MismatchedMdlName',srcMdlName));
    end
    dstObj=Simulink.ID.getHandle(dstKey);
    if isSf
        dstObj=dstObj.Id;
    end








end


function setStructReqs(objH,isSf,modelH,structArray,varargin)


    reqstr=rmi.reqs2str(structArray);


    GUID=rmi.guidGet(objH);


    if isempty(reqstr)
        reqstr='{} ';
    end
    reqstr=[reqstr,' %',GUID];


    rmi.setRawReqs(objH,isSf,reqstr,modelH);

    if~isempty(varargin)
        vnv_panel_mgr('sbUpdateReq',objH,varargin{:});
    end

end
