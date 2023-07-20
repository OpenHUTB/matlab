classdef BadgeManager<handle







    properties(Access='private')
blkBadge
chartBadge
transBadge
stateBadge
graphBadge
zcArchBadge
zcCompBadge
reqData
areaBadge
zcPortBadge
portBadge
systemPortBadge






        SLIdToHandleMap=containers.Map;


        linkDataChangeListener;


        isZCInitialized=false;
    end

    properties(SetAccess=private,GetAccess=public)
badgeMap
    end


    methods

        function this=BadgeManager()
            this.badgeMap=containers.Map('KeyType','double','ValueType','any');


            this.blkBadge=create_badge('RequirementBlkBadge','BlockNorthEast');
            this.areaBadge=create_badge('RequirementAreaBadge','AreaNorthEast');
            this.chartBadge=create_badge('RequirementChartBadge','sfDiagramBadgesPanel');
            this.transBadge=create_badge('RequirementTransBadge','sfTransitionBadgesPanel');
            this.stateBadge=create_badge('RequirementStateBadge','sfStateBadgesPanel');
            this.graphBadge=create_badge('RequirementGraphBadge','Graph');
            this.portBadge=create_badge('RequirementPortBadge','Port');
            this.systemPortBadge=create_badge('RequirementPortBadge','SystemPort');

            init_badge(this.blkBadge,@this.onClickBadge);
            init_badge(this.areaBadge,@this.onClickBadge);
            init_badge(this.chartBadge,@this.onClickBadge);
            init_badge(this.transBadge,@this.onClickBadge);
            init_badge(this.stateBadge,@this.onClickBadge);
            init_badge(this.graphBadge,@this.onClickBadge);
            init_badge(this.portBadge,@this.onClickBadge);
            init_badge(this.systemPortBadge,@this.onClickBadge);






            this.chartBadge.DiagramObjectCategories={'backend','stateflowDiagramAsElement'};


            this.reqData=slreq.data.ReqData.getInstance();
            this.linkDataChangeListener=this.reqData.addlistener('LinkDataChange',@this.onLinkDataUpdate);
        end


        function delete(this)
            delete(this.linkDataChangeListener);
            this.linkDataChangeListener=[];
        end

        function enableBadges(this,modelName)
            modelHandle=get_param(modelName,'handle');
            if~this.badgeMap.isKey(modelHandle)
                this.badgeMap(modelHandle)=containers.Map('KeyType','double',...
                'ValueType','any');
            end
            this.showBadges(modelName);
        end

        function disableBadges(this,modelName)
            modelHandle=get_param(modelName,'handle');
            if this.badgeMap.isKey(modelHandle)
                this.closeBadges(modelName);
            end
        end


        function refreshBadges(this,modelName)













            this.disableBadges(modelName);
            this.enableBadges(modelName);
        end

        function refreshBadgeForLinkedDiagram(this,modelName)



            if dig.isProductInstalled('Simulink')&&bdIsLoaded(modelName)
                allModelWithBadge=this.badgeMap.keys;
                if~isempty(allModelWithBadge)
                    model2BeRefreshed={};
                    if bdIsLibrary(modelName)
                        model2BeRefreshed=slreq.utils.getAllModelsWithLibrary(modelName,allModelWithBadge);
                    elseif bdIsSubsystem(modelName)
                        model2BeRefreshed=slreq.utils.getAllModelsWithSSRef(modelName,allModelWithBadge);
                    end
                    for index=1:length(model2BeRefreshed)
                        cModel=model2BeRefreshed{index};
                        this.refreshBadges(cModel)
                    end
                end
            end
        end

        function showBadge(this,modelName,obj)
            if isZC(modelName)
                chevrons=[];
                if sysarch.isSysArchObject(obj)


                    this.showBageForZC(obj,modelName);
                    if sysarch.isZCPort(obj)
                        if~isnumeric(obj)
                            obj=sysarch.getPortHandle(obj.getZCIdentifier,modelName);
                        end
                        if isempty(obj)
                            return
                        end

                        isBEP=strcmp(get_param(obj(1),'type'),'block')&&...
                        (strcmpi(get_param(obj(1),'BlockType'),'Inport')||...
                        strcmpi(get_param(obj(1),'BlockType'),'Outport'));
                        if isBEP
                            archPort=systemcomposer.utils.getArchitecturePeer(obj(1));
                            obj=sysarch.getPortHandleForMarkup(archPort.getZCIdentifier,modelName);
                            chevrons=sysarch.getChevronsForBadges(archPort.getZCIdentifier,modelName);
                        elseif strcmp(get_param(obj(1),'type'),'block')&&strcmpi(get_param(obj(1),'BlockType'),'PMIOPort')
                            archPort=systemcomposer.utils.getArchitecturePeer(obj(1));
                            obj=sysarch.getPortHandleForMarkup(archPort.getZCIdentifier,modelName);
                        end
                        for i=1:numel(obj)
                            this.showBadgeForSL(obj(i),modelName)
                        end
                        for i=1:numel(chevrons)
                            diagObj=diagram.resolver.resolve(get_param(chevrons(i),'Parent'));
                            this.systemPortBadge.setVisible(diagObj,true);
                        end
                    end
                else


                    this.showBageForZC(obj,modelName);
                    for i=1:numel(obj)
                        this.showBadgeForSL(obj(i),modelName)
                    end
                end
            else
                this.showBadgeForSL(obj,modelName);
            end
        end

        function showBageForZC(this,obj,modelName)

            create_zcBadge_once(this);
            [zcIn,zcOut]=sysarch.resolveSLObj(obj);
            if isempty(zcIn)&&isempty(zcOut)


                [zcIn,zcOut]=sysarch.resolveZCObj(obj);
            end
            setVisibilityForZCBadges(this,obj,zcIn,zcOut,modelName,true);
            updateTooltipForZCBadges(this,obj,zcIn,zcOut,modelName);
        end

        function showBadgeForSL(this,obj,modelName)
            [objOut,objIn]=slreq.utils.diagramResolve(obj);
            if strcmpi(get_param(modelName,'IsHarness'),'on')
                modelName=Simulink.harness.internal.getHarnessOwnerBD(modelName);
            end





            setVisibilityForBadges(this,obj,objOut,objIn,modelName,true)
        end

        function hideBadge(this,obj,modelName)
            try
                if isZC(modelName)


                    create_zcBadge_once(this);
                    [zcIn,zcOut]=sysarch.resolveSLObj(obj);
                    if isempty(zcIn)&&isempty(zcOut)


                        [zcIn,zcOut]=sysarch.resolveZCObj(obj);
                    end
                    setVisibilityForZCBadges(this,obj,zcIn,zcOut,modelName,false);
                    if sysarch.isZCPort(obj)
                        if~isnumeric(obj)
                            obj=sysarch.getPortHandle(obj.getZCIdentifier,modelName);
                        end

                        isBEP=strcmp(get_param(obj(1),'type'),'block')&&...
                        (strcmpi(get_param(obj(1),'BlockType'),'Inport')||...
                        strcmpi(get_param(obj(1),'BlockType'),'Outport'));
                        if isBEP
                            archPort=systemcomposer.utils.getArchitecturePeer(obj(1));
                            obj=sysarch.getPortHandleForMarkup(archPort.getZCIdentifier,modelName);
                            chevrons=sysarch.getChevronsForBadges(archPort.getZCIdentifier,modelName);
                        elseif strcmp(get_param(obj(1),'type'),'block')&&strcmpi(get_param(obj(1),'BlockType'),'PMIOPort')
                            archPort=systemcomposer.utils.getArchitecturePeer(obj(1));
                            obj=sysarch.getPortHandleForMarkup(archPort.getZCIdentifier,modelName);
                        end
                        for i=1:numel(obj)
                            [objOut,objIn]=slreq.utils.diagramResolve(obj(i));
                            setVisibilityForBadges(this,obj(i),objOut,objIn,modelName,false);

                        end
                        for i=1:numel(chevrons)
                            diagObj=diagram.resolver.resolve(get_param(chevrons(i),'Parent'));
                            this.systemPortBadge.setVisible(diagObj,false);
                        end
                    end
                end
                for i=1:numel(obj)
                    [objOut,objIn]=slreq.utils.diagramResolve(obj(i));
                    setVisibilityForBadges(this,obj(i),objOut,objIn,modelName,false);
                end
            catch ex %#ok<NASGU>




                return;
            end
        end

        function updateBadge(this,dasObj)
            if isempty(dasObj)
                return;
            end
            inLinks=dasObj.getLinks;
            for i=1:length(inLinks)
                src=inLinks(i).source;
                if strcmp(src.domain,'linktype_rmi_simulink')
                    try
                        obj=Simulink.ID.getHandle(src.getSID);
                    catch ex
                        continue;
                    end
                    isSF=rmi.resolveobj(obj);
                    if~isSF
                        bd=bdroot(obj);
                        if isZC(bd)
                            [zcIn,zcOut]=sysarch.resolveSLObj(obj);
                            updateTooltipForZCBadges(this,obj,zcIn,zcOut,bd);
                        end
                    end
                end
            end
        end

        function yesno=getStatus(this,modelName)
            modelH=get_param(modelName,'Handle');
            yesno=isKey(this.badgeMap,modelH);
        end

        function removeBadgeMap(this,modelHandle)
            if this.getStatus(modelHandle)
                this.badgeMap.remove(modelHandle);
            end
        end

    end

    methods(Access=private)

        function setSLIdHandleCache(this,slid,slhandle)





            if isa(slhandle,'double')
                this.SLIdToHandleMap(slid)=slhandle;
            else
                this.SLIdToHandleMap(slid)=slhandle.Id;
            end
        end

        function out=getSLHandleFromId(this,slid)
            if isKey(this.SLIdToHandleMap,slid)







                out=this.SLIdToHandleMap(slid);
            else
                out=[];
            end
        end

        function b=getObjBadge(this,obj)
            b=[];
            switch(obj.type)
            case 'Block'
                b=this.blkBadge;
            case 'State'
                b=this.stateBadge;
            case 'Transition'
                b=this.transBadge;
            case 'Graph'
                b=this.graphBadge;
            case 'Chart'
                b=this.chartBadge;
            case 'Annotation'
                b=this.areaBadge;
            case 'Port'
                b=this.portBadge;
            end
        end

        function showBadges(this,modelName)
            modelName=get_param(modelName,'Name');
            if~dig.isProductInstalled('Simulink')||~bdIsLoaded(modelName)

                return;
            end


            if strcmp(get_param(modelName,'IsHarness'),'on')
                modelOwnerName=get_param(Simulink.harness.internal.getHarnessOwnerBD(modelName),'Name');
            else
                modelOwnerName=modelName;
            end
            linkSet=this.reqData.getLinkSet(get_param(modelOwnerName,'FileName'));



            allReferenceBlocks=slreq.utils.getReferenceBlocksWithLink(modelOwnerName);
            if~isempty(allReferenceBlocks)
                for rindex=1:length(allReferenceBlocks)
                    objH=allReferenceBlocks(rindex);
                    this.showBadge(modelName,objH);
                end
            end

            [~,allSSRefModelNames]=rmisl.getLoadedSSRefFromModel(modelOwnerName);
            for index=1:length(allSSRefModelNames)
                allLinkedBlock=rmisl.getLinkedItemsInSSRefInstance(allSSRefModelNames{index},modelOwnerName);
                if~isempty(allLinkedBlock)
                    for rindex=1:length(allLinkedBlock)
                        objH=allLinkedBlock(rindex);
                        this.showBadge(modelName,objH);
                    end
                end
            end

            if isempty(linkSet)

                return;
            end

            linkedItems=linkSet.getLinkedItems();
            if isZC(modelName)
                this.showBadgesForZCLinkedItems(modelName,modelOwnerName,linkedItems);
            else
                this.showBadgesForLinkedItems(modelName,modelOwnerName,linkedItems);
            end
        end

        function showBadgesForZCLinkedItems(this,modelName,modelOwnerName,linkedItems)

            for i=1:length(linkedItems)
                [~,objH]=rmi.resolveobj([modelOwnerName,linkedItems(i).id]);
                if~isempty(objH)
                    this.setSLIdHandleCache([modelOwnerName,linkedItems(i).id],objH);
                    this.showBadge(modelName,objH);
                    [hasCUT,cutInfo]=slreq.utils.doesObjectHaveCUTComponent(objH);

                    if hasCUT
                        this.showBadge(cutInfo.harnessModelHandle,cutInfo.Id);
                    end
                elseif sysarch.isZCElement(linkedItems(i).id)
                    objH=sysarch.resolveZCElement(linkedItems(i).id,modelOwnerName);
                    if~isempty(objH)
                        this.showBadge(modelName,objH);
                    end
                end
            end
        end

        function showBadgesForLinkedItems(this,modelName,modelOwnerName,linkedItems)

            for i=1:length(linkedItems)
                [~,objH]=rmi.resolveobj([modelOwnerName,linkedItems(i).id]);
                if~isempty(objH)
                    this.setSLIdHandleCache([modelOwnerName,linkedItems(i).id],objH);
                    this.showBadge(modelName,objH);
                    [hasCUT,cutInfo]=slreq.utils.doesObjectHaveCUTComponent(objH);

                    if hasCUT
                        this.showBadge(cutInfo.harnessModelHandle,cutInfo.Id);
                    end
                end
            end
        end

        function closeBadges(this,modelName)
            modelHandle=get_param(modelName,'Handle');

            modelBadges=this.badgeMap(modelHandle);
            blockHandles=modelBadges.keys;
            for i=1:numel(blockHandles)
                this.hideBadge(blockHandles{i},modelName);
            end
            this.badgeMap.remove(modelHandle);

            if isZC(modelName)



                this.closeBadgesForZC(modelName)
            end
        end

        function closeBadgesForZC(this,modelName)


            if strcmp(get_param(modelName,'IsHarness'),'on')
                modelOwnerName=get_param(Simulink.harness.internal.getHarnessOwnerBD(modelName),'Name');
            else
                modelOwnerName=modelName;
            end
            linkSet=this.reqData.getLinkSet(get_param(modelOwnerName,'FileName'));
            if~isempty(linkSet)
                linkedItems=linkSet.getLinkedItems();
                for i=1:numel(linkedItems)
                    if sysarch.isZCElement(linkedItems(i).id)
                        objH=sysarch.resolveZCElement(linkedItems(i).id,modelOwnerName);
                        this.hideBadge(objH,modelName);
                    end
                end
            end
        end

        function onClickBadge(this,diagramObject,posX,posY)%#ok<INUSL>


            h=slreq.gui.PopupInformer(diagramObject,posX,posY);
            h.show();
        end

        function html=reqToHtml(~,link)
            html='';
            req=link.dest;
            if~isempty(req)
                tempRMIHTMLdir=[regexprep(getenv('TEMP'),'\\','/'),'/RMI/MSWORD/'];
                html=regexprep(req.description,'src=\"',...
                sprintf('src=\"file:///%s',tempRMIHTMLdir));

            end
        end


        function setVisibilityForBadges(this,obj,objOut,objIn,modelName,isVisibleFlag)

            if strcmp(objOut.type,'Transition')&&sf('get',obj,'trans.type')==1


                for index=1:length(objIn)
                    objInHandle=objIn(index);
                    bdg=this.getObjBadge(objInHandle);
                    bdg.setVisible(objInHandle,isVisibleFlag);
                end
                if isVisibleFlag
                    modelBadges=this.badgeMap(get_param(modelName,'Handle'));
                    modelBadges(obj)=objIn;%#ok<NASGU>
                end
            elseif strcmp(objOut.type,'Transition')&&...
                Stateflow.ReqTable.internal.TableManager.isParentedBySpecBlock(sf('IdToHandle',obj))
                chartId=sf('get',obj,'.chart');
                Stateflow.ReqTable.internal.TableManager.highlightRequirementLinksForTransition(chartId,obj);
            else

                if~isVisibleFlag&&...
                    ~objOut.isNull&&...
                    ~isempty(objIn)&&...
                    ~objIn.isNull&&...
                    strcmpi(objIn.resolutionDomain,'stateflow')&&...
                    strcmpi(objOut.resolutionDomain,'simulink')







                    sfId=double(Stateflow.resolver.asId(objIn));
                    inObj=sf('IdToHandle',sfId);
                    inRootName=inObj.Machine.Name;

                    if bdIsLibrary(inRootName)&&~strcmpi(inRootName,modelName)
                        objIn=[];
                    end
                end

                if~objOut.isNull

                    bdg=this.getObjBadge(objOut);
                    bdg.setVisible(objOut,isVisibleFlag);

                    if strcmpi(objOut.resolutionDomain,'stateflow')...
                        &&strcmp(objOut.type,'State')


                        cbdg=this.chartBadge;
                        cbdg.setVisible(objOut,isVisibleFlag);
                    end
                end

                if~isempty(objIn)&&~objIn.isNull
                    bdg=this.getObjBadge(objIn);
                    bdg.setVisible(objIn,isVisibleFlag);
                end
                if isVisibleFlag
                    modelBadges=this.badgeMap(get_param(modelName,'Handle'));
                    modelBadges(obj)=[objOut,objIn];%#ok<NASGU>
                end
            end
        end

        function updateSourceBadge(this,source,isAdded,expectedLinkCount)


            if nargin<4
                expectedLinkCount=0;
            end

            modelFilePath=source.artifactUri;
            [~,modelName,~]=fileparts(modelFilePath);
            modelHandle=get_param(modelName,'Handle');
            if this.badgeMap.isKey(modelHandle)
                this.handleModelBadges(modelName,source,isAdded,expectedLinkCount);
            end



            if bdIsLibrary(modelHandle)
                this.handleLibraryBadges(modelName,source,isAdded)
            end

        end


        function onLinkDataUpdate(this,~,eventInfo)








            if~any(strcmp(eventInfo.type,{'Link Added','Link Deleted'}))&&...
                (~strcmp(eventInfo.type,'Set Prop Update')||~strcmp(eventInfo.PropName,'source'))
                return;
            end

            try
                link=eventInfo.eventObj;
                source=link.source;

                if~strcmp(source.domain,'linktype_rmi_simulink')


                    return;
                end
                switch eventInfo.type
                case 'Link Added'
                    this.updateSourceBadge(source,true);
                case 'Link Deleted'






                    this.updateSourceBadge(source,false,1);
                case 'Set Prop Update'
                    this.updateSourceBadge(source,true);
                    if isa(eventInfo.OldValue,'slreq.data.SourceItem')


                        this.updateSourceBadge(eventInfo.OldValue,false,0);
                    end
                end
            catch ex %#ok<NASGU>

            end
        end

        function handleLibraryBadges(this,libname,source,isAdded)

            allBlocks=rmisl.getAllReferencedBlocks('',libname,source.id);

            for index=1:length(allBlocks)
                cBlock=allBlocks(index);
                cMName=bdroot(cBlock);
                if get_param(cMName,'ReqPerspectiveActive')==1
                    if isAdded
                        this.showBadge(cMName,cBlock);
                    else
                        modelBlocks=this.badgeMap(cMName);
                        if modelBlocks.isKey(cBlock)
                            if rmisl.isLibObject(cBlock)
                                clinks=[];
                            else



                                cSrc=slreq.utils.getRmiStruct(cBlock);
                                clinks=slreq.data.ReqData.getInstance().getOutgoingLinks(cSrc);
                            end


                            if isempty(clinks)
                                this.hideBadge(cBlock,cMName);
                            end
                        end
                    end
                end
            end
        end

        function handleModelBadges(this,modelName,source,isAdded,expectedLinkCount)
            [isSf,srcObjH]=rmi.resolveobj([modelName,source.id]);
            if isAdded
                if~isempty(srcObjH)
                    this.setSLIdHandleCache([modelName,source.id],srcObjH);
                    this.showOrHideBadges(modelName,source.id,srcObjH,true);
                elseif sysarch.isZCElement(source.id)
                    srcObjH=sysarch.resolveZCElement(source.id,modelName);
                    create_zcBadge_once(this);
                    if sysarch.isZCPort(srcObjH)
                        this.showOrHideBadges(modelName,source.id,srcObjH,true);
                    end
                    [zcIn,zcOut]=sysarch.resolveZCObj(srcObjH);
                    setVisibilityForZCBadges(this,srcObjH,zcIn,zcOut,modelName,true);
                    updateTooltipForZCBadges(this,srcObjH,zcIn,zcOut,modelName);

                end
            else



                totalLinks=source.numberOfLinks;
                if~isSf&&~isempty(srcObjH)&&~strcmpi(get(srcObjH,'type'),'block_diagram')
                    if~strcmp(get(srcObjH,'type'),'annotation')
                        srcRefBlock=get(srcObjH,'ReferenceBlock');
                        if~isempty(srcRefBlock)
                            refSrc=slreq.utils.getRmiStruct(srcRefBlock);
                            cLinks=slreq.data.ReqData.getInstance().getOutgoingLinks(refSrc);
                            totalLinks=source.numberOfLinks+length(cLinks);
                        end
                    end
                end
                if totalLinks==expectedLinkCount




                    if isempty(srcObjH)



                        srcObjH=this.getSLHandleFromId([modelName,source.id]);
                        if isempty(srcObjH)&&sysarch.isZCElement(source.id)
                            srcObjH=sysarch.resolveZCElement(source.id,modelName);
                        end

                    end

                    if~isempty(srcObjH)
                        this.showOrHideBadges(modelName,source.id,srcObjH,false);
                    end
                end
            end
        end


        function showOrHideBadges(this,modelName,sourceID,objH,isShowing)










            modelHandle=get_param(modelName,'Handle');



            if isShowing


                this.showBadge(modelName,objH);
            else
                modelBlocks=this.badgeMap(modelHandle);
                if modelBlocks.isKey(objH)
                    this.hideBadge(objH,modelName);
                elseif sysarch.isSysArchObject(objH)
                    this.hideBadge(objH,modelName);
                    return;
                end
            end
            [hasCUT,cutInfo]=slreq.utils.doesObjectHaveCUTComponent(objH);
            if hasCUT
                if isShowing


                    this.showBadge(cutInfo.harnessModelHandle,cutInfo.Id);
                else
                    if modelBlocks.isKey(objH)
                        this.hideBadge(cutInfo.Id,modelName);
                    end
                end
            end


        end

        function setVisibilityForZCBadges(this,~,zcIn,zcOut,modelName,trueOrFalse)
            s=sysarch.getSyntaxes(modelName);
            for i=1:numel(s)
                for j=1:numel(zcOut)
                    if isa(zcOut(j),'systemcomposer.architecture.model.views.ElementGroup')


                        compGroups=zcOut(j).p_CompGroups.toArray;
                        for compGroup=compGroups
                            this.zcCompBadge.setVisible(trueOrFalse,compGroup,s(i));
                        end
                    elseif isa(zcOut(j),'systemcomposer.architecture.model.views.View')


                        this.zcCompBadge.setVisible(trueOrFalse,zcOut(j).p_ViewArchitecture,s(i));
                    else
                        this.zcCompBadge.setVisible(trueOrFalse,zcOut(j),s(i));
                    end
                end
                for j=1:numel(zcIn)
                    if isa(zcIn(j),'systemcomposer.architecture.model.views.ElementGroup')


                        compGroups=zcIn(j).p_CompGroups.toArray;
                        for compGroup=compGroups
                            this.zcArchBadge.setVisible(trueOrFalse,compGroup,s(i));
                        end
                    elseif isa(zcIn(j),'systemcomposer.architecture.model.views.View')


                        this.zcArchBadge.setVisible(trueOrFalse,zcIn(j).p_ViewArchitecture,s(i));
                    else
                        this.zcArchBadge.setVisible(trueOrFalse,zcIn(j),s(i));
                    end
                end
            end
        end

        function updateTooltipForZCBadges(this,obj,zcIn,zcOut,modelName)
            s=sysarch.getSyntaxes(modelName);
            tooltip=getZCTooltip(obj);
            for i=1:numel(s)
                for j=1:numel(zcOut)
                    if isa(zcOut(j),'systemcomposer.architecture.model.views.ElementGroup')


                        compGroups=zcOut(j).p_CompGroups.toArray;
                        for compGroup=compGroups
                            this.zcCompBadge.setTooltip(tooltip,compGroup,s(i));
                        end
                    elseif isa(zcOut(j),'systemcomposer.architecture.model.views.View')


                        this.zcCompBadge.setTooltip(tooltip,zcOut(j).p_ViewArchitecture,s(i));
                    else
                        this.zcCompBadge.setTooltip(tooltip,zcOut(j),s(i));
                    end
                end
                for j=1:numel(zcIn)
                    if isa(zcIn(j),'systemcomposer.architecture.model.views.ElementGroup')


                        compGroups=zcIn(j).p_CompGroups.toArray;
                        for compGroup=compGroups
                            this.zcArchBadge.setTooltip(tooltip,compGroup,s(i));
                        end
                    elseif isa(zcIn(j),'systemcomposer.architecture.model.views.View')


                        this.zcArchBadge.setTooltip(tooltip,zcIn(j).p_ViewArchitecture,s(i));
                    else
                        this.zcArchBadge.setTooltip(tooltip,zcIn(j),s(i));
                    end
                end
            end
        end

        function create_zcBadge_once(this)
            if~this.isZCInitialized
                this.zcArchBadge=create_zcBadge("RequirementArchBadge","DiagramSouthWest");
                this.zcCompBadge=create_zcBadge("RequirementCompBadge","EntityNorthEast");
                this.isZCInitialized=true;
            end
        end
    end
