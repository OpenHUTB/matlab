function out=placementhandler(action,varargin)











    out={action};

    switch(action)
    case 'adjustSizesAndShiftDownAndToRight'
        adjustSizesAndShiftDownAndToRight(varargin{:});
    case 'getBlocksWithinCompartmentBounds'
        out=getBlocksWithinCompartmentBounds(varargin{:});
    case 'getBlocksWithinModelBounds'
        out=getBlocksWithinModelBounds(varargin{:});
    case 'positionSingleBlock'
        positionSingleBlock(varargin{:});
    case 'positionSingleExpressionBlock'
        positionSingleExpressionBlock(varargin{:});
    case 'positionSingleReactionBlock'
        positionSingleReactionBlock(varargin{:});
    case 'positionMultipleParameterBlocks'
        positionMultipleParameterBlocks(varargin{:});
    case 'getBlockAbsolutePosition'
        out=getBlockAbsolutePosition(varargin{:});
    case 'addBlocksToOccupancyMap'
        addBlocksToOccupancyMap(varargin{:});
    end

end

function positionSingleBlock(operations,model,block,allBlocks,component,checkForOverlap,varargin)
    if isempty(allBlocks)
        allBlocks=model.getAllEntitiesInMap;
    end

    type=component.Type;
    if strcmp(type,'species')
        positionSingleSpeciesBlock(operations,model,block,component);
    elseif strcmp(type,'compartment')
        positionSingleCompartmentBlock(operations,model,block,component);
    elseif strcmp(type,'reaction')
        positionSingleReactionBlock(operations,model,block,component,checkForOverlap,varargin{:});
        reparentBlocks(operations,model,allBlocks,block);
    elseif strcmp(type,'parameter')
        positionSingleParameterBlock(operations,model,block,checkForOverlap);
        reparentBlocks(operations,model,allBlocks,block);
    else
        positionSingleExpressionBlock(operations,model,block,checkForOverlap);
        reparentBlocks(operations,model,allBlocks,block);
    end


end

function positionSingleSpeciesBlock(operations,model,block,component)


    compartment=component.Parent;
    compartmentBlock=model.getEntitiesInMap(compartment.SessionID);

    [position,existingBlocks]=findBlockPositionWithinCompartment(model,block,compartmentBlock);

    if~isempty(position)
        operations.setPosition(block,position.x,position.y);
    else
        positionSingleSpeciesBlockManually(operations,model,block,compartmentBlock,existingBlocks);
    end

end

function positionSingleCompartmentBlock(operations,model,block,component)

    parent=component.Owner;


    if isempty(parent)
        [position,~]=findBlockPositionWithinTopLevelDiagram(model,block,false);

    else
        compartmentBlock=model.getEntitiesInMap(parent.SessionID);
        [position,~]=findBlockPositionWithinCompartment(model,block,compartmentBlock);
    end

    if~isempty(position)
        operations.setPosition(block,position.x,position.y);
    else
        positionSingleCompartmentBlockManually(operations,model,block,component)
    end

end

function[position,diagramRect]=findBlockPositionWithinTopLevelDiagram(model,block,allowOverlapWithCompartments)

    diagramRect=getDiagramRectangle(model,block);
    canvasRect=[diagramRect.left,diagramRect.right,diagramRect.top,diagramRect.bottom];
    canvasCoordinates=canvasRect;




    if allowOverlapWithCompartments
        existingBlocks=getAllNonCompartmentBlocks(model,block);
    else
        existingBlocks=getBlocksWithinModelBounds(model,block);
    end

    position=findBlockPositionUsingOccupancyMap(canvasCoordinates,model,existingBlocks,block,0);

end

function[position,existingBlocks]=findBlockPositionWithinCompartment(model,block,compartmentBlock)



    compartmentSize=compartmentBlock.getSize;
    canvasRect=[0,compartmentSize.width,0,compartmentSize.height];

    canvasMargins=[10,-10,10,-10];
    canvasCoordinates=canvasRect+canvasMargins;


    existingBlocks=getBlocksWithinCompartmentBounds(compartmentBlock,block);


    marginForLabel=10;
    position=findBlockPositionUsingOccupancyMap(canvasCoordinates,model,existingBlocks,block,marginForLabel);

