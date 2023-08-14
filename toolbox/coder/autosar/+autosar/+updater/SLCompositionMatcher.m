classdef SLCompositionMatcher<handle




    properties(Access=private)
PortMatcher

MdlName
UnmatchedModelBlockSet
UnmatchedSignalLines
    end

    methods(Access=public)
        function this=SLCompositionMatcher(mdlName)

            this.MdlName=mdlName;

            this.PortMatcher=autosar.updater.modelMapping.Port(mdlName);

            this.UnmatchedModelBlockSet=autosar.mm.util.Set(...
            'InitCapacity',40,...
            'KeyType','char',...
            'HashFcn',@(x)x);

            this.UnmatchedSignalLines=[];

            this.markAsUnmatched();
        end

        function[isMapped,blockPath]=isComponentPrototypeMapped(this,m3iCompPrototype)

            isMapped=false;
            blockPath=[];

            if~autosar.api.Utils.isMapped(this.MdlName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.MdlName);

            for ii=1:length(modelMapping.ModelBlocks)
                blockMapping=modelMapping.ModelBlocks(ii);
                if strcmp(blockMapping.MappedTo.PrototypeName,m3iCompPrototype.Name)


                    refModel=get_param(blockMapping.Block,'ModelName');
                    if~bdIsLoaded(refModel)
                        load_system(refModel);
                    end
                    compMapping=autosar.api.Utils.modelMapping(refModel);
                    if strcmp(compMapping.MappedTo.Name,m3iCompPrototype.Type.Name)
                        isMapped=true;
                        blockPath=blockMapping.Block;
                        break
                    end
                end
            end

            if~isempty(blockPath)
                this.UnmatchedModelBlockSet.remove(blockPath);
            end
        end

        function[isMapped,blockPath]=isPortElementMapped(this,m3iPort,m3iElement,slBlockType)
            [isMapped,blockPath]=this.PortMatcher.isMapped(m3iPort,m3iElement,slBlockType);
        end


        function[isMapped,isUpdatedBlk]=isIsUpdatedPortElementMapped(this,m3iPort,m3iElement,slBlockType)
            [isMapped,isUpdatedBlk]=this.PortMatcher.isMapped(m3iPort,m3iElement,slBlockType,'IsUpdated');
        end

        function[isMapped,errorStatusBlk]=isErrorStatusPortElementMapped(this,m3iPort,m3iElement,slBlockType)
            [isMapped,errorStatusBlk]=this.PortMatcher.isMapped(m3iPort,m3iElement,slBlockType,'ErrorStatus');
        end

        function isMapped=isSignalLineMapped(this,slSignalLine)
            isMapped=~isempty(find(arrayfun(@(x)isEqual(x,slSignalLine),this.UnmatchedSignalLines),1));




            if~isMapped&&slSignalLine.isLoopbackConnection
                if slSignalLine.getDstPortHandle()~=-1
                    srcBlockH=get_param(slSignalLine.getDstPortHandle,'SrcBlockHandle');
                    if strcmp(get_param(srcBlockH,'BlockType'),'FunctionCallFeedbackLatch')
                        feedbackLatchBlock=strrep(get(slSignalLine.getDstPortHandle,'SourcePort'),':','/');
                        slLine1=autosar.composition.mm2sl.SLSignalLine(this.MdlName,slSignalLine.SrcPort,feedbackLatchBlock);
                        slLine2=autosar.composition.mm2sl.SLSignalLine(this.MdlName,feedbackLatchBlock,slSignalLine.DstPort);
                        isMapped=~isempty(find(arrayfun(@(x)isEqual(x,slLine1),this.UnmatchedSignalLines),1))&&...
                        ~isempty(find(arrayfun(@(x)isEqual(x,slLine2),this.UnmatchedSignalLines),1));
                    end
                end
            end
        end

        function markSignalLineMatched(this,slSignalLine)
            index=find(arrayfun(@(x)isequal(x,slSignalLine),this.UnmatchedSignalLines));
            if~isempty(index)
                this.UnmatchedSignalLines(index)=[];
            else



                if slSignalLine.isLoopbackConnection
                    if slSignalLine.getDstPortHandle()~=-1
                        srcBlockH=get_param(slSignalLine.getDstPortHandle,'SrcBlockHandle');
                        if strcmp(get_param(srcBlockH,'BlockType'),'FunctionCallFeedbackLatch')
                            feedbackLatchBlock=strrep(get(slSignalLine.getDstPortHandle,'SourcePort'),':','/');
                            slLine1=autosar.composition.mm2sl.SLSignalLine(this.MdlName,...
                            slSignalLine.SrcPort,feedbackLatchBlock);
                            slLine2=autosar.composition.mm2sl.SLSignalLine(this.MdlName,...
                            feedbackLatchBlock,slSignalLine.DstPort);
                            index1=find(arrayfun(@(x)isequal(x,slLine1),this.UnmatchedSignalLines));
                            if~isempty(index1)
                                this.UnmatchedSignalLines(index1)=[];
                            end
                            index2=find(arrayfun(@(x)isequal(x,slLine2),this.UnmatchedSignalLines));
                            if~isempty(index2)
                                this.UnmatchedSignalLines(index2)=[];
                            end
                        end
                    end
                end
            end
        end

        function doDeletions(this,changeLogger)

            slSignalLines=this.UnmatchedSignalLines;
            for ii=1:length(slSignalLines)
                slSignalLine=slSignalLines(ii);
                changeLogger.logDeletion('Automatic',message('RTW:autosar:updateReportSignalLineLabel').getString(),slSignalLine.getLineLabel());
                slSignalLine.deleteLine();
            end


            this.PortMatcher.logDeletions(changeLogger,'DeleteBlockAndConnections');


            modelBlocks=this.UnmatchedModelBlockSet.getKeys();
            for ii=1:length(modelBlocks)
                blkPath=modelBlocks{ii};
                blockType=get_param(blkPath,'BlockType');
                changeLogger.logDeletion('Automatic',[blockType,' block'],blkPath);
                autosar.updater.SLCompositionMatcher.deleteBlockAndLeafElements(blkPath);
            end
        end


        function markConnectorsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.MdlName)
                return
            end


            modelBlocks=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            this.MdlName,'ModelReference','');
            for blkIdx=1:length(modelBlocks)
                this.markUnmatchedLinesForBlock(modelBlocks(blkIdx));
            end

            inports=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            this.MdlName,'Inport','','OutputFunctionCall','off');
            for blkIdx=1:length(inports)
                this.markUnmatchedLinesForBlock(inports(blkIdx));
            end


            feedbackLatchBlocks=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            this.MdlName,'FunctionCallFeedbackLatch','');
            for blkIdx=1:length(feedbackLatchBlocks)
                this.markUnmatchedLinesForBlock(feedbackLatchBlocks(blkIdx));
            end
        end
    end

    methods(Access=private)
        function markAsUnmatched(this)

            if~autosar.api.Utils.isMapped(this.MdlName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.MdlName);


            this.PortMatcher.markAsUnmatched();


            for ii=1:length(modelMapping.ModelBlocks)
                this.UnmatchedModelBlockSet.set(modelMapping.ModelBlocks(ii).Block);
            end




        end

        function markUnmatchedLinesForBlock(this,srcBlockH)

            this.UnmatchedSignalLines=[this.UnmatchedSignalLines
            autosar.updater.SLCompositionMatcher...
            .findCompositionSignalLinesFromSrcBlock(srcBlockH)];

        end
    end

    methods(Static)
        function slSignalLines=findCompositionSignalLinesFromSrcBlock(srcBlockH)














            blockType=get_param(srcBlockH,'BlockType');
            assert(any(strcmp(blockType,{'ModelReference','Inport','FunctionCallFeedbackLatch'})),...
            'Cannot mark connections for unsupported block Type %s.',blockType);

            slSignalLines=[];
            parentName=get_param(srcBlockH,'Parent');
            supportedDestBlocks={'ModelReference','Outport','FunctionCallFeedbackLatch'};

            blockPC=get_param(srcBlockH,'PortConnectivity');
            for pcIdx=1:length(blockPC)
                if isempty(blockPC(pcIdx).DstBlock)
                    continue;
                end

                dstBlkHandles=blockPC(pcIdx).DstBlock;
                dstPortNums=blockPC(pcIdx).DstPort;

                sourcePort=[get_param(srcBlockH,'Name'),'/',blockPC(pcIdx).Type];
                for dstBlkIdx=1:length(dstBlkHandles)
                    dstBlkHandle=dstBlkHandles(dstBlkIdx);
                    dstPortNum=dstPortNums(dstBlkIdx);

                    dstBlkType=get_param(dstBlkHandle,'BlockType');
                    switch(dstBlkType)
                    case 'Goto'

                        gotoBlkObj=get_param(dstBlkHandle,'Object');
                        fromBlks=[gotoBlkObj.FromBlocks.handle];
                        for fromIdx=1:length(fromBlks)
                            fromBlkPC=get_param(fromBlks(fromIdx),'PortConnectivity');
                            if~isempty(fromBlkPC.DstBlock)




                                for dstIdx=1:length(fromBlkPC.DstBlock)
                                    dstBlockType=get_param(fromBlkPC.DstBlock(dstIdx),'BlockType');
                                    assert(any(strcmp(dstBlockType,supportedDestBlocks)),...
                                    'connection to block type %s not supported.',dstBlockType);


                                    dstPort=[get_param(fromBlkPC.DstBlock(dstIdx),'Name'),'/',num2str(fromBlkPC.DstPort(dstIdx)+1)];
                                    slSignalLines=[slSignalLines
                                    autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                                end
                            end
                        end
                    case 'ModelReference'

                        dstPort=[get_param(dstBlkHandle,'Name'),'/',num2str(dstPortNum+1)];
                        slSignalLines=[slSignalLines
                        autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                    case 'Outport'

                        dstPort=[get_param(dstBlkHandle,'Name'),'/1'];
                        slSignalLines=[slSignalLines
                        autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                    case 'FunctionCallFeedbackLatch'

                        dstPort=[get_param(dstBlkHandle,'Name'),'/',num2str(dstPortNum+1)];
                        slSignalLines=[slSignalLines
                        autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                    otherwise

                    end
                end
            end
        end

        function deleteBlockAndLeafElements(blkPath)



            blockPC=get_param(blkPath,'PortConnectivity');
            for pcIdx=1:length(blockPC)
                srcBlock=blockPC(pcIdx).SrcBlock;
                if(srcBlock~=-1)
                    if any(strcmp(get_param(srcBlock,'BlockType'),{'Constant','Ground'}))||...
                        strcmp(get_param(srcBlock,'BlockType'),'Inport')&&...
                        strcmp(get_param(srcBlock,'OutputFunctionCall'),'on')


                        lh=get_param(srcBlock,'LineHandles');
                        if ishandle(lh.Outport)
                            delete(lh.Outport);
                        end


                        delete_block(srcBlock);
                    end
                end

                dstBlock=blockPC(pcIdx).DstBlock;
                if(dstBlock~=-1)
                    if strcmp(get_param(dstBlock,'BlockType'),'Terminator')

                        lh=get_param(dstBlock,'LineHandles');
                        if ishandle(lh.Inport)
                            delete(lh.Inport);
                        end


                        delete_block(dstBlock);
                    end
                end
            end

            delete_block(blkPath);
        end
    end
end