end


function b=create_badge(id,panelName)
    try
        b=diagram.badges.create(id,panelName);
    catch Mex
        if strcmp(Mex.identifier,'diagram_badges:badges:DuplicateKey')
            b=diagram.badges.get(id,panelName);
        else
            throw(Mex);
        end
    end
end

function init_badge(badge,actFcn)
    badge.Image=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwReqBadge.png');
    badge.Tooltip=getString(message('Slvnv:slreq:TooltipOnBadge'));
    badge.setActionHandler(actFcn);
    badge.DefaultOpacity=0.7;
end

function b=create_zcBadge(id,panelName)
    try
        b=sysarch.syntax.architecture.createBadgeInfo(id,panelName);
    catch Mex
        if strcmp(Mex.identifier,'diagram_editor_registry:Badge:BadgeNameExists')
            b=sysarch.syntax.architecture.getBadgeInfo(id);
        else
            throw(Mex);
        end
    end
    b.setImagePath(fullfile(filesep,'toolbox','shared','reqmgt','icons','mwReqBadge.png'));
end

function tooltip=getZCTooltip(obj)
    dataLinks=slreq.utils.getLinks(obj);
    tooltip='';
    for i=1:length(dataLinks)
        if~isempty(tooltip)
            tooltip=[tooltip,newline];%#ok<AGROW>
        end
        dataLink=dataLinks(i);
        [adapter,artifactUri,artifactId]=dataLink.getDestAdapter();
        tltp=adapter.getSummary(artifactUri,artifactId);
        tooltip=[tooltip,tltp];%#ok<AGROW>
    end
end

function r=isZC(m)
    r=Simulink.internal.isArchitectureModel(m);
end
