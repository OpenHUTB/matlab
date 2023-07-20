classdef MatrixLayoutStrategy<autosar.mm.mm2sl.layout.LayoutStrategy





    properties(Constant,Access=private)
        DefaultBlockPosition=[300,150,640,260];
        HorizontalGapBetweenBlocks=100;
        VerticalGapBetweenBlocks=100;
    end

    properties(Access=private)
        DestinationSys;
    end

    methods
        function this=MatrixLayoutStrategy(destSys)

            this.DestinationSys=destSys;
        end

        function setBlockPosition(this,blockPath)


            this.addBlocks(blockPath);
        end

        function refresh(this)
            addedBlocks=this.AddedBlocks;
            numBlocksInSys=length(this.AddedBlocks);
            if~isempty(addedBlocks)






                numberOfRows=round(sqrt(numBlocksInSys));
                lastCol=1;
                lastX=autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinX;
                lastY=autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinY;
                for ii=1:numBlocksInSys
                    block=addedBlocks(ii);
                    this.positionBlockInMatrix(block,ii,lastX,lastY,lastCol,numberOfRows);
                    currPos=get_param(block,'Position');
                    lastX=currPos(1);
                    lastY=currPos(4);


                    lastCol=ceil(ii/numberOfRows);
                end
            end
        end
    end

    methods(Access=private)
        function positionBlockInMatrix(this,blockPath,currBlkNum,lastX,...
            lastY,lastCol,numberOfRows)
            import autosar.mm.mm2sl.layout.LayoutHelper;
            assert(strcmp(get_param(blockPath,'Parent'),this.DestinationSys));
            set_param(blockPath,'Position',this.DefaultBlockPosition);
            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(blockPath);
            if currBlkNum>1


                currCol=ceil(currBlkNum/numberOfRows);
                currBlkPos=get_param(blockPath,'Position');
                h=currBlkPos(4)-currBlkPos(2);
                w=currBlkPos(3)-currBlkPos(1);
                if currCol==lastCol
                    x=lastX;
                    y=lastY+this.VerticalGapBetweenBlocks;
                else


                    existingBlocks=find_system(this.DestinationSys,'SearchDepth',1,'BlockType','SubSystem');
                    existingBlocks=setdiff(existingBlocks,this.DestinationSys);


                    assert(~isempty(existingBlocks));
                    positions=get_param(existingBlocks,'Position');

                    if iscell(positions)
                        positions=reshape([positions{:}],4,length(positions));
                        x=max(positions(3,1:end))+this.HorizontalGapBetweenBlocks;
                        y=min(positions(2,1:end));
                    else
                        x=positions(3)+this.HorizontalGapBetweenBlocks;
                        y=min(positions(2));
                    end
                end
                newPosition=[x,y,x+w,y+h];
                LayoutHelper.setBlockPosition(blockPath,newPosition);
            end
        end
    end
end


