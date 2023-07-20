classdef Markup<handle







    properties

        markupMgr;
        markupItem;
        reqUuid='';



        linkUuids={};
        dataMarkup;
        ownerHandle;
        Connectors=slreq.das.Connector.empty;
        diagramPath;
    end

    properties(Dependent)
        Position;
        Size;
        Description;
        Requirement;
        ViewOwnerID;
        Links;
        visibleDetail;
    end

    properties(Access=private)
        cContent;
    end

    methods
        function this=Markup(markupMgr,dataMarkup,dasLink,reqUuid,cInfo,mfMarkupItem)
            if~isa(markupMgr,'slreq.app.MarkupManager')
                error(message('Slvnv:slreq:InvalidInputArgument'));
            end

            this.markupMgr=markupMgr;
            this.dataMarkup=dataMarkup;

            this.reqUuid=reqUuid;
            this.linkUuids={dasLink.dataUuid};
            this.ownerHandle=cInfo.OwnerHandle;


            this.markupMgr.setIgnoreNotificationFlag(true);
            cleanup=onCleanup(@()this.markupMgr.setIgnoreNotificationFlag(false));


            if isempty(mfMarkupItem)
                [modelName,sysRelPath]=strtok(cInfo.SystemPath,'/');
                if~isempty(sysRelPath)
                    sysRelPath(1)=[];
                end

                this.cContent=this.markupMgr.getClientContent(modelName);
                this.markupItem=this.cContent.createMarkupItem(this.reqUuid,sysRelPath);
                this.markupItem.visibleDetail=dataMarkup.visibleDetail;

                if dataMarkup.size(1)<=0


                    pos=find_current_canvas_lowerleft()+[70,-100];
                    this.setDefaultSizePosition(pos(1),pos(2),cInfo.isDiagram);
                else
                    this.Position=dataMarkup.position;
                    this.Size=dataMarkup.size;
                end
            else
                this.markupItem=mfMarkupItem;
                this.syncFromCanvasMarkup(true);
            end
            this.diagramPath=this.markupItem.diagram;

            this.setMarkupContent();

            if~isKey(this.markupMgr.ReqUuid2MarkupMap,reqUuid)
                this.markupMgr.ReqUuid2MarkupMap(reqUuid)=this;
            else
                this.markupMgr.ReqUuid2MarkupMap(reqUuid)=[this.markupMgr.ReqUuid2MarkupMap(reqUuid),this];
            end
            this.markupMgr.setReqSetMarkupMap(this);
        end

        function delete(this)
            try
                this.markupMgr.setIgnoreNotificationFlag(true);
                cleanup=onCleanup(@()this.markupMgr.setIgnoreNotificationFlag(false));

                this.markupMgr.clearReqSetMarkupMap(this);

                if~isempty(this.dataMarkup)&&this.markupItem.isValid

                    this.syncFromCanvasMarkup(false);
                end


                conns=this.Connectors;
                for n=1:length(conns)
                    if isvalid(conns(n))
                        dasLink=conns(n).Link;
                        dasLink.destroyConnector(conns(n).isDiagram);
                    end
                end
            catch ex %#ok<NASGU>
            end
            try

                if isvalid(this.markupMgr)
                    if isKey(this.markupMgr.ReqUuid2MarkupMap,this.reqUuid)
                        exisitngMarkups=this.markupMgr.ReqUuid2MarkupMap(this.reqUuid);
                        if numel(exisitngMarkups)==1

                            this.markupMgr.ReqUuid2MarkupMap.remove(this.reqUuid);
                        else
                            idx=1:length(exisitngMarkups);
                            for n=1:length(exisitngMarkups)

                                if exisitngMarkups(n)==this
                                    idx(n)=[];
                                end
                            end
                            this.markupMgr.ReqUuid2MarkupMap(this.reqUuid)=exisitngMarkups(idx);
                        end
                    end
                end
            catch ex %#ok<NASGU>
            end

            try
                if this.markupItem.isValid
                    this.markupItem.remove;
                    this.markupItem.delete;
                end
            catch ex %#ok<NASGU>
            end
        end

        function set.Position(this,pos)
            this.markupItem.position=pos;
            this.dataMarkup.position=this.markupItem.position;
        end

        function pos=get.Position(this)
            pos=this.markupItem.position;
        end

        function set.Size(this,size)
            this.markupItem.size=size;
            this.dataMarkup.size=this.markupItem.size;
        end

        function size=get.Size(this)
            size=this.markupItem.size;
        end

        function set.Description(this,desc)
            this.markupItem.html=desc;
        end

        function desc=get.Description(this)
            desc=this.markupItem.html;
        end

        function links=get.Links(this)
            links=slreq.data.Link.empty();
            for n=1:length(this.linkUuids)
                links(end+1)=slreq.data.ReqData.getInstance.findObject(this.linkUuids{n});%#ok<AGROW>
            end
        end

        function id=get.ViewOwnerID(this)

            id=this.dataMarkup.viewOwnerId;
        end

        function set.visibleDetail(this,value)
            this.markupItem.visibleDetail=int32(value);
            this.dataMarkup.visibleDetail=int32(value);
        end

        function value=get.visibleDetail(this)
            value=this.dataMarkup.visibleDetail;
        end

        function update(this)
            this.setMarkupContent();
        end

        function setMarkupContent(this)
            reqObject=this.Requirement;
            if~isempty(reqObject)
                this.displayResolvedMarkup(reqObject);
            else
                this.displayUnresolvedMarkup()
            end
        end

        function reqDasObj=get.Requirement(this)

            reqDasObj=slreq.utils.findDASbyUUID(this.reqUuid);
        end

        function addConnector(this,dasConnector)
            this.Connectors(end+1)=dasConnector;
        end

        function removeConnector(this,dasConnector)
            nConns=length(this.Connectors);
            activeIdx=true(1,nConns);
            for n=1:nConns
                if this.Connectors(n)==dasConnector
                    activeIdx(n)=false;
                end
            end
            if~isempty(activeIdx)
                this.Connectors=this.Connectors(activeIdx);
            end
        end


        function setDefaultSizePosition(this,badgeX,badgeY,isDiagram)
            if isDiagram
                this.Position=[badgeX,badgeY];
            else

                linkObj=this.Links;
                if~isempty(linkObj)
                    sourceItem=linkObj(1).source;

                    [~,mdlName,~]=fileparts(sourceItem.artifactUri);
                    zcElem=sysarch.resolveZCElement(sourceItem.id,mdlName);
                    if~isempty(zcElem)
                        if sysarch.isZCPort(zcElem)

                            obj=sysarch.getPortHandleForMarkup(sourceItem.id,mdlName);
                        end
                    else
                        sid=sourceItem.getSID;
                        if rmisl.isHarnessIdString(sid)
                            [~,obj]=rmisl.resolveObjInHarness(sid);
                        else
                            obj=Simulink.ID.getHandle(sid);
                        end
                    end

                    objClass=class(obj);
                    if contains(objClass,'Stateflow')
                        this.Position=[badgeX+70,badgeY-70];
                    else
                        blockPos=get_param(obj,'Position');
                        if numel(blockPos)<3


                            this.Position=[blockPos(2)+70,blockPos(1)-70];
                        else
                            this.Position=[blockPos(3)+70,blockPos(2)-70];
                        end
                    end

                end
            end
            this.Size=slreq.app.MarkupManager.DefaultMarkupSize;
        end

        function syncFromCanvasMarkup(this,updataViewOwner)
            this.dataMarkup.position=this.markupItem.position;
            this.dataMarkup.size=this.markupItem.size;
            this.dataMarkup.visibleDetail=this.markupItem.visibleDetail;
            if updataViewOwner||~strcmp(this.diagramPath,this.markupItem.diagram)
                this.updateViewOwnerID();
            end
        end

        function updateViewOwnerID(this)
            try
                conns=this.markupItem.getConnectors;
                if~isempty(conns)
                    target=conns(1).target;
                    diagramObj=[];
                    if strcmpi(target.type,'Transition')
                        targetID=double(Stateflow.resolver.asId(target));
                        [transInfo,viewerInfo]=slreq.utils.getTransitionViewerList(targetID);
                        if~isempty(transInfo)&&viewerInfo.isInTopView&&~viewerInfo.isInSourceView
                            diagramObj=diagram.resolver.resolve(viewerInfo.topViewerID);
                        end
                    end
                    if isempty(diagramObj)
                        if target.isDiagram
                            diagramObj=target;
                        elseif target.isElement
                            if strcmpi(target.resolutionDomain,'stateflow')


                                stateID=double(Stateflow.resolver.asId(target));
                                sr=sfroot;
                                diagramViewer=sr.idToHandle(stateID);
                                diagramObj=diagram.resolver.resolve(diagramViewer.Subviewer.Id);
                            else
                                diagramObj=target.getParent;
                            end
                        else

                            return;
                        end
                    end
                    if~isempty(diagramObj)
                        [targetHandle,targetId]=this.markupMgr.getTargetInfo(diagramObj);
                        if isa(targetHandle,'Stateflow.Object')
                            this.ownerHandle=targetHandle.Id;
                        else
                            this.ownerHandle=targetHandle;
                        end
                        this.ViewOwnerID=targetId;
                    end
                end
            catch ex %#ok<NASGU>
            end
        end

        function displayResolvedMarkup(this,reqObject)
            this.markupItem.summaryText=slreq.cpputils.buildMarkupSummary(reqObject.Id,reqObject.Summary);
            this.markupItem.html=reqObject.Description;
        end
        function displayUnresolvedMarkup(this)
            dataLinks=this.Links;
            [summary,description]=this.getUnresolvedMarkupSummaryDescription(dataLinks(1));
            this.markupItem.summaryText=summary;
            this.markupItem.html=description;
        end
    end

    methods(Static)
        function[summary,description]=getUnresolvedMarkupSummaryDescription(dataLink)
            summary=sprintf('%s:%s',dataLink.destUri,dataLink.destId);
            description=getString(message('Slvnv:slreq:RequirementUnresolved',summary));
        end
    end
end


function pos=find_current_canvas_lowerleft
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    canvas=allStudios(1).App.getActiveEditor.getCanvas;
    rect=canvas.SceneRectInView;
    pos=[rect(1),rect(4)];
end