end

function placeBlockWithinTopLevelDiagram(operations,model,block,allowOverlapWithCompartments)
    [position,diagramRect]=findBlockPositionWithinTopLevelDiagram(model,block,allowOverlapWithCompartments);

    if~isempty(position)
        operations.setPosition(block,position.x,position.y);
    else


        gap=25;
        margin=25;
        placeBlockInExtendedTopLevelDiagram(operations,block,diagramRect,gap,margin);
    end

end

function placeBlockInExtendedTopLevelDiagram(operations,block,diagramRect,gap,margin)
    position=getPositionOutsideOfRectBounds(diagramRect,gap,margin);
    operations.setPosition(block,position.x,position.y);


end

function position=findBlockPositionUsingOccupancyMap(canvasCoordinates,model,existingBlocks,block,marginForLabel)






    occupancyMap=SimBiology.web.diagram.OccupancyMap(canvasCoordinates);


    addBlocksToOccupancyMap(occupancyMap,model,existingBlocks,true,false);


    blockSize=block.getSize;
    [success,newRect]=occupancyMap.findRectangle(blockSize.width,blockSize.height+marginForLabel,false);
    if success
        position.x=newRect(SimBiology.web.diagram.OccupancyMap.LEFT);
        position.y=newRect(SimBiology.web.diagram.OccupancyMap.TOP);
    else
        position=[];
    end

end

function addBlocksToOccupancyMap(occupancyMap,model,existingBlocks,useBufferMargins,useAbsolutePosition)
    if useBufferMargins
        speciesMargins=[-40,40,-25,55];
        compartmentMargins=[-50,50,-25,50];
        defaultMargins=[-25,25,-25,25];
    else
        speciesMargins=[5,5,5,10];
        compartmentMargins=[5,5,5,10];
        defaultMargins=[5,5,5,5];
    end

    for i=1:numel(existingBlocks)
        childBlock=existingBlocks(i);
        if useAbsolutePosition
            childPosition=getBlockAbsolutePosition(model,childBlock);
        else
            childPosition=childBlock.getPosition;
        end
        childSize=childBlock.getSize;
        childRect=[childPosition.x,childPosition.x+childSize.width,...
        childPosition.y,childPosition.y+childSize.height];

        if strcmp(childBlock.type,'species')

            margins=speciesMargins;
        elseif strcmp(childBlock.type,'compartment')
            margins=compartmentMargins;
        else
            margins=defaultMargins;
        end
        occupancyMap.add(round(childRect+margins),true);
    end

end

function positionSingleSpeciesBlockManually(operations,model,block,compartmentBlock,existingBlocks)

    blockSize=block.getSize;
    compSize=compartmentBlock.getSize;
    rect=struct;

    borderMargin=10;
    if(compSize.width<=compSize.height)
        blockMargin=40;
        xBound=getMaxInDim(existingBlocks,true);
        rect.x=xBound+blockMargin;
        rect.y=borderMargin;
    else
        blockMargin=55;
        yBound=getMaxInDim(existingBlocks,false);
        rect.x=borderMargin;
        rect.y=yBound+blockMargin;
    end

    rect.right=rect.x+blockSize.width;
    rect.bottom=rect.y+blockSize.height;
    operations.setPosition(block,rect.x,rect.y);
    adjustSizesAndShiftDownAndToRight(operations,model,compartmentBlock,rect,block.getAttribute('sessionID').value);

end

function maxValue=getMaxInDim(blocks,useX)
    if isempty(blocks)
        maxValue=0;
    else
        positions=arrayfun(@(b)b.getPosition,blocks);
        sizes=arrayfun(@(b)b.getSize,blocks);
        if useX
            coordinates=arrayfun(@(p,s)p.x+s.width,positions,sizes);
        else
            coordinates=arrayfun(@(p,s)p.y+s.height,positions,sizes);
        end
        maxValue=max(coordinates);
    end


