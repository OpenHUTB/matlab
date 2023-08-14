classdef ArchModelTraverser<slreq.report.rtmx.utils.ModelTraverser



    properties
        AllViews;
        TargetViews;
Architecture
    end

    methods(Access=protected)
        function this=ArchModelTraverser()
            this@slreq.report.rtmx.utils.ModelTraverser()
            this.TypesAtTheEnd={'systemcomposer-view'};
        end
    end

    methods(Static)
        function obj=getInstance()


            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.ArchModelTraverser;
            end
            obj=cachedObj;
        end
    end

    methods


        function setArtifactInfo(this,artifactInfo)
            setArtifactInfo@slreq.report.rtmx.utils.ModelTraverser(this,artifactInfo);
            if isfield(artifactInfo,'ViewName')
                this.IsView=true;
                this.TargetViews=artifactInfo.ViewName;
            end
        end


        function traverseFlatList(this)
            this.setProgressRangeItems(0);
            modelItemData=this.createItemDataForView(get_param(this.ModelName,'Object'),'');
            modelItemData('ParentID')='';%#ok<NASGU> modification of the map object

            if Simulink.internal.isArchitectureModel(this.ModelName,'AUTOSARArchitecture')
                this.Architecture=autosar.arch.loadModel(this.ModelName);
                try
                    mf0Model=get_param(this.ModelName,'SystemComposerMF0Model');
                    zcModelImpl=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0Model);
                    viewImpls=zcModelImpl.getViews();
                    this.AllViews=systemcomposer.view.View.empty;
                    for index=1:length(viewImpls)
                        this.AllViews(end+1)=systemcomposer.internal.getWrapperForImpl(viewImpls(index));
                    end
                catch ex %#ok<NASGU> protection code
                    this.AllViews=[];
                end

            else
                archModel=systemcomposer.loadModel(this.ModelName);
                this.Architecture=archModel.Architecture;
                this.AllViews=archModel.Views;
            end



            this.traverseViews();
            this.traverseComposition();
        end


        function traverseComposition(this)
            [objHs,parentIdx,isSf,SIDs]=rmi('getobjectsInModel',this.ModelName);

            [objHs,parentIdx,isSf,SIDs]=this.updateElementsForSystemComposer(objHs,parentIdx,isSf,SIDs);





            annHs=find_system(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','LookUnderMasks','all','IncludeCommented','on','type','annotation');
            annSIDs=arrayfun(@(x)[':',get(x,'SID')],annHs,'UniformOutput',false);
            objHs=[objHs;annHs];
            parentIdx=[parentIdx;ones(size(annHs))];%#ok<NASGU>
            isSf=[isSf;false(size(annHs))];
            SIDs=[SIDs;annSIDs];
            allItemHandles=objHs;

            flatList=cell(size(allItemHandles));
            flIndex=0;
            for index=1:length(allItemHandles)
                if isSf(index)
                    continue;
                end
                cItemHandle=allItemHandles(index);
                itemDetails=this.createItemData(cItemHandle,SIDs{index});
                fullID=itemDetails('FullID');
                this.ItemDetails(fullID)=itemDetails;

                if strcmpi(itemDetails('IconType'),'simulink-chart')
                    chartId=sfprivate('block2chart',cItemHandle);
                    chartObj=idToHandle(sfroot,chartId);
                    sfFilter=rmisf.sfisa('isaFilter');
                    allChildren=chartObj.find(sfFilter);

                    flatList(length(flatList)+length(allChildren))={0};
                    for cIndex=1:length(allChildren)
                        cChild=allChildren(cIndex);
                        if cChild==chartObj
                            continue;
                        end
                        sfItemDetails=this.createItemDataSFObj(allChildren(cIndex));
                        sfFullID=sfItemDetails('FullID');
                        this.ItemDetails(sfFullID)=sfItemDetails;
                        flIndex=flIndex+1;
                        flatList{flIndex}=sfFullID;
                    end
                end

                flIndex=flIndex+1;
                flatList{flIndex}=fullID;
            end

            this.ItemList=flatList;
        end


        function traverseViews(this)
            for index=1:length(this.AllViews)
                cView=this.AllViews(index);





                itemData=this.createItemDataForView(cView,cView.Name);
                itemData('ParentID')=this.ArtifactID;
                itemData('Color')=cView.Color;
                allComponentOccurrences=cView.getImpl.p_ViewArchitecture.getComponents;

                for cIndex=1:length(allComponentOccurrences)

                    this.traverseComponentOccurrence(allComponentOccurrences(cIndex),itemData('FullID'),cView.Name);
                end
            end
        end



        function traverseComponentOccurrence(this,componentOccurrence,parentID,viewName)

















            if isa(componentOccurrence,'systemcomposer.architecture.model.views.ComponentGroup')
                elemGroup=systemcomposer.internal.getWrapperForImpl(componentOccurrence.p_Source);
                compItemData=this.createItemDataForView(elemGroup,viewName);
            else
                compItemData=this.createItemDataForView(componentOccurrence,viewName);
            end

            compFullID=compItemData('FullID');

            compItemData('ParentID')=parentID;%#ok<NASGU> map object modification.








            allCompOccurrences=componentOccurrence.getComponents;

            for cIndex=1:length(allCompOccurrences)
                cCompOccurrence=allCompOccurrences(cIndex);
                this.traverseComponentOccurrence(cCompOccurrence,compFullID,viewName);
            end


            allPorts=componentOccurrence.getPorts;
            for pIndex=1:length(allPorts)


                cPort=allPorts(pIndex).getArchitecturePort;
                portItemData=this.createItemDataForView(cPort,viewName);
                portItemData('ParentID')=compFullID;%#ok<NASGU> map object modification
            end
        end


        function slHandle=getSLHandleForViewElement(this,viewElem)
            redefElem=viewElem.p_Redefines;
            if isempty(redefElem)
                slHandle=systemcomposer.utils.getSimulinkPeer(viewElem);
            else
                slHandle=this.getSLHandleForViewElement(redefElem);
            end
        end


        function outData=createItemDataForView(this,archItem,viewName)
            import slreq.report.rtmx.utils.*
            itemArtifactID=this.ArtifactID;
            this.needContinue();
            if isa(archItem,'Simulink.BlockDiagram')
                fullID=this.ArtifactID;
                sid=get_param(this.ModelName,'filename');
                slType='systemcomposer-model';
                type='Model';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCSystemArchitecture'));
                subType='Block diagram';
                isRoot=true;
                longDesc=sid;
                desc=this.ModelName;
            elseif isa(archItem,'systemcomposer.view.View')||isa(archItem,'systemcomposer.view.ElementGroup')


                sid=['ZC:',archItem.UUID];
                fullID=[this.ArtifactID,'#',viewName,'#ZC:',archItem.UUID];
                if isa(archItem,'systemcomposer.view.View')
                    slType='systemcomposer-view';
                    type='ArchitectureView';
                    typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCArchitectureView'));
                    subType='Architecture View';
                    desc=archItem.Name;
                    isRoot=false;
                    longDesc=sprintf('%s in %s',viewName,this.ModelName);
                else
                    slType='systemcomposer-viewcomponent';
                    type='ComponentView';
                    typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCViewComponent'));
                    subType='View Component';
                    desc=archItem.Name;
                    isRoot=false;
                    longDesc=sprintf('View Component %s in %s',desc,viewName);
                end
            elseif isa(archItem,'systemcomposer.architecture.model.design.BaseComponent')

                itemHandle=this.getSLHandleForViewElement(archItem);
                if(itemHandle==-1)


                    disp('arch item is missing');
                    disp(archItem);
                    outData=containers.Map();
                    return;
                end
                sid=[':',get(itemHandle,'SID')];
                slType=slreq.utils.getSLType(this.ModelName,sid);
                [~,subType]=rmi.objname(itemHandle);

                isRoot=false;

                topArchName=archItem.getArchitecture().getTopLevelArchitecture().getName;

                if~bdIsLoaded(topArchName)


                    load_system(topArchName);
                end
                artId=get_param(topArchName,'FileName');
                if~isempty(artId)
                    itemArtifactID=artId;
                end

                fullID=[this.ArtifactID,'#',viewName,'#ZC:',archItem.UUID];

                desc=archItem.getName;
                longDesc=sprintf('%s in %s of %s',desc,viewName,this.ModelName);

                if archItem.isAdapterComponent
                    type='Adapter';
                    typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCAdapter'));
                    subType='Adapter';
                elseif archItem.isReferenceComponent
                    type='ComponentReference';
                    typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCComponentReference'));
                else
                    type='Component';
                    typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCComponent'));
                end
            elseif isa(archItem,'systemcomposer.architecture.model.design.ArchitecturePort')


                portActions=archItem.getPortAction;
                if strcmpi(portActions,'PHYSICAL')
                    slType='systemcomposer-physical-port';
                else
                    slType='systemcomposer-port';
                end

                sid=['ZC:',archItem.UUID];
                subType='';

                isRoot=false;
                fullID=[this.ArtifactID,'#',viewName,'#ZC:',archItem.UUID];

                desc=archItem.getName;
                longDesc=sprintf('%s in %s of %s',desc,viewName,this.ModelName);

                type='Port';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCPort'));
            else



            end
            linkKey=sid;

            itemData=ItemIDData(fullID);
            itemData.ItemID=sid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

            itemData.Desc=desc;
            itemData.LongDesc=longDesc;

            itemData.Domain=this.Domain;
            itemData.IsRoot=isRoot;
            itemData.Type=type;

            itemData.IconType=slType;
            this.updateTypeList(type,typeLabel);

            if~isempty(subType)
                itemData.SubType=[type,'##',subType];
            end

            itemData.ArtifactID=itemArtifactID;

            incomingLinks=[];
            if isKey(this.inLinksMap,linkKey)
                incomingLinks=this.inLinksMap(linkKey);
            end
            outgoingLinks=[];
            if isKey(this.outLinksMap,linkKey)
                outgoingLinks=this.outLinksMap(linkKey);
            end


            if~strcmp(itemArtifactID,this.ArtifactID)
                outgoingLinks=[outgoingLinks,this.getOutLinksForArtifact(itemArtifactID,sid,this.ArtifactID)];
            end

            itemData.updateLinkInfo(incomingLinks,outgoingLinks)

            outData=itemData.exportData();
            this.ItemDetails(fullID)=outData;
        end


        function outData=createItemData(this,itemHandle,sid)
            import slreq.report.rtmx.utils.*

            this.needContinue();

            linkKey=sid;
            fullID=[this.ModelName,sid];

            bObj=get(itemHandle,'Object');

            isRoot=false;
            itemData=ItemIDData(fullID);
            itemData.ItemID=sid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

            slType=slreq.utils.getSLType(this.ModelName,sid);
            [objName,subType]=rmi.objname(itemHandle);
            if isempty(objName)
                itemData.Desc='?';
            else
                itemData.Desc=objName;
            end
            itemData.LongDesc=getfullname(itemHandle);

            if isa(bObj,'Simulink.BlockDiagram')
                fullID=get_param(itemHandle,'filename');
                itemData=ItemIDData(fullID);

                itemData.ItemID=fullID;
                this.updateItemID2FullList(itemData.ItemID,itemData.FullID);

                type='Component';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCComponent'));
                subType='Block diagram';
                isRoot=true;
                itemData.Desc=this.ModelName;
                itemData.LongDesc=fullID;
            elseif strcmp(slType,'simulink-component')
                type='Component';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCComponent'));
            elseif strcmp(slType,'systemcomposer-port')||strcmp(slType,'systemcomposer-physical-port')
                type='Port';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCPort'));
            elseif isa(bObj,'Simulink.SubSystem')&&strcmp(bObj.SimulinkSubDomain,'ArchitectureAdapter')
                type='Adapter';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesZCAdapter'));
                subType='Adapter';
            elseif strcmp(slType,'simulink-chart')
                type='Component';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelStateflowObject'));
                subType='Stateflow';
            else
                type='LeafBlock';
                typeLabel=getString(message('Slvnv:slreq_rtmx:FilterTypesModelLeafBlock'));
            end

            itemData.Domain=this.Domain;
            itemData.IsRoot=isRoot;
            itemData.Type=type;

            itemData.IconType=slType;
            this.updateTypeList(type,typeLabel);

            if~isempty(subType)
                itemData.SubType=[type,'##',subType];
            end
            itemData.ArtifactID=this.ArtifactID;
            parentPath=get(itemHandle,'Parent');

            if isempty(parentPath)
                itemData.ParentID=[];
            else
                if isa(get_param(parentPath,'Object'),'Simulink.BlockDiagram')
                    parentID=get_param(parentPath,'filename');
                else
                    parentID=Simulink.ID.getSID(parentPath);
                end
                itemData.ParentID=parentID;
            end
            incomingLinks=[];
            if isKey(this.inLinksMap,linkKey)
                incomingLinks=this.inLinksMap(linkKey);
            end
            outgoingLinks=[];
            if isKey(this.outLinksMap,linkKey)
                outgoingLinks=this.outLinksMap(linkKey);
            end
            itemData.updateLinkInfo(incomingLinks,outgoingLinks)

            outData=itemData.exportData();
        end
    end

    methods(Access=private)
        function[objHs,parentIdx,isSf,SIDs]=updateElementsForSystemComposer(this,objHs,parentIdx,isSf,SIDs)

            removeIdx=[];
            for n=1:length(objHs)
                if isSf(n)
                    continue;
                else
                    bObj=get(objHs(n),'Object');
                end
                if isa(bObj,'Simulink.BlockDiagram')

                    allPorts=this.Architecture.Ports;

                    for index=1:length(allPorts)
                        cPort=allPorts(index);
                        appendPort(cPort.SimulinkHandle,n);
                    end
                    continue;
                end
                switch bObj.BlockType
                case{'SubSystem','ModelReference'}
                    ph=bObj.PortHandles;
                    for ip=1:length(ph.Inport)
                        appendPort(ph.Inport(ip),n);
                    end
                    for op=1:length(ph.Outport)
                        appendPort(ph.Outport(op),n);
                    end

                    for ip=1:length(ph.LConn)
                        appendPort(ph.LConn(ip),n);
                    end
                    for op=1:length(ph.RConn)
                        appendPort(ph.RConn(op),n);
                    end
                otherwise

                    removeIdx(end+1)=n;%#ok<AGROW>
                end
            end

            objHs(removeIdx)=[];
            parentIdx(removeIdx)=[];
            isSf(removeIdx)=[];
            SIDs(removeIdx)=[];

            function appendPort(pHs,idx)

                for i=1:length(pHs)
                    pH=pHs(i);

                    zcPort=systemcomposer.utils.getArchitecturePeer(pH);
                    if isempty(zcPort)

                        return;
                    end
                    objHs(end+1)=pH;%#ok<AGROW> 
                    parentIdx(end+1)=idx;%#ok<AGROW> 
                    isSf(end+1)=false;%#ok<AGROW> 
                    src=slreq.utils.getRmiStruct(zcPort);
                    SIDs{end+1}=src.id;%#ok<AGROW> 
                end
            end
        end
    end
end
