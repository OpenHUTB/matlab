classdef MarkupManager<handle









    properties
        appmgr;


uuid2DASObjMap
    end

    properties(Access=private)
        requirementDef;
client




        ignoreNotification=false;
    end

    properties(SetAccess={?slreq.das.Markup,?slreq.das.Link},GetAccess=public)
        ReqUuid2MarkupMap=containers.Map('KeyType','char','ValueType','Any');
        ModelHandle2cContentMap=containers.Map('KeyType','double','ValueType','Any');



        danglingMarkupMap=containers.Map('KeyType','char','ValueType','Any');
    end

    properties(Constant)
        clientDefName='SLRequirements';
        DefaultMarkupSize=[200,80];
        dragPolicies={'GLUE2.DiagramElement','CreateIfNew',...
        'SLM3I.Annotation','CreateIfNew',...
        'SLM3I.Block','CreateIfNew',...
        'SLM3I.Port','UseCustomDragDropActionFcn',...
        'StateflowDI.Chart','CreateIfNew',...
        'StateflowDI.Junction','DontCreate',...
        'StateflowDI.Port','DontCreate',...
        'StateflowDI.State','CreateIfNew',...
        'StateflowDI.Subviewer','CreateIfNew',...
        'StateflowDI.Transition','CreateIfNew'};
        dropPolicies={'GLUE2.DiagramElement','CreateIfNew',...
        'SLM3I.Annotation','CreateIfNew',...
        'SLM3I.Block','CreateIfNew',...
        'SLM3I.Port','UseCustomDragDropActionFcn',...
        'StateflowDI.Chart','CreateIfNew',...
        'StateflowDI.Junction','DontCreate',...
        'StateflowDI.Port','DontCreate',...
        'StateflowDI.State','CreateIfNew',...
        'StateflowDI.Subviewer','CreateIfNew',...
        'StateflowDI.Transition','CreateIfNew'};
        hierarchyChange='slreq.utils.onHierarchyChange';
        propertyInspectorCallback='slreq.app.MarkupManager.objectToMCOS';
        removeDisconnectedMarkup=true;
        highlightStyleID='SLRequirementsTargetStyle';
    end

    methods(Static)
        function cleanupMarkupOnExit()
            try
                client=diagram.markup.getClient(slreq.app.MarkupManager.clientDefName);
                client.unregister;
            catch ME

            end
        end
    end

    methods
        function this=MarkupManager(mgr)
            this.appmgr=mgr;

            this.uuid2DASObjMap=containers.Map('KeyType','char','ValueType','Any');
        end

        function delete(this)



            this.uuid2DASObjMap.remove(this.uuid2DASObjMap.keys());


            values=this.ModelHandle2cContentMap.values;
            for i=1:length(values)
                if isvalid(values{i})
                    try
                        values{i}.remove;
                    catch
                    end
                end
            end
            this.ModelHandle2cContentMap.remove(this.ModelHandle2cContentMap.keys);

            if~isempty(this.client)




                this.client=[];
            end
        end

        function dasConnector=showConnector(this,dasLink,isDiagram)
            if isempty(this.client)
                this.registerClient();
            end
            dataLink=dasLink.dataModelObj;

            dasConnector=slreq.das.Connector.empty();
            if~checkIfAcceptableLink(dataLink)
                return;
            end


            dataConnector=dataLink.getConnector(isDiagram);
            if isempty(dataConnector)

                dataLink.addConnector(isDiagram);
                dataConnector=dataLink.getConnector(isDiagram);
            end

            dasConnector=addDasConnector(this,dataConnector,dasLink,isDiagram);
        end

        function[dasConnector,dasDiagram]=restoreConnectors(this,dasLink)

            if isempty(this.client)
                this.registerClient();
            end
            dataLink=dasLink.dataModelObj;

            dasConnector=slreq.das.Connector.empty();
            dasDiagram=slreq.das.Connector.empty();
            if~checkIfAcceptableLink(dataLink)
                return;
            end


            dataConnector=dataLink.getConnector(false);
            dataDiagramConnector=dataLink.getConnector(true);


            if~isempty(dataConnector)&&dataConnector.isVisible
                dasConnector=addDasConnector(this,dataConnector,dasLink,false);
            end


            if~isempty(dataDiagramConnector)&&dataDiagramConnector.isVisible
                dasDiagram=addDasConnector(this,dataDiagramConnector,dasLink,true);
            end
        end

        function markup=getReqMarkup(this,reqUuid,systemPathOrHandle)
            markup=slreq.das.Markup.empty;

            if ischar(systemPathOrHandle)
                hdl=Simulink.ID.getHandle(systemPathOrHandle);
            else
                hdl=systemPathOrHandle;
            end
            if isa(hdl,'Stateflow.Object')
                hdl=hdl.Id;
            end
            if isKey(this.ReqUuid2MarkupMap,reqUuid)




                existingMarkupObj=this.ReqUuid2MarkupMap(reqUuid);
                for n=1:length(existingMarkupObj)
                    if existingMarkupObj(n).ownerHandle==hdl
                        markup=existingMarkupObj(n);
                        return;
                    end
                end
            end
        end

        function markup=getMarkupsByReqUuid(this,uuid)
            markup=slreq.das.Markup.empty();
            if this.ReqUuid2MarkupMap.isKey(uuid)
                markup=this.ReqUuid2MarkupMap(uuid);
            end
        end

        function showMarkupsAndConnectorsForModel(this,modelH)%#ok<INUSL>


            linkSet=slreq.utils.getLinkSet(get_param(modelH,'FileName'));

            if~isempty(linkSet)
                dasLinkSet=linkSet.getDasObject();
                if~isempty(dasLinkSet)
                    allLinks=dasLinkSet.children;
                    for n=1:length(allLinks)
                        thisLink=allLinks(n);
                        if thisLink.Source.isValid




                            thisLink.restoreConnectors();
                        end
                    end
                end
            end
        end


        function showMarkupsAndConnectorsForModelIfNeeded(this,modelH)
            [~,isCreated]=this.getClientContent(modelH);
            if isCreated


                this.showMarkupsAndConnectorsForModel(modelH);
            end
        end

        function showMarkupsAndConnectorsForHarnessModel(this,harnessModelH)%#ok<INUSL>


            ownerModelH=Simulink.harness.internal.getHarnessOwnerBD(harnessModelH);


            linkSet=slreq.utils.getLinkSet(get_param(ownerModelH,'FileName'));

            if~isempty(linkSet)
                dasLinkSet=linkSet.getDasObject();
                if~isempty(dasLinkSet)
                    allLinks=dasLinkSet.children;
                    for n=1:length(allLinks)
                        thisLink=allLinks(n);
                        if isSrcInHarness(thisLink.Source,harnessModelH)




                            thisLink.restoreConnectors();
                        end
                    end
                end
            end
        end

        function hideMarkupsAndConnectorsForModel(this,modelH)%#ok<INUSL>


            linkSet=slreq.utils.getLinkSet(get_param(modelH,'FileName'));
            if~isempty(linkSet)
                dasLinkSet=linkSet.getDasObject();
                if~isempty(dasLinkSet)&&isvalid(dasLinkSet)
                    for n=1:length(dasLinkSet.children)



                        dasLinkSet.children(n).hideConnectors(true);
                        dasLinkSet.children(n).hideConnectors(false);
                    end
                end
            end
        end

        function hideMarkupsAndConnectorsForHarnessModel(this,harnessModelH)%#ok<INUSL>



            ownerModelH=Simulink.harness.internal.getHarnessOwnerBD(harnessModelH);

            linkSet=slreq.utils.getLinkSet(get_param(ownerModelH,'FileName'));
            if~isempty(linkSet)
                dasLinkSet=linkSet.getDasObject();
                if~isempty(dasLinkSet)
                    allLinks=dasLinkSet.children;
                    for n=1:length(allLinks)
                        thisLink=allLinks(n);



                        if isSrcInHarness(thisLink.Source,harnessModelH)
                            thisLink.hideConnectors(true);
                            thisLink.hideConnectors(false);
                        end
                    end
                end
            end
        end

        function[cContent,isCreated]=getClientContent(this,systemPath)




            modelH=get_param(bdroot(systemPath),'handle');
            if isKey(this.ModelHandle2cContentMap,modelH)
                cContent=this.ModelHandle2cContentMap(modelH);
                isCreated=false;
            else


                isCreated=true;
                if isempty(this.client)
                    this.registerClient();
                end
                cContent=this.client.getClientContent(get_param(modelH,'Name'));
                cContent.Impl.registerObservingListener(@slreq.app.MarkupManager.onMarkupConnectorChange);
                this.ModelHandle2cContentMap(modelH)=cContent;
                harnessModel=Simulink.harness.internal.getActiveHarness(modelH);
                if~isempty(harnessModel)
                    harnessContent=this.client.getClientContent(harnessModel.name);
                    harnessContent.Impl.registerObservingListener(@slreq.app.MarkupManager.onMarkupConnectorChange);
                    this.ModelHandle2cContentMap(get_param(harnessModel.name,'Handle'))=harnessContent;
                end
            end
        end

        function removeClientContent(this,modelH)



            if isKey(this.ModelHandle2cContentMap,modelH)
                cContent=this.ModelHandle2cContentMap(modelH);
                if cContent.isvalid

                    cContent.remove;
                end
                this.ModelHandle2cContentMap.remove(modelH);
            end
        end

        function destroyMarkupsByUuids(this,uuids)

            if ischar(uuids)
                uuids={uuids};
            end
            for n=1:length(uuids)
                if this.ReqUuid2MarkupMap.isKey(uuids{n})
                    markups=this.ReqUuid2MarkupMap(uuids{n});


                    for m=1:length(markups)
                        conns=markups(m).Connectors;
                        for nConns=1:length(conns)
                            conns(nConns).isVisible=false;
                        end
                        markups(m).delete;
                    end
                end
            end
        end

        function setIgnoreNotificationFlag(this,tf)



            this.ignoreNotification=tf;
        end

        function setReqSetMarkupMap(this,markup)



            isDangling=true;
            dasReq=markup.Requirement;
            if~isempty(dasReq)
                dasReqSet=dasReq.RequirementSet;
                if~isempty(dasReqSet)
                    dasReqSet.MarkupReqSIDMap(dasReq.SID)=true;
                    isDangling=false;
                end
            end
            if isDangling

                dataLinks=markup.Links;
                if isKey(this.danglingMarkupMap,dataLinks(1).destUri)
                    thisMap=this.danglingMarkupMap(dataLinks(1).destUri);
                else
                    thisMap=containers.Map('KeyType','char','ValueType','Any');
                end

                thisMap(dataLinks(1).destId)=markup;
                this.danglingMarkupMap(dataLinks(1).destUri)=thisMap;
            end
        end

        function clearReqSetMarkupMap(this,markup)



            dasReq=markup.Requirement;
            if~isempty(dasReq)
                dasReqSet=dasReq.RequirementSet;
                if isKey(dasReqSet.MarkupReqSIDMap,dasReq.SID)
                    dasReqSet.MarkupReqSIDMap.remove(dasReq.SID);
                    return;
                end
            end

            dataLinks=markup.Links;
            assert(~isempty(dataLinks),'Markup should have at lease one link')
            destUri=dataLinks(1).destUri;
            destId=dataLinks(1).destId;
            if isKey(this.danglingMarkupMap,destUri)
                thisMap=this.danglingMarkupMap(destUri);
                if isKey(thisMap,destId)
                    thisMap.remove(destId);
                    if thisMap.Count==0

                        this.danglingMarkupMap.remove(destUri);
                    else

                        this.danglingMarkupMap(destUri)=thisMap;
                    end
                end
            end
        end

        function updateMarkupOnReqSetLoaded(this,dasReqSet)


            [~,baseName,ext]=fileparts(dasReqSet.Filepath);
            destUri=[baseName,ext];



            if isKey(this.danglingMarkupMap,destUri)
                danglinkMap=this.danglingMarkupMap(destUri);
                ids=danglinkMap.keys;
                if(~isempty(ids))
                    dasReqSet.createChildren();
                end
                for n=1:length(ids)
                    markups=danglinkMap(ids{n});
                    for m=1:length(markups)
                        this.clearReqSetMarkupMap(markups(m));
                        markups(m).update;
                    end
                end
            end
        end

        function updateMarkupOnReqSetDiscarded(this,dasReqSet)


            sidsWithMarkup=dasReqSet.MarkupReqSIDMap.keys;
            dataReqSet=dasReqSet.dataModelObj;
            [~,baseName,ext]=fileparts(dasReqSet.Filepath);
            destUri=[baseName,ext];
            if isKey(this.danglingMarkupMap,destUri)
                danglingMap=this.danglingMarkupMap(destUri);
            else
                danglingMap=containers.Map('KeyType','char','ValueType','Any');
            end
            for n=1:length(sidsWithMarkup)
                dataReq=dataReqSet.getItemFromID(sidsWithMarkup{n});
                dasReq=dataReq.getDasObject();
                markups=dasReq.Markups;
                for m=1:length(markups)
                    markups(m).displayUnresolvedMarkup();
                end
                danglingMap(dasReq.SID)=markups;
            end
            this.danglingMarkupMap(destUri)=danglingMap;
        end
    end

    methods

        function connectWithDasObjects(this,dataLink,isDiagram,mfMarkupItem,mfConnectorItem)

            dataConnector=dataLink.getConnector(isDiagram);
            if isempty(dataConnector)

                dataLink.addConnector(isDiagram);
                dataConnector=dataLink.getConnector(isDiagram);
            end

            reqUuid=this.getReqUuid(dataLink);
            dasLink=this.appmgr.getDasObjFromDataObj(dataLink);


            cInfo=this.getConnectionInfo(dataLink.source,isDiagram);
            dasMarkup=this.getReqMarkup(reqUuid,cInfo.OwnerHandle);

            if isempty(dasMarkup)

                dasMarkup=slreq.das.Markup(this,dataConnector.markup,dasLink,reqUuid,cInfo,mfMarkupItem);
            end

            dasConnector=slreq.das.Connector(this,dasLink,dasMarkup,reqUuid,cInfo,mfConnectorItem);

            dasMarkup.addConnector(dasConnector);
            dasLink.addConnector(dasConnector,isDiagram);
        end

        function removePendingGhost(this,modelHandle)
            cc=this.getClientContent(modelHandle);
            cc.removePending();
        end
    end

    methods(Access=private)

        function dasConnector=addDasConnector(this,dataConnector,dasLink,isDiagram)


            if isDiagram&&~isempty(dasLink.DiagramConnector)

                dasConnector=dasLink.DiagramConnector;
                return;
            elseif~isDiagram&&~isempty(dasLink.Connector)

                dasConnector=dasLink.Connector;
                return;
            end

            dataLink=dasLink.dataModelObj;
            reqUuid=this.getReqUuid(dataLink);

            cInfo=this.getConnectionInfo(dataLink.source,isDiagram);
            if isempty(cInfo.OwnerHandle)
                dasConnector=slreq.das.Connector.empty;
                return;
            end



            if isDiagram&&~cInfo.isSF&&strcmp(get_param(cInfo.SystemPath,'Type'),'block')&&strcmp(get_param(cInfo.SystemPath,'BlockType'),'ModelReference')
                dasConnector=slreq.das.Connector.empty;
                return;
            end


            dasMarkup=this.getReqMarkup(reqUuid,cInfo.OwnerHandle);
            if isempty(dasMarkup)||~dasMarkup.markupItem.isValid

                dasMarkup=slreq.das.Markup(this,dataConnector.markup,dasLink,reqUuid,cInfo,'');
            end

            dasConnector=slreq.das.Connector(this,dasLink,dasMarkup,reqUuid,cInfo,'');

            dasMarkup.addConnector(dasConnector);
        end

        function registerClient(this)

            try
                this.requirementDef=diagram.markup.ClientDefinition(this.clientDefName);
                this.client=diagram.markup.registerClient(this.requirementDef);
                slreq.cpputils.registerPreShutdownCallback('slreq.app.MarkupManager.cleanupMarkupOnExit()');
                this.requirementDef.setEnabledPolicy(@isEnabledForEditor);
                for i=1:length(this.dragPolicies)/2
                    index=(i-1)*2+1;
                    this.requirementDef.setDragActionPolicy(this.dragPolicies{index},this.dragPolicies{index+1});
                end
                for i=1:length(this.dropPolicies)/2
                    index=(i-1)*2+1;
                    this.requirementDef.setDropActionPolicy(this.dropPolicies{index},this.dropPolicies{index+1});
                end
                this.requirementDef.setDragActionCustomPolicy(@handleDragAndDrop);
                this.requirementDef.setDropActionCustomPolicy(@handleDragAndDrop);
                this.requirementDef.setCustomCreatePolicy(@handleCreateMarkup);
                this.requirementDef.setTargetHighlightStyle('',this.highlightStyleID);
                this.requirementDef.HierarchyChangeCallback=this.hierarchyChange;
                this.requirementDef.PropertyInspectorObjectCallback=this.propertyInspectorCallback;
                this.requirementDef.RemoveDisconnectedMarkup=this.removeDisconnectedMarkup;
            catch ex
                if strcmp(ex.identifier,'diagram_markup:markup:DuplicateClient')
                    this.client=diagram.markup.getClient(this.clientDefName);
                else
                    throw(ex);
                end
            end
        end

        function dasMarkup=resolveDasMarkupFromImplMarkup(this,markupImpl)



            dasMarkup=[];
            if isa(markupImpl,'diagram.markup.impl.MarkupItem')
                if isKey(this.ReqUuid2MarkupMap,markupImpl.clientItemId)
                    markups=this.ReqUuid2MarkupMap(markupImpl.clientItemId);
                    for m=1:length(markups)
                        if strcmp(markups(m).markupItem.presentationID,markupImpl.presentationID)
                            dasMarkup=markups(m);
                            break;
                        end
                    end
                end
            end
        end

        function dasConnector=resolveDasConnectorFromImplConnector(this,connectorImpl)%#ok<INUSL>



            dasConnector=[];

            if isa(connectorImpl,'diagram.markup.impl.MarkupConnector')
                dasLink=slreq.utils.findDASbyUUID(connectorImpl.clientItemId);
                if~isempty(dasLink)
                    thisConnector=dasLink.Connector;
                    diagramConnector=dasLink.DiagramConnector;
                    if~isempty(thisConnector)&&strcmp(thisConnector.connectorItem.presentationID,connectorImpl.presentationID)
                        dasConnector=thisConnector;
                    elseif~isempty(diagramConnector)&&strcmp(diagramConnector.connectorItem.presentationID,connectorImpl.presentationID)
                        dasConnector=diagramConnector;
                    end
                end
            end
        end

        function dasMarkup=findAndFixMovedMarkupAndConnector(this,markupImpl)









            dasMarkup=[];
            mfMarkupItem=diagram.markup.MarkupItem(markupImpl);
            mfNewConnectors=mfMarkupItem.getConnectors;
            if~isa(markupImpl,'diagram.markup.impl.MarkupItem')
                return;
            end

            if~isKey(this.ReqUuid2MarkupMap,markupImpl.clientItemId)
                return;
            end










            markups=this.ReqUuid2MarkupMap(markupImpl.clientItemId);
            for m=1:length(markups)
                mfOrigConnectors=markups(m).markupItem.getConnectors;
                if numel(mfNewConnectors)~=numel(mfOrigConnectors)


                    continue;
                end
                matchVec=false(1,numel(mfOrigConnectors));
                connMap=containers.Map('KeyType','char','ValueType','Any');
                for j=1:numel(mfNewConnectors)
                    thisNewClientID=mfNewConnectors(j).clientItemId;
                    for k=1:numel(mfOrigConnectors)
                        thisOrigClientID=mfOrigConnectors(k).clientItemId;
                        if strcmp(thisNewClientID,thisOrigClientID)
                            matchVec(j)=true;
                            connMap(thisOrigClientID)=mfNewConnectors(j);
                        end
                    end
                end
                if all(matchVec)


                    dasMarkup=markups(m);

                    dasMarkup.markupItem=mfMarkupItem;
                    dasMarkup.syncFromCanvasMarkup(true);
                    dasConnectors=dasMarkup.Connectors;
                    for j=1:length(dasConnectors)
                        if isKey(connMap,dasConnectors(j).linkUuid)
                            thisMfConnector=connMap(dasConnectors(j).linkUuid);
                            dasConnectors(j).connectorItem=thisMfConnector;
                            dasConnectors(j).ownerHandle=dasMarkup.ownerHandle;
                        end
                    end
                end
            end
        end
    end

    methods(Static)
        function result=objectToMCOS(markupClientItemID)

            try
                result=slreq.utils.findDASbyUUID(markupClientItemID);
            catch ex %#ok<NASGU>
                result=[];
            end
        end

        function schemas=RequirementsMarkupMenu(cbinfo)%#ok<INUSD>

            schemas={{@slreq.app.MarkupManager.hideMarkupContextMenu,''},...
            {@slreq.app.MarkupManager.selectMarkupContextMenu,''}};
        end

        function schema=hideMarkupContextMenu(cbinfo)%#ok<INUSD>

            schema=sl_action_schema;
            schema.label=getString(message('Slvnv:slreq:Hide'));
            schema.tag='Simulink:ReqMarkupMenuHide';
            schema.state='Enabled';
            schema.callback=@slreq.app.MarkupManager.hideMarkupContextMenuCallback;
            schema.userdata='';
        end

        function hideMarkupContextMenuCallback(cbinfo)

            if isa(cbinfo.domain,'StateflowDI.SFDomain')

                sysH=SFStudio.Utils.getSubviewerId(cbinfo);
            else
                sysH=SLStudio.Utils.getDiagramHandle(cbinfo);
            end
            mgr=slreq.app.MainManager.getInstance;
            mkupMgr=mgr.markupManager;

            parts=SLStudio.Utils.partitionSelection(cbinfo);
            markupItems=parts.markupItems;

            for n=1:length(markupItems)
                markup=mkupMgr.getReqMarkup(markupItems(n).clientItemId,sysH);


                delete(markup);
            end
        end

        function schema=selectMarkupContextMenu(cbinfo)

            schema=sl_action_schema;
            schema.label=getString(message('Slvnv:slreq:SelectInSp'));
            schema.tag='Simulink:ReqMarkupMenuSelect';
            if isUnresolved(cbinfo)
                schema.state='Disabled';
            else
                schema.state='Enabled';
            end
            schema.callback=@slreq.app.MarkupManager.selectMarkupContextMenuCallback;
            schema.userdata='';
        end

        function selectMarkupContextMenuCallback(cbinfo)

            mgr=slreq.app.MainManager.getInstance;
            markupItems=SLStudio.Utils.partitionSelection(cbinfo).markupItems;

            modelHandle=cbinfo.editorModel.Handle;
            spObj=mgr.getCurrentSpreadSheetObject(modelHandle);
            if~isempty(spObj)
                for n=1:length(markupItems)
                    reqObj=slreq.utils.findDASbyUUID(markupItems(n).clientItemId);
                    if~isempty(reqObj)


                        spObj.setSelectedObject(reqObj);
                        spObj.update();
                    end
                end
            end
        end

        function schemas=RequirementsConnectorMenu(cbinfo)%#ok<INUSD>

            schemas={{@slreq.app.MarkupManager.hideConnectorContextMenu,''}};
        end

        function schema=hideConnectorContextMenu(cbinfo)%#ok<INUSD>

            schema=sl_action_schema;
            schema.label=getString(message('Slvnv:slreq:Hide'));
            schema.tag='Simulink:ReqConnectorMenuHide';
            schema.state='Enabled';
            schema.callback=@slreq.app.MarkupManager.hideConnectorContextMenuCallback;
            schema.userdata='';
        end

        function hideConnectorContextMenuCallback(cbinfo)


            if isa(cbinfo.domain,'StateflowDI.SFDomain')

                sysH=SFStudio.Utils.getSubviewerId(cbinfo);
            else
                sysH=SLStudio.Utils.getDiagramHandle(cbinfo);
            end

            connectorItem=SLStudio.Utils.partitionSelection(cbinfo).markupConnectors;
            dasLink=slreq.utils.findDASbyUUID(connectorItem.clientItemId);



            dasLink.destoryConnectorFromSystem(sysH);
        end

        function cInfo=getConnectionInfo(sourceItem,isDiagram)

            cInfo=struct('SystemPath','','OwnerHandle',nan,'isSF',false,'SourceID','','isDiagram',isDiagram);
            parentSystem='';

            [~,mdlName,~]=fileparts(sourceItem.artifactUri);
            zcElem=sysarch.resolveZCElement(sourceItem.id,mdlName);




            if~isempty(zcElem)
                obj=[];
                if sysarch.isZCPort(zcElem)
                    artifactsid=sourceItem.id;



                    [obj,parentSystem]=sysarch.getPortHandleForMarkup(sourceItem.id,mdlName);
                end
            else



                artifactsid=sourceItem.getSID;
                if rmisl.isHarnessIdString(artifactsid)
                    [~,obj,artifactsid]=rmisl.resolveObjInHarness(artifactsid);
                else
                    obj=Simulink.ID.getHandle(artifactsid);
                end
                if~isDiagram
                    obj1=slreq.utils.getRMISLTarget(obj,true,true);
                    if~isequal(obj1,obj)
                        obj=obj1;
                        artifactsid=Simulink.ID.getSID(obj1);
                    end
                end
            end


            cInfo.SourceID=artifactsid;
            if isempty(obj)
                cInfo.OwnerHandle=[];
                return;
            end

            if isa(obj,'Stateflow.Object')
                cInfo.SourceID=obj.Id;
                cInfo.isSF=true;
                sfObj=getChartObject(obj,isDiagram);

                if isa(sfObj,'Stateflow.Chart')
                    cInfo.SystemPath=sfObj.Path;
                else
                    cInfo.SystemPath=[sfObj.Path,'/',sfObj.Name];
                end
                cInfo.OwnerHandle=sfObj.Id;
            elseif isDiagram&&slprivate('is_stateflow_based_block',obj(1))



                cInfo.isSF=true;
                sfID=sfprivate('block2chart',obj(1));
                sr=sfroot;
                sfObj=sr.idToHandle(sfID);
                if isa(sfObj,'Stateflow.Chart')
                    cInfo.SystemPath=sfObj.Path;
                else
                    cInfo.SystemPath=[sfObj.Path,'/',sfObj.Name];
                end
                cInfo.OwnerHandle=sfObj.Id;
            else
                cInfo.isSF=false;
                if~isempty(sourceItem.id)
                    if isDiagram
                        cInfo.SystemPath=getfullname(obj(1));
                    else
                        if~isempty(parentSystem)
                            cInfo.SystemPath=parentSystem;
                        else
                            cInfo.SystemPath=get_param(obj(1),'Parent');
                        end
                    end
                else

                    cInfo.SystemPath=getfullname(obj(1));
                end
                cInfo.OwnerHandle=get_param(cInfo.SystemPath,'Handle');
            end

            function chartObj=getChartObject(thisObj,isDiagram)








                if isa(thisObj,'Stateflow.Transition')
                    [transInfo,viewerInfo]=slreq.utils.getTransitionViewerList(obj.Id);


                    if~isempty(transInfo)
                        if isDiagram
                            sroot=sfroot;
                            chartObj=sroot.idToHandle(viewerInfo.topViewerID);
                            return;
                        end
                    end
                end
                if isDiagram
                    chartObj=thisObj;
                else
                    if isa(thisObj,'Stateflow.Chart')
                        chartObj=thisObj.getParent;
                    else
                        chartObj=thisObj.Subviewer;
                    end
                end
            end
        end

        function reqUuid=getReqUuid(dataLink)


            reqObj=dataLink.dest;
            if~isempty(reqObj)
                reqUuid=reqObj.getUuid;
            else


                reqUuid=slreq.das.Markup.getUnresolvedMarkupSummaryDescription(dataLink);
            end
        end

        function onMarkupConnectorChange(add,update,remove)
            appmgr=slreq.app.MainManager.getInstance;
            mkupMgr=appmgr.markupManager;
            if mkupMgr.ignoreNotification

                return;
            end
            if~isempty(add)

                for n=1:length(add)
                    currentAdd=add(n);
                    try
                        if isa(currentAdd,'diagram.markup.impl.MarkupItem')

                            mfMarkupItem=diagram.markup.MarkupItem(currentAdd);

                            mfConnectorItem=mfMarkupItem.getConnectors;
                            existingDasMarkup=mkupMgr.resolveDasMarkupFromImplMarkup(currentAdd);
                            if~isempty(existingDasMarkup)

                                continue;
                            end










                            dasMarkup=mkupMgr.findAndFixMovedMarkupAndConnector(currentAdd);

                            if isempty(dasMarkup)
                                for m=1:length(mfConnectorItem)
                                    reconnected=false;

                                    dasLink=slreq.utils.findDASbyUUID(mfConnectorItem(m).clientItemId);

                                    if isa(dasLink,'slreq.das.Link')&&isempty(dasLink.Connector)





                                        dataLink=dasLink.dataModelObj;
                                        [isDiagram,isnonvalidtrans]=slreq.utils.isDiagram(mfConnectorItem(m).target);%#ok<ASGLU>



                                        mkupMgr.connectWithDasObjects(dataLink,isDiagram,mfMarkupItem,mfConnectorItem(m));

                                        reconnected=true;
                                    end
                                    if~reconnected&&slfeature('NativeMarkupDrop')==1

                                        diagramObj=mfConnectorItem(m).target;
                                        targetId=mkupMgr.getTargetInfo(diagramObj);
                                        if~isempty(targetId)
                                            dataLink=createLinkIfNeeded(appmgr,mfMarkupItem,targetId);
                                            [isDiagram,isnonvalidtrans]=slreq.utils.isDiagram(mfConnectorItem(m).target);%#ok<ASGLU>


                                            mkupMgr.connectWithDasObjects(dataLink,isDiagram,mfMarkupItem,mfConnectorItem(m));
                                        end
                                    end
                                end
                            end
                        end
                    catch ex %#ok<NASGU>

                    end
                end


                for n=1:length(add)
                    currentAdd=add(n);
                    try
                        if isa(currentAdd,'diagram.markup.impl.MarkupConnector')

                            mfConnectorItem=diagram.markup.MarkupConnector(currentAdd);
                            mfMarkupItem=mfConnectorItem.getOwner;
                            existingDasConnector=mkupMgr.resolveDasConnectorFromImplConnector(currentAdd);
                            if~isempty(existingDasConnector)



                                continue;
                            end

                            dasLink=slreq.utils.findDASbyUUID(mfConnectorItem.clientItemId);

                            if isa(dasLink,'slreq.das.Link')&&isempty(dasLink.Connector)
                                dataLink=dasLink.dataModelObj;
                                [isDiagram,isnonvalidtrans]=slreq.utils.isDiagram(mfConnectorItem.target);%#ok<ASGLU>


                                mkupMgr.connectWithDasObjects(dataLink,isDiagram,mfMarkupItem,mfConnectorItem);
                            end

                        end
                    catch ex %#ok<NASGU>

                    end
                end
            end

            if~isempty(update)

                for n=1:length(update)
                    if isa(update(n),'diagram.markup.impl.MarkupItem')
                        try
                            dasMarkup=mkupMgr.resolveDasMarkupFromImplMarkup(update(n));
                            if~isempty(dasMarkup)
                                dasMarkup.syncFromCanvasMarkup(false);
                            end
                        catch ex %#ok<NASGU>

                        end
                    end
                end
            end

            if~isempty(remove)
                for n=1:length(remove)
                    currentRemove=remove(n);
                    try
                        if isa(currentRemove,'diagram.markup.impl.MarkupItem')
                            dasMarkup=mkupMgr.resolveDasMarkupFromImplMarkup(currentRemove);
                            if~isempty(dasMarkup)
                                dasMarkup.delete;
                            end
                        elseif isa(currentRemove,'diagram.markup.impl.MarkupConnector')
                            dasConnector=mkupMgr.resolveDasConnectorFromImplConnector(currentRemove);
                            if~isempty(dasConnector)
                                dasLink=dasConnector.Link;
                                dasLink.destroyConnector(dasConnector.isDiagram);
                            end
                        end
                    catch ex %#ok<NASGU>

                    end
                end
            end

            function[dataLink,linkCreated]=createLinkIfNeeded(appmgr,thisMarkupItem,srcInfo)%#ok<INUSL>


                dasReq=slreq.utils.findDASbyUUID(thisMarkupItem.clientItemId);
                dataLink=slreq.utils.findLinkFromReq(dasReq,srcInfo);
                linkCreated=false;
                if isempty(dataLink)
                    try
                        if rmisl.isObjectUnderCUT(srcInfo)
                            srcInfo=rmisl.harnessToModelRemap(srcInfo);
                        end
                    catch ME %#ok<NASGU>

                    end
                    srcInfo=slreq.utils.getRmiStruct(srcInfo);
                    dataLink=dasReq.addLink(srcInfo);
                    linkCreated=true;
                end
            end
        end

        function[targetHandle,targetId]=getTargetInfo(diagramObj)


            targetHandle='';
            sid='';
            if~isempty(diagramObj)
                switch diagramObj.resolutionDomain
                case 'simulink'
                    targetHandle=Simulink.resolver.asHandle(diagramObj);
                    if rmisl.isObjectUnderCUT(targetHandle)


                        blockObj=get(targetHandle,'Object');
                        ownerInfo=rmisl.harnessToModelRemap(blockObj);
                        targetHandle=ownerInfo.Handle;
                    end
                    if nargout>1

                        sid=Simulink.ID.getSID(targetHandle);
                    end
                case 'stateflow'
                    sfId=Stateflow.resolver.asId(diagramObj);
                    rt=sfroot;

                    if rmisl.isObjectUnderCUT(double(sfId))


                        objectH=rt.idToHandle(sfId);


                        ownerH=rmisl.harnessToModelRemap(objectH);
                        sfId=ownerH.Id;
                    end

                    targetHandle=rt.find('Id',sfId);
                    sid=Simulink.ID.getSID(targetHandle);
                otherwise
                    return;

                end

                [~,targetId]=strtok(sid,':');
            end
        end

    end