end

function positionSingleCompartmentBlockManually(operations,model,block,component)


    parent=component.Owner;



    if isempty(parent)


        gap=50;
        margin=100;
        position=getPositionOutsideOfCurrentDiagramBounds(model,block,gap,margin);
        operations.setPosition(block,position.x,position.y);
    else

        immediateParent=model.getEntitiesInMap(parent.SessionID);





        blockPosition=getPositionToRightOrBelowOfAllSiblingBlocks(immediateParent,block);
        operations.setPosition(block,blockPosition.x,blockPosition.y);
        blockSize=block.getSize;



        blockRect.x=blockPosition.x;
        blockRect.y=blockPosition.y;
        blockRect.left=blockRect.x;
        blockRect.top=blockRect.y;
        blockRect.bottom=blockRect.y+blockSize.height;
        blockRect.right=blockRect.x+blockSize.width;


        addedBlockSessionIDs=block.getAttribute('sessionID').value;
        adjustSizesAndShiftDownAndToRight(operations,model,immediateParent,blockRect,addedBlockSessionIDs);
    end

end

function position=getPositionOutsideOfCurrentDiagramBounds(model,blocksToExclude,gap,margin)
    diagramRect=getDiagramRectangle(model,blocksToExclude);
    position=getPositionOutsideOfRectBounds(diagramRect,gap,margin);

end

function blockPosition=getPositionToRightOrBelowOfAllSiblingBlocks(parentBlock,blockToPlace)




    margin=20;
    siblingBlocks=parentBlock.subdiagram.entities;
    blockPosition.x=0;
    blockPosition.y=0;
    for i=1:length(siblingBlocks)
        if siblingBlocks(i)~=blockToPlace
            siblingSize=siblingBlocks(i).getSize();
            siblingPosition=siblingBlocks(i).getPosition();
            blockPosition.x=max(blockPosition.x,siblingPosition.x+siblingSize.width);
            blockPosition.y=max(blockPosition.y,siblingPosition.y+siblingSize.height);
        end
    end
    blockPosition.x=blockPosition.x+margin;
    blockPosition.y=blockPosition.y+margin;
    blockToPlaceSize=blockToPlace.getSize();
    parentBlockSize=parentBlock.getSize();
    if 2*(blockPosition.x+blockToPlaceSize.width)-parentBlockSize.width<=...
        2*(blockPosition.y+blockToPlaceSize.height)-parentBlockSize.height

        blockPosition.y=margin;
    else

        blockPosition.x=margin;
    end
end

function position=getPositionOutsideOfRectBounds(diagramRect,gap,margin)
    position=struct('x',[],'y',[]);


    if diagramRect.width==0||diagramRect.height==0
        gap=margin;
    else
        margin=0;
    end
    if shouldExtendHorizontally(diagramRect)
        position.x=diagramRect.right+gap;
        position.y=diagramRect.top+margin;
    else
        position.x=diagramRect.left+margin;
        position.y=diagramRect.bottom+gap;
    end

end

function flag=shouldExtendHorizontally(rect)
    flag=(rect.width<=rect.height);

end

