classdef GotoFromCheck<handle




    properties(SetAccess=private,GetAccess=private)
Model
Systems
    end

    properties(SetAccess=private,GetAccess=private)
ConversionData
SubsystemConversionCheck
        GotoBlocks=[]
        FromBlocks=[]
        GotoTagVisibility=containers.Map;
        BlockGraph=[]
        Graph=[]
        Handle2Vertex=[]

        GotoBlockVids=[]
        FromBlockVids=[]

        Results={}
    end


    properties(Constant)
        FindOptions=Simulink.ModelReference.Conversion.GotoFromCheck.getFindOptions();
    end


    methods(Static,Access=public)

        function args=getFindOptions()
            args=horzcat(Simulink.ModelReference.Conversion.Utilities.BasicFindOptions,...
            {'MatchFilter',@Simulink.match.allVariants,'BlockType','Goto'});
        end

        function isChild=isChildOfBlock(blockHandle,subsystemHandle,modelHandle)
            workH=blockHandle;

            while(workH~=subsystemHandle&&workH~=modelHandle)
                workH=get_param(get_param(workH,'Parent'),'Handle');
            end

            isChild=(workH==subsystemHandle);
        end



        function check(subsys,params,check)
            this=Simulink.ModelReference.Conversion.GotoFromCheck(subsys,params,check);


            arrayfun(@(subsysH)this.exec(subsysH),this.Systems);


            if slfeature('RightClickBuild')
                if~params.ConversionParameters.RightClickBuild
                    if~isempty(this.Results)
                        cellfun(@(aMsg)this.ConversionData.Logger.addWarning(aMsg),this.Results);
                    end
                end
            else
                if~isempty(this.Results)
                    cellfun(@(aMsg)this.ConversionData.Logger.addWarning(aMsg),this.Results);
                end
            end


        end
    end

    methods(Access=private)
        function mdlGotoBlks=getAllGotoBlocksOfAModel(this)
            mdlGotoBlks={};
            visibility={'local','scoped','global'};
            for ii=1:numel(visibility)


                tmpGotoBlks=find_system(this.Model,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','BlockType','Goto',...
                'TagVisibility',visibility{ii});
                if~isempty(tmpGotoBlks)
                    tmpGotoBlks=get_param(tmpGotoBlks,'Handle');
                    if~iscell(tmpGotoBlks)
                        tmpGotoBlks={tmpGotoBlks};
                    end
                else
                    tmpGotoBlks={};
                end
                mdlGotoBlks=[mdlGotoBlks;tmpGotoBlks];%#ok
            end
        end

        function[containsPureVirtualBus,addRTB]=containsPureVirtualBusCrossGotoFromBlocks(~,blockHandle)
            blockType=get_param(blockHandle,'BlockType');
            isFromBlock=strcmp(blockType,'From');
            isGotoBlock=strcmp(blockType,'Goto');
            assert(isFromBlock||isGotoBlock);
            blockObj=get_param(blockHandle,'Object');

            if isFromBlock
                port=blockObj.PortHandles.Outport;
            else
                port=blockObj.PortHandles.Inport;
            end
            isPureVirtualBus=slInternal('isPureVirtualBus',port);
            containsVarDim=(sum(get_param(port,'CompiledPortDimensionsMode'))~=0);
            if~isPureVirtualBus||containsVarDim
                containsPureVirtualBus=false;
                addRTB=false;
            else
                signalHierarchy=get_param(port,'SignalHierarchy');
                if~isempty(signalHierarchy.BusObject)
                    containsPureVirtualBus=false;
                    addRTB=false;
                else
                    containsPureVirtualBus=true;
                    try
                        addRTB=Simulink.ModelReference.Conversion.PortUtils.portConnectedWithRTB(blockObj);
                    catch MME %#ok
                        addRTB=0;
                        if exist('sess','var')
                            delete(sess);
                        end
                    end
                end
            end
        end



        function this=GotoFromCheck(subsys,params,check)
            assert(all(ishandle(subsys)),'Input must be an array of handles');
            this.Model=bdroot(subsys(1));
            this.Systems=subsys;
            this.ConversionData=params;
            this.SubsystemConversionCheck=check;


            this.GotoBlocks=find_system(this.Model,this.FindOptions{:});

            if~isempty(this.GotoBlocks)

                this.FromBlocks=arrayfun(@(blkH)arrayfun(@(item)item.handle,get_param(blkH,'FromBlocks')),...
                this.GotoBlocks,'UniformOutput',false);


                this.BlockGraph=Simulink.ModelReference.BlockGraph.create(vertcat(this.FromBlocks{:},this.GotoBlocks));
                this.Graph=this.BlockGraph.Graph;
                this.Handle2Vertex=this.BlockGraph.VertexMap;


                this.GotoBlockVids=findIf(this.Graph,@(id,v,d)strcmp(d.Type,'Goto'),'Vertex');
                this.FromBlockVids=findIf(this.Graph,@(id,v,d)strcmp(d.Type,'From'),'Vertex');

                mdlGotoBlks=this.getAllGotoBlocksOfAModel();
                subsystemHandle=[];
                scopedInfo={};
                for subsystemIdx=1:numel(this.Systems)

                    strFromGoto.NumScopeBlocks=0;
                    strFromGoto.scopeBlocks=[];
                    for ii=1:numel(mdlGotoBlks)
                        tagName=sscanf(get_param(mdlGotoBlks{ii},'GotoTag'),'%s');
                        tagVisibility=get_param(mdlGotoBlks{ii},'TagVisibility');
                        fromBlk=[];
                        scopeBlock=[];
                        bScoped=0;
                        bLocalScope=0;


                        if strcmpi(tagVisibility,'scoped')


                            bScoped=1;
                            parentBlock=get_param(mdlGotoBlks{ii},'Parent');

                            while(~isempty(parentBlock))
                                parentBlkH=get_param(parentBlock,'Handle');
                                scopeBlock=find_system(parentBlkH,'LookUnderMasks','all',...
                                'FollowLinks','on','SearchDepth',1,...
                                'BlockType','GotoTagVisibility',...
                                'GotoTag',tagName);
                                if(~isempty(scopeBlock))
                                    break;
                                end
                                parentBlock=get_param(parentBlock,'Parent');
                            end



                            if isempty(scopeBlock)||iscell(scopeBlock)
                                DAStudio.error('RTW:buildProcess:slbusScopeInconsistency',tagName);
                            else
                                parentBlkH=get_param(get_param(scopeBlock,'Parent'),...
                                'Handle');
                                fromBlk=coder.internal.GotoFromChecks.getFromBlkForGoto(mdlGotoBlks{ii});



                            end

                            if length(fromBlk)>1
                                scopeSys=parentBlkH;
                                tempFromBlk=[];

                                for j=1:length(fromBlk)
                                    tmpScopeBlk=[];
                                    parentBlkH=get_param(fromBlk(j),'Handle');
                                    while(parentBlkH~=scopeSys&&isempty(tmpScopeBlk))
                                        parentBlkH=get_param(get_param(parentBlkH,'Parent'),'Handle');
                                        tmpScopeBlk=find_system(parentBlkH,'LookUnderMasks','all',...
                                        'FollowLinks','on','SearchDepth',1,...
                                        'BlockType','GotoTagVisibility',...
                                        'GotoTag',tagName);
                                    end
                                    if(parentBlkH==scopeSys)
                                        tempFromBlk(end+1)=fromBlk(j);%#ok<AGROW>
                                    end
                                end
                                fromBlk=tempFromBlk;
                            end
                        end

                        gotoBlkIsChild=coder.internal.GotoFromChecks.isChildOfBlk(mdlGotoBlks{ii},this.Systems(subsystemIdx),this.Model);
                        bSkipFrom=0;bSkipGoto=0;bSkipScope=0;
                        for j=1:length(fromBlk)
                            if~bSkipFrom
                                fromBlkIsChild=coder.internal.GotoFromChecks.isChildOfBlk(fromBlk(j),this.Systems(subsystemIdx),this.Model);
                                if fromBlkIsChild&&~gotoBlkIsChild
                                    bSkipFrom=1;
                                end
                            end
                            if gotoBlkIsChild&&~fromBlkIsChild
                                if~bSkipGoto
                                    bSkipGoto=1;
                                end
                            end

                            if bScoped&&~bSkipScope
                                scopeBlkIsChild=coder.internal.GotoFromChecks.isChildOfBlk(scopeBlock,this.Systems(subsystemIdx),this.Model);
                                if(gotoBlkIsChild||fromBlkIsChild)&&~scopeBlkIsChild
                                    strFromGoto.NumScopeBlocks=strFromGoto.NumScopeBlocks+1;
                                    strFromGoto.scopeBlocks(end+1)=scopeBlock;
                                    bSkipScope=1;
                                end
                            end
                        end
                    end

                    subsystemHandle=[subsystemHandle,this.Systems(subsystemIdx)];%#ok
                    scopedInfo={scopedInfo{:},strFromGoto};%#ok
                end
                this.GotoTagVisibility=containers.Map(subsystemHandle,scopedInfo);
            end
        end

        function compIOInfo=getCompiledIOInfoOfgotofrom(this,currentSubsystem,ssPortBlks)
            conversionSubsystemCheck=this.SubsystemConversionCheck;
            model=this.Model;
            useNewTemporaryModel=true;
            createBusObjectsForAllBuses=false;
            useTempModelAndNotCreateBusObjects=useNewTemporaryModel&&~createBusObjectsForAllBuses;

            compIOInfo=Simulink.ModelReference.Conversion.PortUtils.getCompiledIOInfo(ssPortBlks,currentSubsystem,useTempModelAndNotCreateBusObjects);




            bclist=get_param(model,'BackPropagatedBusObjects');
            displayWarningAboutBusName=false;
            isConvertingSubsystemToModelButNotExportFunctionModel=true;
            calculateSampleTimeForEachComponentOfVirtualBus=~createBusObjectsForAllBuses&&useNewTemporaryModel;
            compIOInfo=sl('slbus_gen_object',compIOInfo,calculateSampleTimeForEachComponentOfVirtualBus,isConvertingSubsystemToModelButNotExportFunctionModel,...
            bclist,0,conversionSubsystemCheck.DataAccessor,displayWarningAboutBusName);


            numberOfCompIOInfos=length(compIOInfo);
            for idx=1:numberOfCompIOInfos
                compIOInfo(idx).portAttributes=Simulink.CompiledPortInfo(compIOInfo(idx).port);
            end
        end

        function exec(this,subsysH)
            if~isempty(this.BlockGraph)&&this.BlockGraph.VertexMap.isKey(subsysH)
                currentVId=this.BlockGraph.VertexMap(subsysH);


                childNodes=this.Graph.depthFirstTraverse(currentVId);


                gotoBlocks=intersect(childNodes,this.GotoBlockVids);


                fromBlocks=intersect(childNodes,this.FromBlockVids);


                invalidOutsideFromBlocks=[];
                numberOfBlocks=numel(gotoBlocks);
                for idx=1:numberOfBlocks
                    gotoBlock=gotoBlocks(idx);
                    gotoBlockHandle=this.Graph.vertex(gotoBlock).Data.ID;


                    fromBlockHandles=this.FromBlocks{this.GotoBlocks==gotoBlockHandle};
                    fromBlockVids=arrayfun(@(h)this.Handle2Vertex(h),fromBlockHandles);
                    invalidFromBlocks=setdiff(fromBlockVids,fromBlocks);
                    if~isempty(invalidFromBlocks)
                        invalidOutsideFromBlocks=vertcat(invalidOutsideFromBlocks,invalidFromBlocks);%#ok
                        invalidFromBlockHandles=arrayfun(@(item)item.Data.ID,this.Graph.vertex(invalidFromBlocks));
                        this.generateErrorMessages(subsysH,invalidFromBlockHandles);


                        gotoBlockHandle=this.Graph.vertex(gotoBlock).Data.ID;
                        ph=get_param(gotoBlockHandle,'PortHandles');
                        portInfo={Simulink.CompiledPortInfo(ph.Inport)};


                        [containsPureVirtualBus,addRTB]=this.containsPureVirtualBusCrossGotoFromBlocks(gotoBlockHandle);

                        gotoBlockStruct.gotoBlksH.blocks=gotoBlockHandle;
                        gotoBlockStruct.gotoBlksH.portHs=ph.Inport;

                        compIOInfo=this.getCompiledIOInfoOfgotofrom(subsysH,gotoBlockStruct);
                        portInfoExtra.containsPureVirtualBus=containsPureVirtualBus;
                        portInfoExtra.addRTB=addRTB;
                        portInfoExtra.compIOInfo=compIOInfo;
                        portInfoMap=containers.Map(gotoBlockHandle,portInfoExtra);
                        this.ConversionData.addNewModelFixObj(Simulink.ModelReference.Conversion.FixInsideGotoBlock(...
                        subsysH,gotoBlockHandle,portInfo,this.ConversionData,portInfoMap));

                        this.ConversionData.SkipVirtualSubsystemCheck=true;

                    end


                    fromBlocks=setdiff(fromBlocks,fromBlockVids);
                end




                if~isempty(fromBlocks)
                    invalidFromBlockHandles=arrayfun(@(item)item.Data.ID,this.Graph.vertex(fromBlocks));
                    this.generateErrorMessages(subsysH,invalidFromBlockHandles);


                    outsideGotoBlocks=unique(arrayfun(@(item)item.handle,...
                    arrayfun(@(fromBlock)get_param(fromBlock,'GotoBlock'),invalidFromBlockHandles)));
                    N=numel(outsideGotoBlocks);
                    portInfos=cell(1,N);
                    extraPortInfos={};
                    for idx=1:N
                        ph=get_param(outsideGotoBlocks(idx),'PortHandles');
                        portInfos{idx}=Simulink.CompiledPortInfo(ph.Inport);

                        if strcmp(portInfos{idx}.DataType,'fcn_call')
                            this.ConversionData.FcnCallCrossBoundaryWithGotoFrom=true;
                        end

                        [containsPureVirtualBus,addRTB]=this.containsPureVirtualBusCrossGotoFromBlocks(outsideGotoBlocks(idx));

                        gotoBlockStruct.gotoBlksH.blocks=outsideGotoBlocks(idx);
                        gotoBlockStruct.gotoBlksH.portHs=ph.Inport;
                        compIOInfo=this.getCompiledIOInfoOfgotofrom(subsysH,gotoBlockStruct);

                        extraPortInfo.containsPureVirtualBus=containsPureVirtualBus;
                        extraPortInfo.addRTB=addRTB;
                        extraPortInfo.compIOInfo=compIOInfo;

                        extraPortInfos={extraPortInfos{:},extraPortInfo};%#ok
                    end
                    portInfoMap=containers.Map(outsideGotoBlocks,extraPortInfos);

                    this.ConversionData.addNewModelFixObj(...
                    Simulink.ModelReference.Conversion.FixOutsideGotoBlock(subsysH,outsideGotoBlocks,...
                    portInfos,this.ConversionData,this.SubsystemConversionCheck,portInfoMap));





                    this.ConversionData.SkipVirtualSubsystemCheck=true;
                end

                if~isempty(this.GotoTagVisibility)
                    scopedBlocks=this.GotoTagVisibility(subsysH);
                    if iscell(scopedBlocks)
                        scopedBlocks=scopedBlocks{:};
                    end
                    gotoTagVisibilityBlocks=scopedBlocks.scopeBlocks;
                    fakePortInfo=cell(1,numel(gotoTagVisibilityBlocks));
                    [fakePortInfo{:}]=deal({1});
                    this.ConversionData.addNewModelFixObj(...
                    Simulink.ModelReference.Conversion.FixScopedGotoBlocks(subsysH,gotoTagVisibilityBlocks,fakePortInfo,...
                    this.ConversionData,this.SubsystemConversionCheck,[],...
                    this.GotoTagVisibility));
                end
            end
        end


        function generateErrorMessages(this,subsysH,fromBlockHandles)
            gotoBlockHandles=arrayfun(@(item)item.handle,...
            arrayfun(@(fromBlock)get_param(fromBlock,'GotoBlock'),fromBlockHandles));
            N=numel(fromBlockHandles);
            currentSubsystem=this.ConversionData.beautifySubsystemName(subsysH);
            for idx=1:N
                this.Results{end+1}=message('Simulink:modelReferenceAdvisor:InvalidGotoFromPair',...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                getfullname(gotoBlockHandles(idx)),gotoBlockHandles(idx)),...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                getfullname(fromBlockHandles(idx)),fromBlockHandles(idx)),...
                currentSubsystem);
            end
        end
    end
end
