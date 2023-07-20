



classdef ScopedDataStoreMemoryCheck<handle



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


            this=Simulink.ModelReference.Conversion.ScopedDataStoreMemoryCheck(subsys,params);
            arrayfun(@(ss)this.exec(ss),this.Systems);
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

                this.createExceptions;
                if(~isempty(this.ConversionData.DSMReferenceCopyInfo))
                    this.ConversionData.addNewModelFixObj(...
                    Simulink.ModelReference.Conversion.ScopedDataStoreMemoryFix(...
                    this.ConversionData));
                end

            end
        end


        function this=ScopedDataStoreMemoryCheck(subsys,params)
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
                    if(slfeature('scopeddsm')>0)

                        signalAttribute=get_param(dsmBlock,'CachedCompiledSignalAttr');
                        DSMReferenceCopyInfo.DSM=dsmBlock;
                        DSMReferenceCopyInfo.dataStoreName=get_param(dsmBlock,'datastorename');
                        DSMReferenceCopyInfo.Subsys=subsysH;
                        DSMReferenceCopyInfo.Dim=signalAttribute.Dimensions;
                        DSMReferenceCopyInfo.DataType=signalAttribute.DataType;
                        DSMReferenceCopyInfo.SignalType=signalAttribute.SignalType;
                        this.ConversionData.addDSMReferenceCopyInfo(DSMReferenceCopyInfo);

                    else
                        results{end+1}=this.createErrorMessage(dsmBlock,accessBlock,subsysH);%#ok
                        problematicSystems(end+1)=subsysH;%#ok
                    end
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