function positionSingleReactionBlock(operations,model,block,reaction,checkForOverlap,speciesBlocks)


    reactants=reaction.Reactants.get({'SessionID'});
    products=reaction.Products.get({'SessionID'});

    reactants=[reactants{:}];
    products=[products{:}];

    reactantBlock=[];
    if~isempty(reactants)
        reactant=reactants(1);
        product=setdiff(products,reactant);
        reactantBlock=model.getEntitiesInMap(reactant);
    else
        product=products;
    end

    productBlock=[];
    if~isempty(product)
        productBlock=model.getEntitiesInMap(product(1));
    end

    if~isempty(reactantBlock)&&~isempty(speciesBlocks)
        sessionIds=getAttributeValue(speciesBlocks,'sessionID');
        sessionIds=[sessionIds{:}];
        reactantBlock=speciesBlocks(sessionIds==reactant);
    end

    if~isempty(reactantBlock)
        reactantBlock=reactantBlock(1);
    end

    if~isempty(productBlock)&&~isempty(speciesBlocks)
        sessionIds=getAttributeValue(speciesBlocks,'sessionID');
        sessionIds=[sessionIds{:}];
        productBlock=speciesBlocks(sessionIds==product);
    end

    if~isempty(productBlock)
        productBlock=productBlock(1);
    end


    targetPoint=struct('x',[],'y',[]);
    reactionSize=block.getSize;
    if~isempty(reactantBlock)&&~isempty(productBlock)

        pos=getBlockAbsolutePosition(model,reactantBlock);
        size=reactantBlock.getSize;
        cx1=pos.x+size.width/2;
        cy1=pos.y+size.height/2;

        pos=getBlockAbsolutePosition(model,productBlock);
        size=productBlock.getSize;
        cx2=pos.x+size.width/2;
        cy2=pos.y+size.height/2;
        targetPoint.x=(cx1+cx2)/2-reactionSize.width/2;
        targetPoint.y=(cy1+cy2)/2-reactionSize.height/2;
    elseif isempty(reactantBlock)&&~isempty(productBlock)


        pos=getBlockAbsolutePosition(model,productBlock);
        targetPoint.x=pos.x-60;
        targetPoint.y=pos.y;
    elseif~isempty(reactantBlock)&&isempty(productBlock)


        pos=getBlockAbsolutePosition(model,reactantBlock);
        targetPoint.x=pos.x+60;
        targetPoint.y=pos.y;
    else
        targetPoint=[];

        placeBlockWithinTopLevelDiagram(operations,model,block,false);
    end


    if~isempty(targetPoint)
        positionAtTargetPoint(operations,model,block,targetPoint,checkForOverlap)
    end

end

function positionAtTargetPoint(operations,model,block,targetPoint,checkForOverlap)
    if checkForOverlap
        positionNearTargetPoint(operations,model,block,targetPoint);
    else
        operations.setPosition(block,targetPoint.x,targetPoint.y);
    end

end

function positionNearTargetPoint(operations,model,block,targetPoint)

    diagramRect=getDiagramRectangle(model,block);
    canvasRect=[diagramRect.left,diagramRect.right,diagramRect.top,diagramRect.bottom];
    canvasCoordinates=canvasRect;
    occupancyMap=SimBiology.web.diagram.OccupancyMap(canvasCoordinates);
    existingBlocks=getAllNonCompartmentBlocks(model,block);
    blockSize=block.getSize;
    addBlocksToOccupancyMap(occupancyMap,model,existingBlocks,false,true);

    targetRect=[targetPoint.x,targetPoint.x+blockSize.width,targetPoint.y,targetPoint.y+blockSize.height];
    [success,addedRect]=addNearTargetPoint(occupancyMap,targetRect);
    if success
        operations.setPosition(block,addedRect(SimBiology.web.diagram.OccupancyMap.LEFT),addedRect(SimBiology.web.diagram.OccupancyMap.TOP));
    else
        placeBlockWithinTopLevelDiagram(operations,model,block,false);
    end

end

function positionMultipleParameterBlocks(operations,model,blocks)

    margin=100;
    verticalGap=35;
    horizontalGap=100;
    defaultNumPerColumn=10;
    blockSize=blocks(1).getSize();
    blockHeight=blockSize.height+verticalGap;
    blockWidth=blockSize.width+horizontalGap;

    diagramRect=getDiagramRectangle(model,blocks);
    if diagramRect.height>(margin+defaultNumPerColumn*blockHeight)
        defaultNumPerColumn=floor(diagramRect.height/blockHeight);
    end

    x=diagramRect.right+margin;
    y=diagramRect.top+margin;
    for i=1:numel(blocks)

        xIndex=floor((i-1)/defaultNumPerColumn);
        yIndex=mod(i-1,defaultNumPerColumn);
        operations.setPosition(blocks(i),x+xIndex*blockWidth,y+yIndex*blockHeight);
    end