end

function enabled=isEnabledForEditor(editor)
    enabled=slreq.utils.isInPerspective(editor.getStudio.App.blockDiagramHandle,false);
    studioHelper=slreq.utils.DAStudioHelper.createHelper(editor.getStudio);


    enabled=enabled&&~studioHelper.isCurrentCanvasFromSSRefInstance;
end

function reply=handleCreateMarkup(params,id)
    isStateflow=isa(params.editor.getDiagram,'StateflowDI.Subviewer');
    if(id<0)




        cDiagram=params.editor.getDiagram;
        if isa(cDiagram,'StateflowDI.Subviewer')
            currentSys=double(cDiagram.backendId);
        else
            currentSys=cDiagram.handle;
        end

        if isStateflow
            reply=slreq.utils.nativeDropOntoSFCanvas(params,currentSys);
        else
            if Simulink.internal.isArchitectureModel(bdroot(currentSys),'Architecture')||...
                Simulink.internal.isArchitectureModel(bdroot(currentSys),'SoftwareArchitecture')
                pPort=Simulink.Editor.MousePositionToSystemPortInterface.getPortUnderCursor(params.editor,params.scenePosition);
                if~isempty(pPort)&&sysarch.isZCPort(pPort.handle)
                    id=pPort.handle;
                    reply=slreq.utils.nativeDropOntoZCPort(params,id);
                else
                    reply=slreq.utils.nativeDropOntoSLCanvas(params,currentSys);
                end
            else
                reply=slreq.utils.nativeDropOntoSLCanvas(params,currentSys);
            end
        end
    else
        if isStateflow
            reply=slreq.utils.nativeDropOntoSFObject(params,id);
        elseif sysarch.isZCPort(id,params.editor.getDiagram.getFullName)
            reply=slreq.utils.nativeDropOntoZCPort(params,id);
        else
            reply=slreq.utils.nativeDropOntoBlock(params,id);
        end
    end
    reply.connectorLabel=upper(reply.connectorLabel);
