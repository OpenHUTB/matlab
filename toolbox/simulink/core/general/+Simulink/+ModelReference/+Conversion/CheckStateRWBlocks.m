classdef CheckStateRWBlocks<handle
    properties(SetAccess=private,GetAccess=public)
        StateAccessorInfoMap=[]
        StateOwnerBlocks=[]
        StateReaderBlockSet={}
        StateWriterBlockSet={}
        ConversionData=[]
        Graph=[]
    end

    methods(Static,Access=public)
        function check(params)
            aModel=params.ConversionParameters.Model;
            checkObj=Simulink.ModelReference.Conversion.CheckStateRWBlocks(aModel,params);
            arrayfun(@(aBlk)checkObj.exec(aBlk),params.ConversionParameters.Systems);
        end

        function blks=filterCommentedBlocks(blks)
            aMask=arrayfun(@(aBlk)strcmpi(get_param(aBlk,'Commented'),'off'),blks);
            blks=blks(aMask);
        end
    end

    methods(Access=public)
        function this=CheckStateRWBlocks(aModel,params)
            this.StateAccessorInfoMap=get_param(aModel,'StateAccessorInfoMap');
            if~isempty(this.StateAccessorInfoMap)
                this.StateOwnerBlocks=arrayfun(@(item)Simulink.ModelReference.Conversion.CheckStateRWBlocks.filterCommentedBlocks(item.StateOwnerBlock),...
                this.StateAccessorInfoMap);
                this.StateReaderBlockSet=arrayfun(@(item)Simulink.ModelReference.Conversion.CheckStateRWBlocks.filterCommentedBlocks(item.StateReaderBlockSet),...
                this.StateAccessorInfoMap,'UniformOutput',false);
                this.StateWriterBlockSet=arrayfun(@(item)Simulink.ModelReference.Conversion.CheckStateRWBlocks.filterCommentedBlocks(item.StateWriterBlockSet),...
                this.StateAccessorInfoMap,'UniformOutput',false);
                blks=horzcat(this.StateOwnerBlocks,this.StateReaderBlockSet{:},this.StateWriterBlockSet{:});
                this.ConversionData=params;
                this.Graph=Simulink.ModelReference.BlockGraph.create(blks);
            end
        end

        function exec(this,subsys)
            if~isempty(this.Graph)&&this.Graph.VertexMap.isKey(subsys)
                g=this.Graph.Graph;
                vid=this.Graph.VertexMap(subsys);



                childVids=g.depthFirstTraverse(vid);
                vertexes=g.vertex(childVids);



                excludedTypes={'SubSystem','StateReader','StateWriter'};
                stateOwnerVertexes=vertexes(arrayfun(@(item)...
                ~any(strcmp(item.Data.Type,excludedTypes))&&~item.Data.Commented,vertexes));
                stateOwnerBlks=arrayfun(@(item)item.Data.ID,stateOwnerVertexes);

                stateReaderVertexes=vertexes(arrayfun(@(item)...
                strcmp(item.Data.Type,'StateReader')&&~item.Data.Commented,vertexes));
                stateReaderBlks=arrayfun(@(item)item.Data.ID,stateReaderVertexes);

                stateWriterVertexes=vertexes(arrayfun(@(item)...
                strcmp(item.Data.Type,'StateWriter')&&~item.Data.Commented,vertexes));
                stateWriterBlks=arrayfun(@(item)item.Data.ID,stateWriterVertexes);

                if isempty(stateOwnerBlks)

                    invalidReaderBlks=stateReaderBlks;
                    invalidWriterBlks=stateWriterBlks;
                else
                    aMask=this.StateOwnerBlocks==stateOwnerBlks(1);
                    for idx=2:numel(stateOwnerBlks)
                        aMask=aMask|this.StateOwnerBlocks==stateOwnerBlks(idx);
                    end

                    readerBlks=horzcat(this.StateReaderBlockSet{aMask});
                    invalidReaderBlks=setxor(readerBlks,stateReaderBlks,'stable');

                    writerBlks=horzcat(this.StateWriterBlockSet{aMask});
                    invalidWriterBlks=setxor(writerBlks,stateWriterBlks,'stable');
                end

                if~isempty(invalidReaderBlks)||~isempty(invalidWriterBlks)
                    ssName=this.ConversionData.beautifySubsystemName(subsys);


                    msgs=horzcat(arrayfun(@(aBlk)message('Simulink:modelReferenceAdvisor:StateReaderBlockCrossSubsystemBoundary',...
                    ssName,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(aBlk),aBlk)),...
                    invalidReaderBlks,'UniformOutput',false),...
                    arrayfun(@(aBlk)message('Simulink:modelReferenceAdvisor:StateWriterBlockCrossSubsystemBoundary',...
                    ssName,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(aBlk),aBlk)),...
                    invalidWriterBlks,'UniformOutput',false));
                    if~isempty(msgs)
                        me=MException(message('Simulink:modelReferenceAdvisor:CannotConvertSubsystem',ssName));
                        for idx=1:numel(msgs)
                            me=me.addCause(MException(msgs{idx}));
                        end
                        throw(me);
                    end
                end
            end
        end
    end
end