end

function positionSingleParameterBlock(operations,model,block,checkForOverlap)



    if~isempty(block.connections)
        connections=block.connections(1);


        associatedBlockUUID=connections.getAttribute('sourceBlockUUID').value;
        associatedBlockSessionID=connections.getAttribute('sourceSessionID').value;
        positionSingleParameterOrExpressionBlock(operations,model,block,associatedBlockUUID,associatedBlockSessionID,60,0,checkForOverlap);
    else

        placeBlockWithinTopLevelDiagram(operations,model,block,false);
    end

end

function positionSingleExpressionBlock(operations,model,block,checkForOverlap)



    if~isempty(block.connections)
        connections=block.connections(1);


        associatedBlockUUID=connections.getAttribute('destinationBlockUUID').value;
        associatedBlockSessionID=connections.getAttribute('destinationSessionID').value;
        positionSingleParameterOrExpressionBlock(operations,model,block,associatedBlockUUID,associatedBlockSessionID,-60,0,checkForOverlap);
    else

        placeBlockWithinTopLevelDiagram(operations,model,block,false);
    end

end

function positionSingleParameterOrExpressionBlock(operations,model,block,associatedBlockUUID,associatedBlockSessionID,xPosDelta,yPosDelta,checkForOverlap)

    associatedBlocks=model.getEntitiesInMap(associatedBlockSessionID);
    associatedBlock=associatedBlocks(ismember({associatedBlocks.uuid},associatedBlockUUID));


    if~isempty(associatedBlock)


        if ismember(associatedBlock.type,{'species','compartment'})
            pos=getBlockAbsolutePosition(model,associatedBlock);
        else
            pos=associatedBlock.getPosition;
        end
        blockSize=associatedBlock.getSize;



        if xPosDelta>0
            xPosDelta=xPosDelta+blockSize.width;
        elseif xPosDelta==0
            xPosDelta=blockSize.width/2;
        end

        if yPosDelta>0
            yPosDelta=yPosDelta+blockSize.height;
        elseif yPosDelta==0
            yPosDelta=blockSize.height/2-10;
        end

        targetPoint=struct('x',floor(pos.x+xPosDelta),'y',floor(pos.y+yPosDelta));
        positionAtTargetPoint(operations,model,block,targetPoint,checkForOverlap);
    else

        placeBlockWithinTopLevelDiagram(operations,model,block,false);
    end





end



