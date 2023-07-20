function selections=resolveComponentSelection(this)



















    selections={};

    markups=this.Markups;










    [~,~,modelHandle]=slreq.utils.DAStudioHelper.getCurrentBDHandle();
    if strcmp(get_param(modelHandle,'isHarness'),'on')
        if locIsSLTestLicensed
            ownerName=Simulink.harness.internal.getHarnessOwnerBD(modelHandle);
            modelHandle=get_param(ownerName,'Handle');
        end
    end

    for i=1:length(markups)
        markup=markups(i);
        ownerHandle=markup.ownerHandle;
        if locBelongToModel(ownerHandle,modelHandle)

            selections{end+1}=markup.markupItem;%#ok<AGROW>
            markupConnectors=markup.Connectors;
            for j=1:length(markupConnectors)
                selections{end+1}=markupConnectors(j).connectorItem;%#ok<AGROW>
            end
        end
    end

    inLinks=this.getLinks;

    if isempty(inLinks)

        updateSystemComposer({},modelHandle);
    end

    for j=1:length(inLinks)
        try
            inLink=inLinks(j);

            inLinkSource=inLink.source;
            switch inLinkSource.domain
            case 'linktype_rmi_simulink'
                srcObj=resolveSimulinkObjBySID(inLinkSource.getSID);
                if~isempty(srcObj)
                    selections=[selections,srcObj];%#ok<AGROW>

                    for sindex=1:length(srcObj)
                        cSrcObj=srcObj{sindex};
                        if isa(cSrcObj,'Stateflow.Transition')


                            transInfo=slreq.utils.getTransitionViewerList(cSrcObj.Id);
                            if~isempty(transInfo)
                                selections=[selections,{transInfo.subtranID}];%#ok<AGROW>
                            end
                        end
                    end
                else
                    if sysarch.isZCElement(inLinkSource.id)
                        modelName=get_param(modelHandle,'Name');
                        portHandles=sysarch.getPortHandleForReqHighlighting(inLinkSource.id,modelName);
                        for i=1:numel(portHandles)
                            selections=[selections,{get_param(portHandles(i),'Object')}];
                        end
                    end
                end
                updateSystemComposer(selections,modelHandle);
            end
        catch ex %#ok<NASGU>


        end
    end



    function item=resolveSimulinkObjBySID(sid)
        item={};
        try
            if rmisl.isHarnessIdString(sid)
                [~,srcHandle]=rmisl.resolveObjInHarness(sid);
            else
                srcHandle=Simulink.ID.getHandle(sid);
            end
            srcHandle=slreq.utils.getRMISLTarget(srcHandle,true,true);

            if~isempty(modelHandle)&&~isa(srcHandle,'Stateflow.Object')&&bdIsLibrary(bdroot(srcHandle))





                blockName=getfullname(srcHandle);


                allBlocks=find_system(modelHandle,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','FindAll','on',...
                'ReferenceBlock',blockName);

                allBlockHandles=get_param(allBlocks,'Handle');
                if iscell(allBlockHandles)
                    allSrcHandles=[allBlockHandles,srcHandle];
                else
                    allSrcHandles=[{allBlockHandles(:)},srcHandle];
                end
            else
                allSrcHandles={srcHandle};
            end

            for index=1:length(allSrcHandles)
                cSrcHandle=allSrcHandles{index};
                if locBelongToModel(cSrcHandle,modelHandle)



                    if isa(cSrcHandle,'Stateflow.Object')
                        cItem=cSrcHandle;
                    else
                        cItem=get_param(cSrcHandle,'Object');
                    end
                    item{end+1}=cItem;%#ok<AGROW>

                    [yesorno,harnessObj]=slreq.utils.doesObjectHaveCUTComponent(cSrcHandle);
                    if yesorno
                        if harnessObj.isSf
                            sr=sfroot;
                            item=[item,{sr.idToHandle(harnessObj.Id)}];%#ok<AGROW>
                        else
                            item=[item,{get_param(harnessObj.Id,'Object')}];%#ok<AGROW>
                        end
                    end
                end
            end
        catch


        end
    end
end

function out=locBelongToModel(srcHandle,modelH)
    if isempty(modelH)
        out=true;
        return;
    end
    try
        if isa(srcHandle,'Stateflow.Object')
            ownerHandle=get_param(bdroot(srcHandle.Machine.Name),'Handle');
        else
            ownerHandle=bdroot(srcHandle);
        end

        out=ownerHandle==modelH;


        if~out&&locIsSLTestLicensed



            activeHarness=Simulink.harness.internal.getActiveHarness(modelH);
            if~isempty(activeHarness)
                out=get_param(activeHarness.name,'Handle')==ownerHandle;
            end
        end
    catch ex %#ok<NASGU>

        out=true;
    end
end


function out=locIsSLTestLicensed

    out=license('test','Simulink_Test')&&...
    dig.isProductInstalled('Simulink Test');

end

function updateSystemComposer(srcObjs,modelHandle)

    if~strcmp(get_param(modelHandle,'SimulinkSubDomain'),'Architecture')&&...
        ~strcmp(get_param(modelHandle,'SimulinkSubDomain'),'SoftwareArchitecture')
        return;
    end


    appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelHandle);
    appMgr.getStyler().clear("requirement_highlight");


    objCount=length(srcObjs);
    componentUUIDs=strings(1,objCount);
    for sindex=1:objCount
        cSrcObj=srcObjs{sindex};
        component=systemcomposer.utils.getArchitecturePeer(cSrcObj.Handle);
        componentUUIDs(sindex)=component.UUID;
    end


    if objCount
        appMgr.getStyler().add(componentUUIDs,"requirement_highlight");
    end
end


