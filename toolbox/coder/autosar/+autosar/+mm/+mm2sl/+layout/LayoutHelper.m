classdef LayoutHelper<handle





    properties(Constant,Access=private)

        CentralCategoryBlockTypes={'ModelReference','SubSystem'};


        LeafCategoryBlockTypes={'Inport','Outport','Constant','Terminator',...
        'Ground','ArgIn','ArgOut','Goto','From'};



        BetweenCategoryBlockTypes={'Merge','AsynchronousTaskSpecification',...
        'VariantSource','VariantSink','FunctionCaller','RateTransition',...
        'FunctionCallFeedbackLatch'};


        FloatingCategoryBlockTypes={'EventListener','TriggerPort','DataStoreMemory',...
        'Interpolation_n-D','Lookup_n-D','PreLookup'};


        LineRoutingMode='on';
    end

    properties(Constant)

        CanvasLimit=intmax('int32');




        CanvasMinX=500;
        CanvasMinY=500;


        BlockTypeToLayoutBlockCategoryMap=...
        autosar.mm.mm2sl.layout.LayoutHelper.getBlockTypeToBlockCategoryMap();
    end

    methods(Static)
        function homedBlks=homeSrcAndDstBlocks(centralBlocks)














            homedBlks={};

            if isempty(centralBlocks)
                return;
            end


            for centBlkIdx=1:length(centralBlocks)
                centBlk=centralBlocks(centBlkIdx);
                assert(any(strcmp(get_param(centBlk,'BlockType'),...
                autosar.mm.mm2sl.layout.LayoutHelper.CentralCategoryBlockTypes)),...
                '%s is not a central block type.',getfullname(centBlk));
            end


            for centBlkIdx=1:length(centralBlocks)
                centBlk=centralBlocks(centBlkIdx);

                pc=get_param(centBlk,'PortConnectivity');
                pcDstHandle=[pc.DstBlock];
                pcSrcHandle=[pc.SrcBlock];




                betweenOutHandles={};
                leafOutHandles={};

                betweenMaxWidth=0;



                for dstIdx=1:length(pcDstHandle)
                    if pcDstHandle(dstIdx)==-1,continue;end


                    dstBlockType=get_param(pcDstHandle(dstIdx),'BlockType');
                    blockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(dstBlockType);
                    switch blockCategory
                    case 'LeafBlock'



                        leafOutHandles=[leafOutHandles,pcDstHandle(dstIdx)];%#ok <AGROW>
                    case 'BetweenBlock'



                        betweenPc=get_param(pcDstHandle(dstIdx),'PortConnectivity');
                        betweenDstBlock=[betweenPc.DstBlock];
                        if length(betweenDstBlock)~=1




                            continue
                        end
                        betweenDstBlockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(get_param(betweenDstBlock,'BlockType'));
                        switch betweenDstBlockCategory
                        case 'CentralBlock'


                        case 'BetweenBlock'





                        case 'LeafBlock'
                            betweenOutHandles=[betweenOutHandles,pcDstHandle(dstIdx)];%#ok <AGROW>
                            leafOutHandles=[leafOutHandles,betweenDstBlock];%#ok <AGROW>

                            betweenPos=get(pcDstHandle(dstIdx),'Position');
                            betweenMaxWidth=max(betweenMaxWidth,(betweenPos(3)-betweenPos(1)));
                        otherwise
                            assert(false,'Unexpected dst block category: "%s"',betweenDstBlockCategory);
                        end
                    case 'CentralBlock'

                    otherwise
                        assert(false,'Unexpected block category "%s" connected to central block output.',blockCategory);
                    end
                end

                if~isempty(leafOutHandles)||~isempty(betweenOutHandles)
                    autosar.mm.mm2sl.MRLayoutManager.homeBlockLayers(betweenOutHandles,leafOutHandles,'east');
                    homedBlks=[homedBlks,betweenOutHandles{:},leafOutHandles{:}];%#ok<AGROW>
                end




                betweenInHandles={};
                leafInHandles={};



                fcnCallInportBlkLeaf=[];
                asyncTaskSpecBlkBetween=[];

                betweenMaxWidth=0;
                for srcIdx=1:length(pcSrcHandle)
                    if pcSrcHandle(srcIdx)==-1,continue;end


                    blockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(get_param(pcSrcHandle(srcIdx),'BlockType'));
                    switch blockCategory
                    case 'LeafBlock'





                        leafInPh=get(pcSrcHandle(srcIdx),'PortHandles');
                        leafInLine=get([leafInPh.Outport],'Line');
                        portHandle=get(leafInLine,'DstPortHandle');
                        if strcmp(get(portHandle,'PortType'),'trigger')
                            fcnCallInportBlkLeaf=pcSrcHandle(srcIdx);
                        else
                            leafInHandles=[leafInHandles,pcSrcHandle(srcIdx)];%#ok <AGROW>
                        end
                    case 'BetweenBlock'



                        betweenPc=get_param(pcSrcHandle(srcIdx),'PortConnectivity');
                        betweenSrcBlock=[betweenPc.SrcBlock];

                        betweenInPh=get(pcSrcHandle(srcIdx),'PortHandles');
                        betweenInLine=get([betweenInPh.Outport],'Line');
                        portHandle=get(betweenInLine,'DstPortHandle');

                        if strcmp(get(portHandle,'PortType'),'trigger')
                            asyncTaskSpecBlkBetween=pcSrcHandle(srcIdx);
                        else
                            betweenInHandles=[betweenInHandles,pcSrcHandle(srcIdx)];%#ok <AGROW>
                            betweenPos=get(pcSrcHandle(srcIdx),'Position');
                            betweenMaxWidth=max(betweenMaxWidth,betweenPos(3)-betweenPos(1));
                        end


                        for betweenSrcIdx=1:length(betweenSrcBlock)
                            betweenSrcBlockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(get_param(betweenSrcBlock(betweenSrcIdx),'BlockType'));
                            switch betweenSrcBlockCategory
                            case 'CentralBlock'

                            case 'BetweenBlock'



                            case 'LeafBlock'
                                if~isempty(asyncTaskSpecBlkBetween)&&isempty(fcnCallInportBlkLeaf)
                                    fcnCallInportBlkLeaf=betweenSrcBlock(betweenSrcIdx);
                                else
                                    leafInHandles=[leafInHandles,betweenSrcBlock(betweenSrcIdx)];%#ok <AGROW>
                                end
                            otherwise
                                assert(false,'Unexpected src block category: "%s"',betweenSrcBlockCategory);
                            end
                        end
                    case 'CentralBlock'

                    otherwise
                        assert(false,'Unexpected block category "%s" connected to central block input.',blockCategory);
                    end
                end

                if~(isempty(leafInHandles)&&isempty(betweenInHandles))
                    autosar.mm.mm2sl.MRLayoutManager.homeBlockLayers(betweenInHandles,leafInHandles,'west');
                    homedBlks=[homedBlks,betweenInHandles{:},leafInHandles{:}];%#ok<AGROW>
                end


                if~isempty(fcnCallInportBlkLeaf)
                    if~isempty(asyncTaskSpecBlkBetween)
                        idealL1Gap=autosar.mm.mm2sl.layout.LayoutHelper.getIdealGapForBlocksToHome({asyncTaskSpecBlkBetween});
                        idealL2Gap=autosar.mm.mm2sl.layout.LayoutHelper.getIdealGapForBlocksToHome({fcnCallInportBlkLeaf});

                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(asyncTaskSpecBlkBetween,'Gap',idealL1Gap,'BlockOrientation','north');
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(fcnCallInportBlkLeaf,'Gap',idealL2Gap,'BlockOrientation','west');
                        homedBlks=[homedBlks,asyncTaskSpecBlkBetween,fcnCallInportBlkLeaf];%#ok<AGROW>
                    else
                        idealGap=autosar.mm.mm2sl.layout.LayoutHelper.getIdealGapForBlocksToHome({fcnCallInportBlkLeaf});
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(fcnCallInportBlkLeaf,'Gap',idealGap,'BlockOrientation','north');
                        homedBlks=[homedBlks,fcnCallInportBlkLeaf];%#ok<AGROW>
                    end
                end
            end
        end




        function makeBlocksSameWidth(model,blockType)
            blocks=find_system(model,'SearchDepth',1,'BlockType',blockType);
            if isempty(blocks)
                return;
            end

            blockPositions=get_param(blocks,'Position');
            blockWidths=cellfun(@(x)x(3)-x(1),blockPositions);
            maxBlockWidth=max(blockWidths);
            for blockIdx=1:length(blocks)
                pos=blockPositions{blockIdx};
                newPosition=[pos(1),pos(2),pos(1)+maxBlockWidth,pos(4)];
                set_param(blocks{blockIdx},'Position',newPosition);
            end
        end




        function orderFcnCallInPortsFirst(model)


            allInports=find_system(model,'SearchDepth',1,'BlockType','Inport');
            fcnCallInports=allInports(strcmp(get_param(allInports,'OutputFunctionCall'),'on'));
            otherInports=allInports(strcmp(get_param(allInports,'OutputFunctionCall'),'off'));
            if isempty(fcnCallInports)||isempty(otherInports)
                return;
            end





            otherPortNames=get_param(otherInports,'PortName');
            [~,uniquePortidx]=unique(otherPortNames,'stable');
            otherInports=otherInports(uniquePortidx);


            fcnCallPortNums=str2double(get_param(fcnCallInports,'Port'));
            otherPortNums=str2double(get_param(otherInports,'Port'));

            maxPortNum=max([fcnCallPortNums;otherPortNums]);

            if max(fcnCallPortNums)<min(otherPortNums)

                return;
            end


            [~,sortIndex]=sort(otherPortNums);
            sortIndex=flip(sortIndex);
            portIdx=maxPortNum;
            for i=1:length(otherPortNums)
                set_param(otherInports{sortIndex(i)},'Port',num2str(portIdx));
                portIdx=portIdx-1;
            end

            [~,sortIndex]=sort(fcnCallPortNums);
            sortIndex=flip(sortIndex);
            for i=1:length(fcnCallPortNums)
                set_param(fcnCallInports{sortIndex(i)},'Port',num2str(portIdx));
                portIdx=portIdx-1;
            end
        end







        function[addedBlocks,addedBlocksInfo]=tidySignalLines(modelName,useGoToFrom,CompNameToLayerLevelMap)
            assert(any(strcmp(useGoToFrom,{'Auto','Always','Never'})),...
            'invalid useGoToFrom value: %s',useGoToFrom);

            allLines=find_system(modelName,'SearchDepth',1,...
            'FindAll','on','type','line','SegmentType','trunk');

            linesToUseGotoFrom=[];
            for lineIdx=1:length(allLines)
                lineH=allLines(lineIdx);


                srcBlockH=get(lineH,'SrcBlockHandle');
                dstBlockH=get(lineH,'DstBlockHandle');
                srcBlockType=get_param(srcBlockH,'BlockType');
                dstBlockType=get_param(dstBlockH,'BlockType');

                if~iscell(srcBlockType)
                    srcBlockType={srcBlockType};
                end
                if~iscell(dstBlockType)
                    dstBlockType={dstBlockType};
                end

                if any(strcmp(dstBlockType,'Merge'))
                    linesToUseGotoFrom=[linesToUseGotoFrom,lineH];%#ok<AGROW>
                else

                    srcBlockCategory={};
                    dstBlockCategory={};

                    if any(isKey(autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap,srcBlockType))
                        for ii=1:length(srcBlockType)
                            srcBlockCategory{ii}=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(srcBlockType{ii});%#ok <AGROW>
                        end
                    end

                    if any(isKey(autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap,dstBlockType))
                        for ii=1:length(dstBlockType)
                            dstBlockCategory{ii}=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(dstBlockType{ii});%#ok <AGROW>
                        end
                    end


                    isCentralToCentral=any(strcmp(srcBlockCategory,'CentralBlock').*strcmp(dstBlockCategory,'CentralBlock'));
                    isCentralToBetween=any(strcmp(srcBlockCategory,'CentralBlock').*strcmp(dstBlockCategory,'BetweenBlock'));

                    if isCentralToCentral
                        switch(useGoToFrom)
                        case 'Auto'




                            numDestinations=length(get_param(lineH,'DstPortHandle'));
                            if(numDestinations>1)

                                linesToUseGotoFrom=[linesToUseGotoFrom,lineH];%#ok<AGROW>
                            else

                                if~isempty(CompNameToLayerLevelMap)
                                    srcLayerLvl=CompNameToLayerLevelMap(autosar.mm.mm2sl.layout.LayeredLayoutStrategy.getLayoutNodeName(getfullname(srcBlockH)));
                                    dstLayerLvl=CompNameToLayerLevelMap(autosar.mm.mm2sl.layout.LayeredLayoutStrategy.getLayoutNodeName(getfullname(dstBlockH)));
                                    if(dstLayerLvl-srcLayerLvl)~=1

                                        linesToUseGotoFrom=[linesToUseGotoFrom,lineH];%#ok<AGROW>
                                    end
                                end
                            end
                        case 'Always'

                            linesToUseGotoFrom=[linesToUseGotoFrom,lineH];%#ok<AGROW>
                        case 'Never'

                        otherwise
                            assert(false,'invalid useGoToFrom value: %s',useGoToFrom);
                        end
                    elseif isCentralToBetween







                        dstDstBlock=[];
                        for i=1:length(dstBlockH)
                            dstPC=get_param(dstBlockH(i),'PortConnectivity');
                            dstDstBlock=[dstDstBlock,dstPC.DstBlock];%#ok<AGROW>
                        end
                        useGoTo=false;
                        for ii=1:length(dstDstBlock)


                            dstDstBlockType=get_param(dstDstBlock(ii),'BlockType');
                            dstDstBlockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(dstDstBlockType);
                            if strcmp(dstDstBlockCategory,'CentralBlock')


                                if~isempty(CompNameToLayerLevelMap)
                                    srcLayerLvl=CompNameToLayerLevelMap(autosar.mm.mm2sl.layout.LayeredLayoutStrategy.getLayoutNodeName(getfullname(srcBlockH)));
                                    dstLayerLvl=CompNameToLayerLevelMap(autosar.mm.mm2sl.layout.LayeredLayoutStrategy.getLayoutNodeName(getfullname(dstDstBlock(ii))));
                                    if(dstLayerLvl-srcLayerLvl)~=1

                                        useGoTo=true;
                                    end
                                end
                            end
                        end



                        if useGoTo
                            linesToUseGotoFrom=[linesToUseGotoFrom,lineH];%#ok<AGROW>
                        end
                    else

                        if~strcmp(srcBlockCategory,'CentralBlock')
                            srcPC=get_param(srcBlockH,'PortConnectivity');
                            srcDstBlock=[srcPC.DstBlock];
                            if length(srcDstBlock)>1
                                linesToUseGotoFrom=[linesToUseGotoFrom,lineH];%#ok<AGROW>
                            end
                        end
                    end
                end
            end


            addedBlocks={};
            addedBlocksInfo={};
            for lineIdx=1:length(linesToUseGotoFrom)
                lineH=linesToUseGotoFrom(lineIdx);
                gotoFromNamePrefix=autosar.mm.mm2sl.layout.LayoutHelper.getGoToFromNamePrefixForLine(lineH);
                [newAddedBlocks,newAddedBlocksInfo]=autosar.mm.mm2sl.MRLayoutManager.addGotoFrom(lineH,gotoFromNamePrefix);
                addedBlocks=[addedBlocks,newAddedBlocks];%#ok<AGROW>
                addedBlocksInfo=[addedBlocksInfo,newAddedBlocksInfo];%#ok<AGROW>
            end
        end



        function autoRouteLines(lineHandles)
            SLM3I.SLDomain.routeLines(lineHandles);
        end



        function autoRouteLinesWithEdges(model)
            allLines=find_system(model,'SearchDepth',1,'FindAll','on',...
            'type','line','SegmentType','trunk');
            LinesWithEdges=[];
            for lineIdx=1:length(allLines)
                lineH=allLines(lineIdx);
                hasEdges=size(get(lineH,'Points'),1)>2;
                if hasEdges
                    LinesWithEdges=[LinesWithEdges,lineH];%#ok<AGROW>
                end
            end
            if~isempty(LinesWithEdges)
                autosar.mm.mm2sl.layout.LayoutHelper.autoRouteLines(LinesWithEdges);
            end
        end

        function deleteUnconnectedLines(modelName)
            unconnectedLines=find_system(modelName,'SearchDepth',1,...
            'FindAll','on','type','line','Connected','off');
            for lineIdx=1:length(unconnectedLines)
                lineH=unconnectedLines(lineIdx);


                try %#ok<TRYNC>
                    delete_line(lineH);
                end
            end
        end




        function canvasViewScrollTopLeft(modelName)
            allBlocks=find_system(modelName,'SearchDepth',1);
            allBlocks=setdiff(allBlocks,modelName);
            if~isempty(allBlocks)
                positions=get_param(allBlocks,'Position');
                positions=reshape([positions{:}],4,length(positions));


                allYPos=positions(2,1:end);
                topYPos=min(allYPos);
                [~,Ycols]=find(allYPos==topYPos);
                topBlocksPos=positions(1:end,Ycols);
                topBlocks=allBlocks(Ycols);


                allXPos=topBlocksPos(1,1:end);
                mostleftXPos=min(allXPos);
                [~,Xcols]=find(allXPos==mostleftXPos);
                topMostLeftBlock=topBlocks(Xcols(1));


                Simulink.scrollToVisible(topMostLeftBlock{1},'ensureFit','off');
            end
        end



        function idealGap=getIdealGapForBlocksToHome(blocksToHome)
            idealGap=40;
            for idx=1:length(blocksToHome)

                if strcmp(get_param(blocksToHome{idx},'ShowName'),'on')
                    gap=max(40,2.5*length(get_param(blocksToHome{idx},'Name')));
                    if gap>idealGap
                        idealGap=gap;
                    end
                end
            end
        end



        function line=addLine(sys,outport,inport)
            line=add_line(sys,outport,inport,'autorouting',...
            autosar.mm.mm2sl.layout.LayoutHelper.LineRoutingMode);
        end




        function setBlockPosition(block,position)
            canvasLimit=autosar.mm.mm2sl.layout.LayoutHelper.CanvasLimit;
            if position(1)<-canvasLimit
                offset=-position(1)-canvasLimit;
                position(1)=position(1)+offset;
                position(3)=position(3)+offset;
            elseif position(3)>canvasLimit
                offset=position(3)-canvasLimit;
                position(1)=position(1)-offset;
                position(3)=position(3)-offset;
            end

            if position(2)<-canvasLimit
                offset=-position(2)-canvasLimit;
                position(2)=position(2)+offset;
                position(4)=position(4)+offset;
            elseif position(4)>canvasLimit
                offset=position(4)-canvasLimit;
                position(2)=position(2)-offset;
                position(4)=position(4)-offset;
            end

            set_param(block,'Position',position);
        end
    end

    methods(Static,Access=private)


        function gotoFromNamePrefix=getGoToFromNamePrefixForLine(lineH)

            gotoFromNamePrefix='';


            signalName=get_param(lineH,'Name');
            if~isempty(signalName)

                gotoFromNamePrefix=signalName;
                return;
            end




            srcBlockH=get_param(lineH,'SrcBlockHandle');
            srcPortH=get_param(lineH,'SrcPortHandle');
            srcBlockType=get_param(srcBlockH,'BlockType');
            srcBlockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(srcBlockType);
            switch(srcBlockCategory)
            case 'CentralBlock'


                if strcmp(srcBlockType,'ModelReference')
                    refModel=get_param(srcBlockH,'ModelName');
                    if~bdIsLoaded(refModel)
                        load_system(refModel);
                    end

                    outportBlock=find_system(refModel,'SearchDepth',1,...
                    'BlockType','Outport',...
                    'Port',num2str(get_param(srcPortH,'PortNumber')));
                    gotoFromNamePrefix=get_param(outportBlock{1},'PortName');
                else



                    dstBlockH=get_param(lineH,'dstBlockHandle');
                    assert(length(dstBlockH)==1,'Only expected one destination block');
                    dstBlockType=get_param(dstBlockH,'BlockType');
                    assert(strcmp('BetweenBlock',...
                    autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(dstBlockType)),...
                    'expected destination block to be a between block');
                    gotoFromNamePrefix=get_param(dstBlockH,'Name');
                end
            case{'LeafBlock','BetweenBlock'}

                gotoFromNamePrefix=get_param(srcBlockH,'Name');
            otherwise
                assert(false,'Unexpected block category: %s',srcBlockCategory);
            end
            assert(~isempty(gotoFromNamePrefix),'No valid GoTo/From prefix found');
        end




        function[isConnected,connectedToBlock]=hasBlockSingleConnectionTo(block,connectedToBlockType)
            isConnected=false;
            connectedToBlock='';

            lh=get_param(block,'LineHandles');
            switch(connectedToBlockType)
            case 'Inport'
                portH=lh.Inport;
                SrcOrDst='Src';
            case 'Outport'
                portH=lh.Outport;
                SrcOrDst='Dst';
            otherwise
                assert(false,'Unsupported block type: %s',connectedToBlockType);
            end

            if ishandle(portH)
                connectedToBlockH=get(portH,[SrcOrDst,'BlockHandle']);
                if ishandle(connectedToBlockH)&&...
                    strcmp(get_param(connectedToBlockH,'BlockType'),connectedToBlockType)
                    isConnected=true;
                    connectedToBlock=getfullname(connectedToBlockH);
                end
            end
        end



        function blockTypeToBlockCategoryMap=getBlockTypeToBlockCategoryMap()
            centralBlockValues=repmat({'CentralBlock'},size(autosar.mm.mm2sl.layout.LayoutHelper.CentralCategoryBlockTypes));
            leafBlockValues=repmat({'LeafBlock'},size(autosar.mm.mm2sl.layout.LayoutHelper.LeafCategoryBlockTypes));
            betweenBlockValues=repmat({'BetweenBlock'},size(autosar.mm.mm2sl.layout.LayoutHelper.BetweenCategoryBlockTypes));
            floatingBlockValues=repmat({'FloatingBlock'},size(autosar.mm.mm2sl.layout.LayoutHelper.FloatingCategoryBlockTypes));

            blockTypes=[...
            autosar.mm.mm2sl.layout.LayoutHelper.CentralCategoryBlockTypes,...
            autosar.mm.mm2sl.layout.LayoutHelper.LeafCategoryBlockTypes,...
            autosar.mm.mm2sl.layout.LayoutHelper.BetweenCategoryBlockTypes,...
            autosar.mm.mm2sl.layout.LayoutHelper.FloatingCategoryBlockTypes];

            blockCategories=[...
            centralBlockValues,...
            leafBlockValues,...
            betweenBlockValues,...
            floatingBlockValues];

            blockTypeToBlockCategoryMap=containers.Map(blockTypes,blockCategories);
        end
    end
end