function adjustSizesAndShiftDownAndToRight(operations,model,targetBlock,blockRect,addedBlockSessionIDs)









    margin=20;






    childOffsetX=0;
    childOffsetY=0;
    tfRequireShift=false;
    childrenBlocks={};



    rectToClear=blockRect;
    rectToClear.left=rectToClear.x;
    rectToClear.top=rectToClear.y;
    rectToClear.right=rectToClear.right+margin;
    rectToClear.bottom=rectToClear.bottom+margin;



    childrenBounds.x=0;
    childrenBounds.y=0;
    childrenBounds.bottom=0;
    childrenBounds.right=0;







    overlappingBlocksDict=dictionary(addedBlockSessionIDs(:),...
    num2cell(ones(numel(addedBlockSessionIDs),1)));

    if~isempty(targetBlock)

        targetChildren=targetBlock.subdiagram.entities;
    else

        syntax=model.getDiagramSyntax();
        targetChildren=syntax.root.entities;
    end

    for j=1:length(targetChildren)











        for i=1:length(targetChildren)
            targetChildSessionID=targetChildren(i).getAttribute('sessionID').value;
            targetChildCloneIdx=targetChildren(i).getAttribute('cloneIndex').value;
            tfKnownSessionID=overlappingBlocksDict.isKey(targetChildSessionID);
            if tfKnownSessionID
                cloneIndices=overlappingBlocksDict(targetChildSessionID);
                if ismember(targetChildCloneIdx,cloneIndices{1})


                    continue;
                end
            end

            childSize=targetChildren(i).getSize();
            childPosition=targetChildren(i).getPosition();
            childRect.top=childPosition.y;
            childRect.left=childPosition.x;
            childRect.right=childRect.left+childSize.width;
            childRect.bottom=childRect.top+childSize.height;
            childRect.width=childSize.width;
            childRect.height=childSize.height;
            if rectIntersects(childRect,rectToClear)





                if targetChildren(i).type~="annotation"
                    childrenBlocks{end+1}=childRect;%#ok<AGROW>
                end
                visitedClones=[];
                if tfKnownSessionID
                    visitedClones=overlappingBlocksDict(targetChildSessionID);
                    visitedClones=visitedClones{1};
                end
                overlappingBlocksDict(targetChildSessionID)=...
                {[visitedClones,targetChildCloneIdx]};
            end
        end

        tfRequireShift=~isempty(childrenBlocks);
        if tfRequireShift


            childrenBounds=getBoundingRect(childrenBlocks);


            updatedChildOffsetX=blockRect.right-childrenBounds.x;
            updatedChildOffsetY=blockRect.bottom-childrenBounds.y;
            if updatedChildOffsetX==childOffsetX&&...
                updatedChildOffsetY==childOffsetY



                break;
            end




            rectToClear.left=min(rectToClear.left,childrenBounds.x);
            rectToClear.top=min(rectToClear.top,childrenBounds.y);
            rectToClear.right=rectToClear.right+childrenBounds.width-childOffsetX+updatedChildOffsetX;
            rectToClear.bottom=rectToClear.bottom+childrenBounds.height-childOffsetY+updatedChildOffsetY;
            childOffsetX=updatedChildOffsetX;
            childOffsetY=updatedChildOffsetY;
        else

            break
        end

    end



    newRightEdge=blockRect.right;
    newBottomEdge=blockRect.bottom;


    if tfRequireShift



        tfShiftSpeciesDown=childrenBounds.y-blockRect.y+...
        blockRect.x-childrenBounds.x>=0;
        if tfShiftSpeciesDown
            childOffsetY=childOffsetY+margin;



            newBottomEdge=childOffsetY+childrenBounds.bottom;
        else
            childOffsetX=childOffsetX+margin;



            newRightEdge=childOffsetX+childrenBounds.right;
        end
    end

    if~isempty(targetBlock)


        targetSize=targetBlock.getSize();
        targetRightEdge=targetSize.width;
        targetBottomEdge=targetSize.height;

        tfExpandTargetRight=newRightEdge+margin>targetRightEdge;
        tfExpandTargetDown=newBottomEdge+margin>targetBottomEdge;

        if tfExpandTargetRight||tfExpandTargetDown
            if tfExpandTargetRight
                targetRightEdge=newRightEdge+margin;
                operations.setAttributeValue(targetBlock,'width',targetRightEdge);
            end
            if tfExpandTargetDown
                targetBottomEdge=newBottomEdge+margin;
                operations.setAttributeValue(targetBlock,'height',targetBottomEdge);
            end


            operations.setSize(targetBlock,targetRightEdge,targetBottomEdge);
        end
    end

    if tfRequireShift



        overlappingBlocksDict(addedBlockSessionIDs)=[];
        overlappingBlockSessionIDs=overlappingBlocksDict.keys()';
        for sessionID=overlappingBlockSessionIDs
            block=model.getEntitiesInMap(sessionID);
            cloneIdx=block.getAttribute('cloneIndex').value;
            cloneIndicesToShift=overlappingBlocksDict(sessionID);
            if ismember(cloneIdx,cloneIndicesToShift{1})

                pos=block.getPosition;
                blockLeft=pos.x;
                blockTop=pos.y;
                if tfShiftSpeciesDown
                    blockTop=pos.y+childOffsetY;
                else
                    blockLeft=pos.x+childOffsetX;
                end
                operations.setPosition(block,blockLeft,blockTop);
            end
        end
    end

    if isempty(targetBlock)


        return;
    end



    targetPosition=targetBlock.getPosition();
    blockRect.x=targetPosition.x;
    blockRect.left=targetPosition.x;
    blockRect.y=targetPosition.y;
    blockRect.top=targetPosition.y;
    blockRect.right=blockRect.left+targetRightEdge;
    blockRect.bottom=blockRect.top+targetBottomEdge;
    syntax=model.getDiagramSyntax();
    targetBlockParent=targetBlock.getParent();
    if targetBlockParent==syntax.root
        targetBlockParent=[];
    else
        targetBlockParent=targetBlockParent.getParent();
    end
    addedBlockSessionIDs=targetBlock.getAttribute('sessionID').value;
    adjustSizesAndShiftDownAndToRight(operations,model,targetBlockParent,blockRect,addedBlockSessionIDs);