end


function policy=handleDragAndDrop(element)
    if strcmpi(class(element),'SLM3I.Annotation')&&...
        strcmpi(get_param(element.handle,'AnnotationType'),'area_annotation')
        if slfeature('SLReqOnAreaAnnotations')~=0
            policy='CreateIfNew';
        else
            policy='DontCreate';
        end
    elseif strcmpi(class(element),'SLM3I.Port')
        archPort=systemcomposer.utils.getArchitecturePeer(element.handle);
        if~isempty(archPort)
            policy='CreateIfNew';
        else
            policy='ForceToCanvas';
        end
    else
        policy='DontCreate';
    end
end

function tf=checkIfAcceptableLink(linkObj)
    tf=true;
    if~isa(linkObj.dest,'slreq.data.Requirement')
        tf=false;
    end
    sourceItem=linkObj.source;
    if~isa(sourceItem,'slreq.data.SourceItem')
        tf=false;
    elseif~strcmp(sourceItem.domain,'linktype_rmi_simulink')
        tf=false;
    end
end


function tf=isUnresolved(cbinfo)
    tf=true;
    mgr=slreq.app.MainManager.getInstance;
    parts=SLStudio.Utils.partitionSelection(cbinfo);
    markupItems=parts.markupItems;
    for n=1:length(markupItems)
        if isKey(mgr.markupManager.ReqUuid2MarkupMap,markupItems(n).clientItemId)
            tf=false;
            return;
        end
    end
end

function tf=isSrcInHarness(sourceInfo,harnessHD)
    tf=false;
    if rmisl.isHarnessIdString(sourceInfo.id)
        [~,harnessName]=fileparts(sourceInfo.artifactUri);
        sourceId=[harnessName,sourceInfo.id];

        srcName=Simulink.harness.internal.sidmap.getHarnessObjectFromUniqueID(sourceId);
        harnessName=get(harnessHD,'Name');
        if strcmp(srcName,harnessName)&&sourceInfo.isValid
            tf=true;
        end
    end
end



