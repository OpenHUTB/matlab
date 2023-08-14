classdef MRLayoutManager





    methods(Static,Access=public)






        function homeBlockLayers(layer1Blks,layer2Blks,blockOrientation)

            idealL1Gap=autosar.mm.mm2sl.layout.LayoutHelper.getIdealGapForBlocksToHome(layer1Blks);
            idealL2Gap=autosar.mm.mm2sl.layout.LayoutHelper.getIdealGapForBlocksToHome(layer2Blks);

            if~isempty(layer1Blks)

                blkPC=get_param(layer1Blks{1},'PortConnectivity');
                switch blockOrientation
                case 'east'
                    centBlk=[blkPC.SrcBlock];


                    centBlkType=get_param(centBlk,'BlockType');
                    if iscell(centBlkType)
                        centBlkIdx=cellfun(@(x)strcmp(autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(x),'CentralBlock'),centBlkType,'UniformOutput',1);
                        centBlks=centBlk(centBlkIdx);
                    else
                        centBlks=centBlk;
                    end
                    assert(~isempty(centBlks),'Expected Central Block');
                    centBlkPos=get_param(centBlks(1),'Position');


                    maxL1Width=0;
                    for idx=1:length(layer1Blks)
                        blk=layer1Blks{idx};

                        [w,h,y]=autosar.mm.mm2sl.MRLayoutManager.getSizeAndYOffset(blk,'output');

                        maxL1Width=max(maxL1Width,w);


                        newPos=[...
                        centBlkPos(3)+idealL2Gap,...
                        y-(h/2),...
                        centBlkPos(3)+idealL2Gap+w,...
                        y+(h/2)];
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    end


                    for idx=1:length(layer2Blks)
                        blk=layer2Blks{idx};

                        [w,h,y]=autosar.mm.mm2sl.MRLayoutManager.getSizeAndYOffset(blk,'output');


                        newPos=[...
                        centBlkPos(3)+idealL2Gap+idealL1Gap+maxL1Width,...
                        y-(h/2),...
                        centBlkPos(3)+idealL2Gap+idealL1Gap+maxL1Width+w,...
                        y+(h/2)];
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    end

                case 'west'
                    centBlk=[blkPC.DstBlock];


                    centBlkType=get_param(centBlk,'BlockType');
                    if iscell(centBlkType)
                        centBlkIdx=cellfun(@(x)strcmp(autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(x),'CentralBlock'),centBlkType,'UniformOutput',1);
                        centBlks=centBlk(centBlkIdx);
                    else
                        centBlks=centBlk;
                    end
                    assert(~isempty(centBlks),'Expected Central Block');
                    centBlkPos=get_param(centBlks(1),'Position');


                    maxL1Width=0;
                    for idx=1:length(layer1Blks)
                        blk=layer1Blks{idx};

                        [w,h,y]=autosar.mm.mm2sl.MRLayoutManager.getSizeAndYOffset(blk,'input');

                        maxL1Width=max(maxL1Width,w);


                        newPos=[...
                        centBlkPos(1)-idealL1Gap-w,...
                        y-(h/2),...
                        centBlkPos(1)-idealL1Gap,...
                        y+(h/2)];
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    end


                    for idx=1:length(layer2Blks)
                        blk=layer2Blks{idx};

                        [w,h,y]=autosar.mm.mm2sl.MRLayoutManager.getSizeAndYOffset(blk,'input');


                        newPos=[...
                        centBlkPos(1)-idealL2Gap-idealL1Gap-maxL1Width-w,...
                        y-(h/2),...
                        centBlkPos(1)-idealL2Gap-idealL1Gap-maxL1Width,...
                        y+(h/2)];
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    end
                end
            else

                blkPC=get_param(layer2Blks{1},'PortConnectivity');
                switch blockOrientation
                case 'east'
                    centBlk=[blkPC.SrcBlock];


                    centBlkType=get_param(centBlk,'BlockType');
                    if iscell(centBlkType)
                        centBlkIdx=cellfun(@(x)strcmp(autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(x),'CentralBlock'),centBlkType,'UniformOutput',1);
                        centBlks=centBlk(centBlkIdx);
                    else
                        centBlks=centBlk;
                    end
                    assert(~isempty(centBlks),'Expected Central Block');
                    centBlkPos=get_param(centBlks(1),'Position');

                    for idx=1:length(layer2Blks)
                        blk=layer2Blks{idx};

                        [w,h,y]=autosar.mm.mm2sl.MRLayoutManager.getSizeAndYOffset(blk,'output');


                        newPos=[...
                        centBlkPos(3)+idealL2Gap,...
                        y-(h/2),...
                        centBlkPos(3)+idealL2Gap+w,...
                        y+(h/2)];
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    end
                case 'west'
                    centBlk=[blkPC.DstBlock];


                    centBlkType=get_param(centBlk,'BlockType');
                    if iscell(centBlkType)
                        centBlkIdx=cellfun(@(x)strcmp(autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(x),'CentralBlock'),centBlkType,'UniformOutput',1);
                        centBlks=centBlk(centBlkIdx);
                    else
                        centBlks=centBlk;
                    end
                    assert(~isempty(centBlks),'Expected Central Block');
                    centBlkPos=get_param(centBlks(1),'Position');

                    for idx=1:length(layer2Blks)
                        blk=layer2Blks{idx};

                        [w,h,y]=autosar.mm.mm2sl.MRLayoutManager.getSizeAndYOffset(blk,'input');


                        newPos=[...
                        centBlkPos(1)-idealL2Gap-w,...
                        y-(h/2),...
                        centBlkPos(1)-idealL2Gap,...
                        y+(h/2)];
                        autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(blk,newPos);
                    end
                end
            end
        end

        function isHomed=homeBlk(blk,varargin)







            isHomed=false;

            p=inputParser;
            p.addParameter('Gap',40,@isnumeric);
            p.addParameter('BlockOrientation','',@ischar);
            p.parse(varargin{:});

            gap=p.Results.Gap;
            blkOrientation=p.Results.BlockOrientation;


            blkPortHandles=get_param(blk,'PortHandles');
            if isempty(blkOrientation)


                if~isempty(blkPortHandles.Outport)
                    blkOrientation='west';
                    lineH=get_param(blkPortHandles.Outport,'Line');

                    if(lineH==-1)
                        return;
                    end


                    dstPortH=get(lineH,'DstPortHandle');
                    if strcmp(get_param(dstPortH,'PortType'),'trigger')
                        blkOrientation='north';
                    end
                elseif~isempty(blkPortHandles.Inport)
                    blkOrientation='east';
                    lineH=get_param(blkPortHandles.Inport,'Line');

                    if(lineH==-1)
                        return;
                    end
                else
                    assert(false,'Not sure how to move block %s',blk);
                end
            end


            switch blkOrientation
            case 'east'
                lineH=get_param(blkPortHandles.Inport,'Line');
                if length(lineH)>1
                    lineH=get_param(blkPortHandles.Outport,'Line');
                end
            case{'west','north'}
                lineH=get_param(blkPortHandles.Outport,'Line');
            otherwise
                assert(false,'Invalid blkLocation specification');
            end


            sys=get(lineH,'Parent');
            srcPortH=get(lineH,'SrcPortHandle');
            dstPortH=get(lineH,'DstPortHandle');

            dstHomingPortH=dstPortH(1);


            delete_line(lineH);

            blkPosition=get_param(blk,'Position');
            blkWidth=blkPosition(3)-blkPosition(1);
            blkHeight=blkPosition(4)-blkPosition(2);

            dstPos=get_param(dstHomingPortH,'Position');
            dstXPos=dstPos(1);
            dstYPos=dstPos(2);

            srcPos=get_param(srcPortH,'Position');
            srcXPos=srcPos(1);
            srcYPos=srcPos(2);

            switch blkOrientation
            case 'north'

                blkPosition=[dstXPos-gap-blkWidth,dstYPos-min(gap,40)-blkHeight,dstXPos-gap,dstYPos-min(gap,40)];
            case 'east'

                blkPosition=[srcXPos+gap,srcYPos-blkHeight/2,srcXPos+gap+blkWidth,srcYPos+blkHeight/2];
            case 'west'

                blkPosition=[dstXPos-gap-blkWidth,dstYPos-blkHeight/2,dstXPos-gap,dstYPos+blkHeight/2];
            otherwise
                assert(false,'Did not recognize blkLocation of %s',blkOrientation);
            end


            set_param(blk,'Position',blkPosition);


            if numel(dstPortH)>1
                for ii=1:numel(dstPortH)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH,dstPortH(ii));
                end
            elseif numel(srcPortH)>1
                for ii=1:numel(srcPortH)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH(ii),dstPortH);
                end
            else
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH,dstPortH);
            end

            isHomed=true;
        end

        function[numConnections,lineH]=numConnections(portBlk)

            portBlkPortHandles=get_param(portBlk,'PortHandles');
            blockType=get_param(portBlk,'BlockType');
            switch blockType
            case{'Inport','VariantSource','AsynchronousTaskSpecification','Ground'}
                lineH=get_param(portBlkPortHandles.Outport,'Line');
                if isempty(lineH)||lineH==-1
                    numConnections=0;
                else
                    numConnections=length(get(lineH,'DstPortHandle'));
                end
            case{'Outport','VariantSink'}
                lineH=get_param(portBlkPortHandles.Inport,'Line');
                if isempty(lineH)||lineH==-1
                    numConnections=0;
                else
                    numConnections=length(get(lineH,'SrcPortHandle'));
                end
            otherwise
                assert(false,'Did not recognize BlockType %s',blockType);
            end
        end

        function[addedBlocks,addedBlocksInfo]=addGotoFrom(lineH,gotoFromNamePrefix)


            addedBlocksInfo={};

            sys=get(lineH,'Parent');
            srcPortH=get(lineH,'SrcPortHandle');
            dstPortH=get(lineH,'DstPortHandle');


            delete_line(lineH);

            tagName=arxml.arxml_private('p_create_aridentifier',...
            [gotoFromNamePrefix,'_Tag'],namelengthmax);


            gotoBlkName=sprintf('%s_goto',gotoFromNamePrefix);
            [gotoBlkName,tagName]=autosar.mm.mm2sl.MRLayoutManager.getValidGoToFromNames(sys,gotoBlkName,tagName);

            gotoBlk=add_block('built-in/Goto',[sys,'/',gotoBlkName],...
            'GotoTag',tagName);
            addedBlocks={getfullname(gotoBlk)};


            gotoPortHandles=get_param(gotoBlk,'PortHandles');
            autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH,gotoPortHandles.Inport);


            floatingChain=autosar.mm.mm2sl.MRLayoutManager.getFloatingChain(gotoBlk);
            if~isempty(floatingChain)
                addedBlocksInfo=[addedBlocksInfo,{floatingChain}];
            end


            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(gotoBlk);


            for dstIdx=1:length(dstPortH)
                fromBlkName=sprintf('%s_from',gotoFromNamePrefix);
                [fromBlkName,~]=autosar.mm.mm2sl.MRLayoutManager.getValidGoToFromNames(sys,fromBlkName,tagName);
                fromBlk=add_block('built-in/From',[sys,'/',fromBlkName],...
                'GotoTag',tagName);
                addedBlocks=[addedBlocks,getfullname(fromBlk)];%#ok <AGROW>


                fromPortHandles=get_param(fromBlk,'PortHandles');
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,fromPortHandles.Outport,dstPortH(dstIdx));


                floatingChain=autosar.mm.mm2sl.MRLayoutManager.getFloatingChain(fromBlk);
                if~isempty(floatingChain)
                    addedBlocksInfo=[addedBlocksInfo,{floatingChain}];%#ok <AGROW>
                end


                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(fromBlk);
            end
        end



        function moveBlk(blk,x,y,w,h)


            pos=get_param(blk,'Position');

            if x==-1
                x=pos(1);
            end

            if y==-1
                y=pos(2);
            end

            if nargin<4||w==-1
                w=pos(3)-pos(1);
            end

            if nargin<5||h==-1
                h=pos(4)-pos(2);
            end

            pos=[x,y,x+w,y+h];
            set_param(blk,'Position',pos);

        end
    end

    methods(Static,Access=private)






        function[w,h,y]=getSizeAndYOffset(blk,direction)
            blkPos=get_param(blk,'Position');
            w=blkPos(3)-blkPos(1);
            h=blkPos(4)-blkPos(2);

            blkPortHandles=get_param(blk,'PortHandles');
            switch direction
            case 'input'
                lineH=get_param(blkPortHandles.Outport,'Line');
                dstPortH=get(lineH,'DstPortHandle');
                prtPos=get_param(dstPortH,'Position');
            case 'output'
                lineH=get_param(blkPortHandles.Inport(1),'Line');
                srcPortH=get(lineH,'SrcPortHandle');
                prtPos=get_param(srcPortH,'Position');
            end
            if iscell(prtPos),prtPos=prtPos{1};end
            y=prtPos(2);
        end





        function floatingChain=getFloatingChain(fromGotoBlk)
            import autosar.mm.mm2sl.layout.LayoutHelper

            floatingChain={};

            fromGotoBlkPC=get_param(fromGotoBlk,'PortConnectivity');
            fromGotoBlkType=get_param(fromGotoBlk,'BlockType');
            if strcmp(fromGotoBlkType,'From')
                connectedToFromGotoBlk=fromGotoBlkPC.DstBlock;
            else
                assert(strcmp(fromGotoBlkType,'Goto'),...
                'Unexpected block type "%s" for "%s"',...
                fromGotoBlkType,getfullname(fromGotoBlk));
                connectedToFromGotoBlk=fromGotoBlkPC.SrcBlock;
            end




            if length(connectedToFromGotoBlk)~=1
                return
            end








            betweenBlkDstBlkType=get_param(connectedToFromGotoBlk,'BlockType');
            connectedToFromGotoBlkCategory=LayoutHelper.BlockTypeToLayoutBlockCategoryMap(betweenBlkDstBlkType);
            switch(connectedToFromGotoBlkCategory)
            case 'LeafBlock'

                floatingChain={getfullname(fromGotoBlk),getfullname(connectedToFromGotoBlk)};
            case 'BetweenBlock'


                betweenBlk=connectedToFromGotoBlk;
                betweenBlkPC=get_param(betweenBlk,'PortConnectivity');
                blksConnectedToBetween=setdiff([betweenBlkPC.SrcBlock,betweenBlkPC.DstBlock],fromGotoBlk);

                if length(blksConnectedToBetween)==1



                    connectedToBetweenBlkType=get_param(blksConnectedToBetween,'BlockType');
                    if strcmp(LayoutHelper.BlockTypeToLayoutBlockCategoryMap(connectedToBetweenBlkType),'LeafBlock')
                        floatingChain={getfullname(fromGotoBlk)
                        getfullname(betweenBlk)
                        getfullname(blksConnectedToBetween)};
                    end
                else


                    betweenBlkSrcs=[betweenBlkPC.SrcBlock];
                    betweenBlkSrcsBlkType=get(betweenBlkSrcs,'BlockType');
                    if all(strcmp(betweenBlkSrcsBlkType,'From'))
                        betweenBlkDsts=[betweenBlkPC.DstBlock];
                        if length(betweenBlkDsts)==1
                            betweenBlkDst=betweenBlkDsts;
                            betweenBlkDstBlkType=get_param(betweenBlkDst,'BlockType');
                            switch(LayoutHelper.BlockTypeToLayoutBlockCategoryMap(betweenBlkDstBlkType))
                            case 'LeafBlock'

                                floatingChain={getfullname(betweenBlkSrcs)
                                getfullname(connectedToFromGotoBlk)
                                getfullname(betweenBlkDst)};
                            case 'BetweenBlock'

                                pc3=get_param(betweenBlkDst,'PortConnectivity');
                                betweenBlkDstDst=setdiff([pc3.SrcBlock,pc3.DstBlock],connectedToFromGotoBlk);
                                if length(betweenBlkDstDst)==1
                                    betweenBlkDstDstType=get_param(betweenBlkDstDst,'BlockType');
                                    if strcmp(LayoutHelper.BlockTypeToLayoutBlockCategoryMap(betweenBlkDstDstType),'LeafBlock')
                                        leafBlock=betweenBlkDstDst;
                                        floatingChain={getfullname(betweenBlkSrcs)
                                        getfullname(connectedToFromGotoBlk)
                                        getfullname(betweenBlkDst)
                                        getfullname(leafBlock)};
                                    end
                                end
                            otherwise

                            end
                        end
                    end
                end
            otherwise

            end
        end

        function[blockName,tagName]=getValidGoToFromNames(sys,blockName,tagName)
            if~isempty(find_system(sys,'SearchDepth',1,'Name',blockName))
                blockSuffix=1;
                while~isempty(find_system(sys,'SearchDepth',1,'Name',[blockName,num2str(blockSuffix)]))
                    blockSuffix=blockSuffix+1;
                end
                blockName=[blockName,num2str(blockSuffix)];
                tagName=[tagName,num2str(blockSuffix)];
                tagName=arxml.arxml_private('p_create_aridentifier',tagName,namelengthmax);
            end
        end

        function[xPos,width]=subsysXPos(sys)



            xPos=-1;
            width=-1;


            inports=find_system(sys,'SearchDepth',1,'BlockType','Inport');
            for ii=1:length(inports)
                if autosar.mm.mm2sl.MRLayoutManager.numConnections(inports{ii})>1
                    xPos=350;
                    break
                end
            end


            subsys=find_system(sys,'SearchDepth',1,'type','block',...
            'BlockType','SubSystem');
            for ii=1:length(subsys)
                pos=get_param(subsys{ii},'Position');
                w=pos(3)-pos(1);
                width=max(width,w);
            end

        end


        function xPos=outportXPos(sys,outports)




            if isempty(outports)
                xPos=-1;
                return
            end

            pos=get_param(outports{1},'Position');
            xPos=pos(1);

            maxGap=160;

            maxOutpName=0;
            for ii=1:numel(outports)
                maxOutpName=max(maxOutpName,numel(get_param(outports{ii},'Name')));
            end


            fontSize=6;
            gap=0.5*fontSize*maxOutpName;
            maxGap=max(maxGap,gap);

            maxSSX=0;
            blocks=find_system(sys,'SearchDepth',1,'type','block',...
            'BlockType','SubSystem');
            for ii=1:length(blocks)
                pos=get_param(blocks{ii},'Position');
                maxSSX=max(maxSSX,pos(3));
            end

            xPos=max(maxSSX+maxGap,xPos);

        end

        function hLine=halignBlk(blk,reconnectLine)


            if nargin<2
                reconnectLine=true;
            end


            blkPortHandles=get_param(blk,'PortHandles');
            if~isempty(blkPortHandles.Outport)

                lineH=get_param(blkPortHandles.Outport,'Line');
                srcPortH=get(lineH,'SrcPortHandle');
                dstPortH=get(lineH,'DstPortHandle');

                dstPos=get_param(dstPortH(1),'Position');
                centerYPos=dstPos(2);
            elseif~isempty(blkPortHandles.Inport)

                lineH=get_param(blkPortHandles.Inport,'Line');
                srcPortH=get(lineH,'SrcPortHandle');
                dstPortH=get(lineH,'DstPortHandle');

                srcPos=get_param(srcPortH(1),'Position');
                centerYPos=srcPos(2);
            else
                assert(false,'Not sure how to move block %s',blk);
            end

            blkPosition=get_param(blk,'Position');
            blkHeight=blkPosition(4)-blkPosition(2);

            blkPosition=[blkPosition(1),centerYPos-blkHeight/2,blkPosition(3),centerYPos+blkHeight/2];


            set_param(blk,'Position',blkPosition);


            if reconnectLine
                sys=get(lineH,'Parent');
                delete_line(lineH);
                hLine=autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH(1),dstPortH(1));
                for ii=2:length(srcPortH)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH(ii),dstPortH(1));
                end
                for ii=2:length(dstPortH)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(sys,srcPortH(1),dstPortH(ii));
                end
            end
        end


    end

end