end


function rect=getBoundingRect(childrenBounds)

    top=inf;
    left=inf;
    bottom=-inf;
    right=-inf;

    for i=1:length(childrenBounds)
        next=childrenBounds{i};
        top=min(top,next.top);
        left=min(left,next.left);
        right=max(right,next.left+next.width);
        bottom=max(bottom,next.top+next.height);
    end

    if isempty(childrenBounds)
        top=0;
        left=0;
    end

    width=right-left;
    height=bottom-top;
    rect.x=left;
    rect.y=top;
    rect.width=width;
    rect.height=height;
    rect.right=right;
    rect.bottom=bottom;

end

function blocks=getBlocksWithinCompartmentBounds(compBlock,blocksToExclude)

    if nargin==1
        blocksToExclude=[];
    end

    blocks=getBlocksWithinDiagramOrSubdiagram(compBlock.subdiagram,blocksToExclude);

end

function blocks=getBlocksWithinModelBounds(model,blocksToExclude)

    if nargin==1
        blocksToExclude=[];
    end

    if~isempty(model)&&model.hasDiagramSyntax
        blocks=getBlocksWithinDiagramOrSubdiagram(model.getDiagramSyntax.root,blocksToExclude);
    else
        blocks=[];
    end

end

function blocks=getBlocksWithinDiagramOrSubdiagram(parentDiagram,blocksToExclude)


    blocks=parentDiagram.entities;


    blocks=blocks([blocks.isValid]);


    for i=1:numel(blocksToExclude)
        idx=arrayfun(@(b)b==blocksToExclude(i),blocks);
        blocks=blocks(~idx);
    end

end

function blocks=getAllNonCompartmentBlocks(model,blocksToExclude)


    blocks=[];


    allBlocks=model.getAllEntitiesInMap;



    for i=1:numel(allBlocks)
        nextBlock=allBlocks(i);
        if~strcmpi(nextBlock.type,'compartment')
            blocks=[blocks;nextBlock];%#ok<AGROW>
        end
    end


    for i=1:numel(blocksToExclude)
        idx=arrayfun(@(b)b==blocksToExclude(i),blocks);
        blocks=blocks(~idx);
    end

end


function out=getBlockAbsolutePosition(model,block)

    out=SimBiology.web.diagram.layouthandler('getBlockAbsolutePosition',model,block);

end

function out=getAttributeValue(blocks,property)

    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);

end

function rect=getDiagramRectangle(model,blocksToExclude)

    rect=SimBiology.web.diagram.layouthandler('getDiagramRectangle',model,blocksToExclude);

end

function out=rectIntersects(rect1,rect2)

    out=~(rect1.right<rect2.left||rect2.right<rect1.left||rect1.bottom<rect2.top||rect2.bottom<rect1.top);

end

function reparentBlocks(operations,model,allBlocks,blocksToReparent)

    SimBiology.web.diagram.layouthandler('reparentBlocks',operations,model,allBlocks,blocksToReparent);

end