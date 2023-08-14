



classdef DataStoreMemoryCheck<handle



    properties(SetAccess=private,GetAccess=private)
Model
Systems
BlockGraph
DSMBlocks
DSRWBlocks
    end


    properties(SetAccess=private,GetAccess=private)
DataStoreRWMap
DataStoreMemoryMap
DataStoreMemoryVertexIds
AccessorVertexIds


ConversionData
ConversionParameters
DataAccessor

Handle2Vertex

        InvalidPairs={}
        InvalidSubsystems=[]
        IgnoredDSMBlocks=[]
    end


    methods(Static,Access=public)
        function check(subsys,params)
            if iscell(subsys)
                subsys=cellfun(@(blk)get_param(blk,'Handle'),subsys);
            elseif ischar(subsys)
                subsys=get_param(subsys,'Handle');
            end


            this=Simulink.ModelReference.Conversion.DataStoreMemoryCheck(subsys,params);
            arrayfun(@(ss)this.exec(ss),this.Systems);
            if~isempty(this.InvalidPairs)
                this.createFixObject;
                this.createExceptions;
            end
        end
    end


    methods(Access=private)
        function exec(this,subsysH)
            if~isempty(this.BlockGraph)&&this.BlockGraph.VertexMap.isKey(subsysH)
                currentVId=this.BlockGraph.VertexMap(subsysH);
                g=this.BlockGraph.Graph;


                childNodes=g.depthFirstTraverse(currentVId);



                dsmBlocks=intersect(this.DataStoreMemoryVertexIds,childNodes);
                accessorBlocks=intersect(this.AccessorVertexIds,childNodes);




                for dsmIdx=1:numel(dsmBlocks)
                    dsmBlock=dsmBlocks(dsmIdx);
                    rwBlocks=this.DataStoreMemoryMap{this.DataStoreMemoryVertexIds==dsmBlock};


                    mask=arrayfun(@(rwBlock)(all(arrayfun(@(blk)any(dsmBlocks==blk),this.DataStoreRWMap(rwBlock)))),rwBlocks);
                    accessorBlocks=setdiff(accessorBlocks,rwBlocks(mask));
                end




                for blkIdx=1:numel(accessorBlocks)
                    rwBlock=accessorBlocks(blkIdx);




                    usedDSMBlocks=setdiff(this.DataStoreRWMap(rwBlock),dsmBlocks);
                    usedDSMBlockHandles=arrayfun(@(v)v.Data.ID,g.vertex(usedDSMBlocks));
                    numberOfDSMBlocks=numel(usedDSMBlockHandles);
                    for dsmIdx=1:numberOfDSMBlocks
                        dsmBlock=usedDSMBlockHandles(dsmIdx);
                        if~this.isGlobalDSM(dsmBlock)
                            this.InvalidPairs{end+1}=[usedDSMBlocks(dsmIdx),rwBlock];
                            this.InvalidSubsystems(end+1)=subsysH;
                        end
                    end
                end
            end
        end


        function this=DataStoreMemoryCheck(subsys,params)
            this.Systems=subsys;
            this.Model=get_param(bdroot(subsys(1)),'Handle');
            this.ConversionData=params;
            this.ConversionParameters=params.ConversionParameters;
            this.DataAccessor=params.DataAccessor;
            this.init;
        end


        function init(this)
            assert(Simulink.SubsystemType.isBlockDiagram(this.Model),'Invalid block diagram name or handle!');
            this.DSMBlocks=slInternal('getDataStoreBlocks',this.Model);
            if~isempty(this.DSMBlocks)

                numberOfDSMBlocks=numel(this.DSMBlocks);
                for dsmIdx=1:numberOfDSMBlocks
                    dsmBlock=this.DSMBlocks(dsmIdx);
                    this.DSRWBlocks{dsmIdx}=arrayfun(@(item)item.handle,slInternal('getDataStoreReadWriteBlocks',dsmBlock));
                end


                allBlocks=vertcat(this.DSRWBlocks{:},this.DSMBlocks);
                this.BlockGraph=Simulink.ModelReference.BlockGraph.create(allBlocks);

                g=this.BlockGraph.Graph;
                this.Handle2Vertex=this.BlockGraph.VertexMap;


                commentedNodes=findIf(g,@(id,v,d)(d.Commented==1),'Vertex');
                if~isempty(commentedNodes)
                    this.BlockGraph.removeVertexes(commentedNodes);
                    this.Handle2Vertex=this.BlockGraph.VertexMap;

                    for dsmIdx=1:numberOfDSMBlocks
                        rwBlocks=this.DSRWBlocks{dsmIdx};
                        this.DSRWBlocks{dsmIdx}=rwBlocks(arrayfun(@(blk)this.Handle2Vertex.isKey(blk),rwBlocks));
                    end
                end


                this.DataStoreMemoryVertexIds=findIf(g,@(id,v,d)strcmp(d.Type,'DataStoreMemory'),'Vertex');
                numberOfDSMBlocks=numel(this.DataStoreMemoryVertexIds);


                this.DataStoreMemoryMap=cell(numberOfDSMBlocks,1);


                this.DataStoreRWMap=containers.Map('KeyType','uint64','ValueType','any');


                for dsmIdx=1:numberOfDSMBlocks
                    dsmVid=this.DataStoreMemoryVertexIds(dsmIdx);
                    accessorBlockVids=[];
                    if g.isVertex(dsmVid)
                        dsmBlock=g.vertex(dsmVid).Data.ID;
                        accessorBlocks=this.DSRWBlocks{this.DSMBlocks==dsmBlock};
                        numberOfAccessorBlocks=numel(accessorBlocks);
                        for idx=1:numberOfAccessorBlocks
                            accessorBlock=accessorBlocks(idx);
                            vid=this.Handle2Vertex(accessorBlock);
                            if g.isVertex(vid)
                                this.AccessorVertexIds(end+1)=vid;


                                if this.DataStoreRWMap.isKey(vid)
                                    val=this.DataStoreRWMap(vid);
                                    this.DataStoreRWMap(vid)=[val,dsmVid];
                                else
                                    this.DataStoreRWMap(vid)=dsmVid;
                                end
                                accessorBlockVids(end+1)=vid;%#ok
                            end
                        end
                    end
                    this.DataStoreMemoryMap{dsmIdx}=accessorBlockVids;
                end
                this.AccessorVertexIds=unique(this.AccessorVertexIds);
            end
        end


        function createFixObject(this)
            g=this.BlockGraph.Graph;



            dsmBlockVids=unique(cellfun(@(aPair)aPair(1),this.InvalidPairs),'stable');
            dsmBlocks=arrayfun(@(vid)g.vertex(vid).Data.ID,dsmBlockVids);
            rwBlocks=arrayfun(@(dsmBlock)this.DSRWBlocks{this.DSMBlocks==dsmBlock},dsmBlocks,'UniformOutput',false);



            mask=this.getFixableDataStoreBlockMask(rwBlocks,this.ConversionParameters.RightClickBuild);


            subsys=this.InvalidSubsystems(mask);
            dsmBlocks=dsmBlocks(mask);
            rwBlocks=rwBlocks(mask);
            if~isempty(dsmBlocks)
                if this.ConversionParameters.RightClickBuild
                    this.ConversionData.addNewModelFixObj(...
                    Simulink.ModelReference.Conversion.DataStoreFixForRightClickBuild(...
                    this.ConversionData,subsys,dsmBlocks));
                else
                    N=numel(dsmBlocks);


                    excludedNames=get_param(this.DSMBlocks,'DataStoreName');







                    simpleCaseMask=arrayfun(@(blkIdx)this.isSimpleCase(rwBlocks{blkIdx},subsys(blkIdx)),1:N);
                    if any(simpleCaseMask)
                        currentSystems=subsys(simpleCaseMask);
                        simpleDSMBlocks=dsmBlocks(simpleCaseMask);
                        simpleRWBlocks=rwBlocks(simpleCaseMask);
                        N=numel(currentSystems);

                        if this.ConversionParameters.ReplaceSubsystem


                            this.ConversionData.addSystemFixObj(...
                            Simulink.ModelReference.Conversion.DataStoreMemoryFixSimpleCaseForSubsystem(...
                            this.ConversionData,currentSystems,simpleDSMBlocks));

                        else
                            this.ConversionData.addNewModelFixObj(...
                            Simulink.ModelReference.Conversion.DataStoreMemoryFixSimpleCase(...
                            this.ConversionData,currentSystems,simpleDSMBlocks));

                            for idx=1:N
                                blks=simpleRWBlocks{idx};
                                for blkIdx=1:numel(blks)
                                    this.ConversionData.Logger.addWarning(this.createErrorMessage(...
                                    simpleDSMBlocks(idx),blks(blkIdx),currentSystems(idx)));
                                end
                            end
                            this.IgnoredDSMBlocks=simpleDSMBlocks;
                        end
                    end



                    aMask=~simpleCaseMask;
                    if any(aMask)
                        this.ConversionData.addTopModelFixObj(...
                        Simulink.ModelReference.Conversion.DataStoreMemoryFix(dsmBlocks(aMask),rwBlocks(aMask),...
                        excludedNames,this.ConversionData));
                    end
                end
            end
        end


        function isOK=isSimpleCase(this,rwBlocks,subsys)
            g=this.BlockGraph.Graph;
            rwBlockVids=arrayfun(@(blk)this.Handle2Vertex(blk),rwBlocks);
            rwBlockInsideSubsys=g.depthFirstTraverse(this.Handle2Vertex(subsys));
            isOK=isempty(setdiff(rwBlockVids,rwBlockInsideSubsys));
        end


        function createExceptions(this)
            g=this.BlockGraph.Graph;
            results={};
            problematicSystems=[];
            numberOfInvalidPairs=numel(this.InvalidSubsystems);
            for idx=1:numberOfInvalidPairs
                invalidPair=this.InvalidPairs{idx};
                dsmBlock=g.vertex(invalidPair(1)).Data.ID;
                if isempty(this.IgnoredDSMBlocks)||any(this.IgnoredDSMBlocks~=dsmBlock)
                    accessBlock=g.vertex(invalidPair(2)).Data.ID;
                    subsysH=this.InvalidSubsystems(idx);
                    results{end+1}=this.createErrorMessage(dsmBlock,accessBlock,subsysH);%#ok
                    problematicSystems(end+1)=subsysH;%#ok
                end
            end

            if~isempty(results)
                if this.ConversionParameters.Force
                    cellfun(@(msg)warning(msg),results);
                elseif this.ConversionParameters.RightClickBuild


                    cellfun(@(aMsg)this.ConversionData.Logger.addInfo(aMsg),results);
                else
                    subsysNames=arrayfun(@(subsys)this.ConversionData.beautifySubsystemName(subsys),...
                    unique(problematicSystems),'UniformOutput',false);
                    nameString=Simulink.ModelReference.Conversion.Utilities.cellstr2str(subsysNames,'','');
                    me=MException(message('Simulink:modelReferenceAdvisor:CannotConvertSubsystem',nameString));
                    N=numel(results);
                    for idx=1:N
                        me=me.addCause(MException(results{idx}));
                    end
                    throw(me);
                end
            end
        end


        function msg=createErrorMessage(this,dsmBlock,accessBlock,subsysH)
            msg=message('Simulink:modelReferenceAdvisor:LocalDataStoreCrossSubsystemBoundary',...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(dsmBlock),dsmBlock),...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(accessBlock),accessBlock),...
            this.ConversionData.beautifySubsystemName(subsysH));
        end
    end


    methods(Static,Access=private)
        function results=isGlobalDSM(dsmBlock)
            obj=get_param(dsmBlock,'Object');
            results=isempty(obj.getParent);
        end

        function mask=getFixableDataStoreBlockMask(rwBlocks,isRightClickBuild)

            mask=cellfun(@(blkHs)~any(arrayfun(@(aBlk)...
            (slprivate('is_stateflow_based_block',aBlk)||slprivate('is_stateflow_based_block',get_param(aBlk,'Parent')))&&~isRightClickBuild,blkHs)),rwBlocks);
        end
    end
end


