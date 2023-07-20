classdef LayeredLayoutStrategy<autosar.mm.mm2sl.layout.LayoutStrategy






    properties(Constant,Access=private)
        HorizontalGapBetweenBlocks=300;
        VerticalGapBetweenBlocks=120;

        FloatingBlockMargin=-100;
    end

    properties(Access=private)

        DefaultBlockPositionXY=[];

        AddedDashboardBlocks;

        UseGotoFromBlocks;
        CompNameToLayerLevelMap;

        MaxLayerWidth=0;
    end

    methods
        function this=LayeredLayoutStrategy(modelName,...
            useGotoFromBlocks,isUpdateMode,CentralBlockType,layers)

            this.ModelName=modelName;
            this.UseGotoFromBlocks=useGotoFromBlocks;
            this.IsUpdateMode=isUpdateMode;
            this.CentralBlockType=CentralBlockType;


            this.CompNameToLayerLevelMap=containers.Map;
            for layerIdx=1:length(layers)
                layer=layers{layerIdx};
                for compIdx=1:length(layer)
                    if this.IsUpdateMode
                        this.CompNameToLayerLevelMap(layer{compIdx})=1;
                    else
                        this.CompNameToLayerLevelMap(layer{compIdx})=layerIdx;
                    end
                end
            end


            this.DefaultBlockPositionXY=this.calculateDefaultBlockPosition();
        end




        function setBlockPosition(this,blockPath)
            import autosar.mm.mm2sl.layout.LayoutHelper;


            isDashboardBlock=this.isDashboardBlock(blockPath);
            if isDashboardBlock
                this.positionDashboardBlock(blockPath);
                return;
            end


            currentPos=get_param(blockPath,'Position');
            w=currentPos(3)-currentPos(1);
            h=currentPos(4)-currentPos(2);


            if~isempty(this.AddedCentralBlocks)
                lastPositionedCentralBlock=this.AddedCentralBlocks(end);
                [lastLayerBlockName,~]=this.getLayoutNodeName(lastPositionedCentralBlock);



                [layerBlockName,~]=this.getLayoutNodeName(blockPath);
                blockLayerId=this.CompNameToLayerLevelMap(layerBlockName);
                lastBlockLayerId=this.CompNameToLayerLevelMap(lastLayerBlockName);
                isBlockInSameLayer=isequal(blockLayerId,lastBlockLayerId);

                lastBlockPosition=get_param(lastPositionedCentralBlock,'Position');
                if isBlockInSameLayer

                    x=lastBlockPosition(1);
                    lastBlockH=lastBlockPosition(4)-lastBlockPosition(2);
                    y=lastBlockPosition(2)+lastBlockH+this.VerticalGapBetweenBlocks;
                else

                    x=this.calculateNewLayerXPosition(lastBlockLayerId,'right');
                    y=this.DefaultBlockPositionXY(2);
                    this.MaxLayerWidth=0;
                end


                newPosition=[x,y,x+w,y+h];
            else


                newPosition=[this.DefaultBlockPositionXY,this.DefaultBlockPositionXY+[w,h]];
            end

            LayoutHelper.setBlockPosition(blockPath,newPosition);
            this.AddedCentralBlocks(end+1)=get_param(blockPath,'Handle');
            this.MaxLayerWidth=max(this.MaxLayerWidth,w);
        end




        function positionDashboardBlock(this,blockPath)
            import autosar.mm.mm2sl.layout.LayoutHelper;


            currentPos=get_param(blockPath,'Position');
            w=currentPos(3)-currentPos(1);
            h=currentPos(4)-currentPos(2);


            newBlkPos=...
            [this.DefaultBlockPositionXY(1:2)+[0,-this.VerticalGapBetweenBlocks-h],...
            this.DefaultBlockPositionXY(1:2)+[w,-this.VerticalGapBetweenBlocks]];
            LayoutHelper.setBlockPosition(blockPath,newBlkPos);

            this.AddedDashboardBlocks(end+1)=get_param(blockPath,'Handle');
        end

        function refresh(this)

            addedBlocksInfo={};
            if~this.IsUpdateMode

                autosar.mm.mm2sl.layout.LayoutHelper.orderFcnCallInPortsFirst(this.ModelName);


                [addedBlocks,addedBlocksInfo]=autosar.mm.mm2sl.layout.LayoutHelper.tidySignalLines(...
                this.ModelName,this.UseGotoFromBlocks,this.CompNameToLayerLevelMap);
                this.addBlocks(addedBlocks);
            end


            homedBlks=autosar.mm.mm2sl.layout.LayoutHelper.homeSrcAndDstBlocks([this.AddedCentralBlocks,this.AddedDashboardBlocks]);



            addedBlks=this.AddedBlocks;
            notHomedBlks=setdiff(getfullname(addedBlks),getfullname([homedBlks{:}]));
            if this.IsUpdateMode
                for idx=1:length(notHomedBlks)
                    notHomedBlk=notHomedBlks{idx};
                    blockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(...
                    get_param(notHomedBlk,'BlockType'));
                    if strcmp(blockCategory,'LeafBlock')
                        isHomed=autosar.mm.mm2sl.MRLayoutManager.homeBlk(notHomedBlk);
                        if isHomed
                            notHomedBlks{idx}=[];
                        end
                    end
                end

                if~isempty(notHomedBlks)
                    notHomedBlks=notHomedBlks(~cellfun(@isempty,notHomedBlks));
                end
            end


            this.positionFloatingBlocks(notHomedBlks,addedBlocksInfo);

            serverRunSubsystems=this.ServerRunSSBlocks;
            this.positionServerRunSubsystems(serverRunSubsystems,notHomedBlks);


            if~this.IsUpdateMode
                autosar.mm.mm2sl.layout.LayoutHelper.autoRouteLinesWithEdges(this.ModelName);

                autosar.mm.mm2sl.layout.LayoutHelper.canvasViewScrollTopLeft(this.ModelName);
            end
        end
    end

    methods(Access=private)



        function defaultBlockPositionXY=calculateDefaultBlockPosition(this)
            defaultBlockPositionXY=[...
            autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinX,...
            autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinY];

            if this.IsUpdateMode
                existingBlocks=find_system(this.ModelName,'SearchDepth',1);
                existingBlocks=setdiff(existingBlocks,this.ModelName);

                if~isempty(existingBlocks)
                    positions=get_param(existingBlocks,'Position');
                    if iscell(positions)
                        positions=reshape([positions{:}],4,length(positions));
                        mostRightXPos=max(positions(3,1:end));
                        topYPos=min(positions(2,1:end));
                        defaultBlockPositionXY=[mostRightXPos+this.HorizontalGapBetweenBlocks,topYPos];
                    else
                        defaultBlockPositionXY=[positions(3)+this.HorizontalGapBetweenBlocks,positions(2)];
                    end
                end
            end
        end


        function positionServerRunSubsystems(this,serverRunSubsystems,otherBlocks)
            existingBlocks=find_system(this.ModelName,'SearchDepth',1,'BlockType','SubSystem');
            existingBlocks=setdiff(existingBlocks,[this.ModelName,serverRunSubsystems,otherBlocks]);
            if~isempty(existingBlocks)
                positions=get_param(existingBlocks,'Position');
                if iscell(positions)
                    positions=reshape([positions{:}],4,length(positions));


                    mostLeftXPos=min(positions(1,1:end));
                    mostRightXPos=max(positions(3,1:end));
                    x=mostLeftXPos;
                    bottomYPos=max(positions(4,1:end));
                    y=bottomYPos+this.VerticalGapBetweenBlocks;

                    for blkIdx=1:length(serverRunSubsystems)
                        blk=serverRunSubsystems{blkIdx};
                        currentPos=get_param(blk,'Position');
                        w=currentPos(3)-currentPos(1);
                        h=currentPos(4)-currentPos(2);

                        if(y+h>bottomYPos)
                            bottomYPos=y+h;
                        end
                        if(x+w>mostRightXPos)
                            x=mostLeftXPos;
                            y=bottomYPos+this.VerticalGapBetweenBlocks;
                        end
                        newPos=[x,y,x+w,y+h];
                        blk=serverRunSubsystems{blkIdx};
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                        x=x+this.HorizontalGapBetweenBlocks;
                    end
                end
            end
        end





        function centralBlockName=getCentralBlockName(this,name)
            centralBlockName=name;

            if strcmp(this.CentralBlockType,'ModelReference')

                return;
            end




            block=find_system(this.ModelName,'SearchDepth',1,'Name',name,'BlockType',this.CentralBlockType);
            if isempty(block)
                centralBlockName=strcat(name,'_sys');
                assert(length(find_system(this.ModelName,'SearchDepth',1,'Name',centralBlockName))==1,...
                'Could not find block %s/%s',this.ModelName,centralBlockName);
            else
                blockType=get_param(block,'BlockType');
                if strcmp(blockType,'Inport')&&strcmp(get_param(block,'OutputFunctionCall'),'on')


                    centralBlockName=strcat(name,'_sys');
                end
            end
        end





        function positionFloatingBlocks(this,addedBlocks,addedBlocksInfo)

            if isempty(addedBlocks)
                return;
            end

            dataStoreSpacing=30;


            dbBlkHeight=0;
            for ii=1:length(this.AddedDashboardBlocks)
                dbBlk=this.AddedDashboardBlocks(ii);
                dbBlkPos=get_param(dbBlk,'Position');
                dbBlkHeight=max(dbBlkHeight,(dbBlkPos(4)-dbBlkPos(2)));
            end
            firstDSBlockPosition=this.DefaultBlockPositionXY...
            +[0,-dbBlkHeight-(2*this.VerticalGapBetweenBlocks)];

            datastores={};
            for blkIdx=1:length(addedBlocks)
                blk=addedBlocks{blkIdx};
                blkType=get_param(blk,'BlockType');


                if strcmp(blkType,'DataStoreMemory')
                    currentPos=get_param(blk,'Position');
                    w=currentPos(3)-currentPos(1);
                    h=currentPos(4)-currentPos(2);
                    autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,...
                    [(firstDSBlockPosition+[0,-h]),(firstDSBlockPosition+[w,0])]);
                    firstDSBlockPosition=firstDSBlockPosition+[w+dataStoreSpacing,0];
                    datastores=[datastores,blk];%#ok<AGROW>
                end
            end
            addedBlocks=setdiff(addedBlocks,datastores);








            leftChains={};
            rightChains={};


            maxLeftLength=0;
            maxRightLength=0;

            for ii=1:length(addedBlocksInfo)
                blockChain=addedBlocksInfo{ii};








                firstBlockLayer=blockChain{1};
                if iscell(firstBlockLayer)
                    firstBlk=firstBlockLayer{1};
                else
                    firstBlk=firstBlockLayer;
                end
                switch get_param(firstBlk,'BlockType')
                case 'Goto'
                    maxLeftLength=max(maxLeftLength,length(blockChain));
                    leftChains=[leftChains;{blockChain(:)}];%#ok<AGROW>
                case 'From'
                    maxRightLength=max(maxRightLength,length(blockChain));
                    rightChains=[rightChains;{blockChain(:)}];%#ok<AGROW>
                otherwise
                    maxRightLength=max(maxRightLength,length(blockChain));
                    rightChains=[rightChains;{blockChain(:)}];%#ok<AGROW>
                end
            end

            leftLayers=cell(length(leftChains),maxLeftLength);
            rightLayers=cell(length(rightChains),maxRightLength);


            for ii=1:length(leftChains)
                leftChain=leftChains{ii};
                chainLen=length(leftChain);
                if chainLen<maxLeftLength
                    leftChain{maxLeftLength}=leftChain{chainLen};
                    leftChain{chainLen}=[];
                end
                leftLayers(ii,1:maxLeftLength)=leftChain;
            end
            for ii=1:length(rightChains)
                rightChain=rightChains{ii};
                chainLen=length(rightChain);
                if chainLen<maxRightLength
                    rightChain{maxRightLength}=rightChain{chainLen};
                    rightChain{chainLen}=[];
                end
                rightLayers(ii,1:maxRightLength)=rightChain;
            end



            floatingChainBlks=[rightLayers(:);leftLayers(:)];
            if any(cellfun(@(x)iscell(x),floatingChainBlks))
                floatingChainBlks=[floatingChainBlks{:}];
            end
            floatingChainBlks=floatingChainBlks(cellfun(@(x)~isempty(x),floatingChainBlks));
            addedBlocks=setdiff(addedBlocks,floatingChainBlks);

            goToFromSpacing=50;


            if~isempty(leftLayers)
                defaultFirstBlockPosition=[this.calculateNewLayerXPosition(1,'left')-this.FloatingBlockMargin,this.DefaultBlockPositionXY(2)];
                this.positionChains('left',goToFromSpacing,defaultFirstBlockPosition,leftLayers);
            end


            if~isempty(rightLayers)
                layers=this.CompNameToLayerLevelMap.values;
                finalLayer=max([layers{:}]);
                defaultFirstBlockPosition=[this.calculateNewLayerXPosition(finalLayer,'right')+this.FloatingBlockMargin,this.DefaultBlockPositionXY(2)];
                rhsChainPos=this.positionChains('right',goToFromSpacing,defaultFirstBlockPosition,rightLayers);
            end

            otherBlockSeparation=100;
            otherBlockSpacing=55;


            if~isempty(addedBlocks)

                if~isempty(rightLayers)
                    firstBlkPos=rhsChainPos+[0,otherBlockSeparation];
                else

                    firstBlkPos=[this.DefaultBlockPositionXY(1)+this.HorizontalGapBetweenBlocks+this.FloatingBlockMargin,this.DefaultBlockPositionXY(2)];
                end

                for ii=1:length(addedBlocks)
                    blk=addedBlocks{ii};
                    blkPos=get_param(blk,'Position');
                    w=blkPos(3)-blkPos(1);
                    h=blkPos(4)-blkPos(2);

                    newPos=[firstBlkPos(1:2),firstBlkPos(1:2)+[w,h]];
                    autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    firstBlkPos=firstBlkPos+[0,h+otherBlockSpacing];
                end
            end

        end



        function newLayerXPosition=calculateNewLayerXPosition(this,layerID,side)


            layerSpacingCoeff=6;


            switch side
            case 'left'
                blockType='Inport';
            case 'right'
                blockType='Outport';
            otherwise
                assert(false,'Invalid side specification')
            end


            centralBlks=this.CompNameToLayerLevelMap.keys;
            idxs=cellfun(@(x)x==layerID,this.CompNameToLayerLevelMap.values);
            lastLayerCentralBlocks=centralBlks(idxs);
            lastLayerCentralBlocks=cellfun(@(x)this.getCentralBlockName(x),lastLayerCentralBlocks,'UniformOutput',false);

            layerMargin=[];
            for centralBlkIdx=1:length(lastLayerCentralBlocks)
                blkPath=[this.ModelName,'/',lastLayerCentralBlocks{centralBlkIdx}];
                blkPos=get_param(blkPath,'Position');



                if strcmp(get_param(blkPath,'BlockType'),'ModelReference')
                    refModel=get_param(blkPath,'ModelName');
                    if~bdIsLoaded(refModel)
                        load_system(refModel);
                    end
                    Ports=find_system(refModel,'SearchDepth',1,'BlockType',blockType);
                else
                    Ports=find_system(blkPath,'SearchDepth',1,'BlockType',blockType);
                end
                PortNames=get_param(Ports,'Name');
                if~isempty(PortNames)
                    longestPortName=max(cellfun(@(x)length(x),PortNames));
                else
                    longestPortName=0;
                end
                portSpacing=max(40,3*longestPortName);
                layerSpacing=portSpacing*layerSpacingCoeff;


                switch side
                case 'left'
                    if isempty(layerMargin)
                        layerMargin=blkPos(1)-layerSpacing;
                    else
                        layerMargin=min(layerMargin,blkPos(1)-layerSpacing);
                    end
                case 'right'
                    if isempty(layerMargin)
                        layerMargin=blkPos(3)+layerSpacing;
                    else
                        layerMargin=max(layerMargin,blkPos(3)+layerSpacing);
                    end
                end
            end

            assert(~isempty(layerMargin),'layerMargin should not be empty');
            newLayerXPosition=layerMargin;
        end
    end

    methods(Static,Access=private)



        function isDashboardBlock=isDashboardBlock(blockPath)
            isDashboardBlock=false;
            blkType=get_param(blockPath,'BlockType');

            if strcmp(blkType,'SubSystem')
                eventListener=find_system(blockPath,'SearchDepth',1,'BlockType','EventListener','EventType','Initialize');
                isDashboardBlock=~isempty(eventListener);
            end
        end
    end

    methods(Static,Access=public)



        function[name,path]=getLayoutNodeName(blockPath)



            name=get_param(blockPath,'Name');
            path=blockPath;

            blockType=get_param(blockPath,'BlockType');
            if strcmp(blockType,'ModelReference')
                return;
            end
            assert(strcmp(blockType,'SubSystem'),'Expected BlockType ''Subsystem'', received BlockType %s.',blockType);

            triggerPort=find_system(blockPath,'SearchDepth',1,'BlockType','TriggerPort');
            if isempty(triggerPort)
                eventListener=find_system(blockPath,'SearchDepth',1,'BlockType','EventListener');
                isIRTBlock=~isempty(eventListener);
                if isIRTBlock
                    eventType=get_param(eventListener,'EventType');
                    assert(ismember(eventType,{'Initialize','Reset','Terminate'}));
                    return;
                else
                    name=name(1:end-4);
                    path=path(1:end-4);
                    return;
                end
            else


                name=name(1:end-4);
                path=path(1:end-4);
                return;
            end

        end






        function newStartingPositionXY=positionChains(side,verticalGapBetweenChains,startingPositionXY,layers)
            assert(any(strcmp(side,{'left','right'})),'Invalid side specification');


            firstBlockPosition=startingPositionXY;

            for layerIdx=1:size(layers,2)
                layerBlks=layers(:,layerIdx);

                if layerIdx>1

                    idealGap=autosar.mm.mm2sl.layout.LayoutHelper.getIdealGapForBlocksToHome(layerBlks);
                    firstBlockPosition(2)=startingPositionXY(2);
                    switch side
                    case 'left'
                        firstBlockPosition=firstBlockPosition-[maxWidth+idealGap,0];
                    case 'right'
                        firstBlockPosition=firstBlockPosition+[maxWidth+idealGap,0];
                    end
                end

                maxWidth=0;
                for blkIdx=1:length(layerBlks)

                    blks=layerBlks{blkIdx};


                    if~isempty(blks)

                        if~iscell(blks)
                            blks={blks};
                        end

                        numBlks=length(blks);
                        for ii=1:numBlks
                            blk=blks{ii};

                            currentPos=get_param(blk,'Position');
                            w=currentPos(3)-currentPos(1);
                            maxWidth=max(maxWidth,w);
                            h=currentPos(4)-currentPos(2);








                            spacingRatio=1/(2*numBlks);
                            placementIndex=((2*ii)-1);
                            yPos=-(verticalGapBetweenChains/2)+((placementIndex*spacingRatio)*verticalGapBetweenChains);


                            switch side
                            case 'left'
                                newPos=[(firstBlockPosition+[-w,yPos-h/2]),(firstBlockPosition+[0,yPos+h/2])];
                            case 'right'
                                newPos=[(firstBlockPosition+[0,yPos-h/2]),(firstBlockPosition+[w,yPos+h/2])];
                            end
                            autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                        end
                    end


                    firstBlockPosition=firstBlockPosition+[0,verticalGapBetweenChains];
                end
            end


            lowestBlkPos=get_param(layers{end,1},'Position');
            switch side
            case 'left'
                newStartingPositionXY=[lowestBlkPos(3),lowestBlkPos(2)];
            case 'right'
                newStartingPositionXY=[lowestBlkPos(1),lowestBlkPos(2)];
            end
        end

    end
end






