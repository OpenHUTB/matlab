function out=clipboardhandler(action,varargin)











    out=[];

    switch(action)
    case 'cut'
        cut(varargin{:});
    case 'copy'
        copy(varargin{:});
    case 'doesObjectAddNeedAutomaticPlacement'
        out=doesObjectAddNeedAutomaticPlacement(varargin{:});
    case 'getBlockInfoForObjects'
        out=getBlockInfoForObjects(varargin{:});
    case 'paste'
        out=paste(varargin{:});
    end

end

function cut(input)


    objArray=copy(input);


    args=struct;
    args.modelSessionID=input.modelSessionID;
    args.objArray=objArray;
    SimBiology.web.modelhandler('deleteAllObjects',args);

end

function objArray=copy(input)


    input.sessionIDs=unique(input.sessionIDs);


    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    blockInfo=getBlockInfoForDiagram(model,input);
    objArray=sbioselect(model,'SessionID',num2cell(input.sessionIDs));
    SimBiology.internal.Clipboard.copy(objArray,blockInfo);

end

function out=paste(input)

    out.error=false;
    out.message='';
    out.lastSessionID=input.lastSessionID;

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    target=sbioselect(model,'type',input.targetType,'SessionID',input.target);
    supportedTypes=input.acceptedTypes;
    transaction=SimBiology.Transaction.create(model);

    [blockInfo,status,objectsAdded]=SimBiology.internal.Clipboard.paste(target,supportedTypes);


    if isempty(status)
        out.error=true;
        out.message='Unable to paste.';
    elseif isa(status,'MException')
        out.error=true;
        out.message=SimBiology.web.internal.errortranslator(status);
    elseif~strcmp(status.Identifier,'SimBiology:Clipboard:Success')
        out.error=true;
        out.message=getString(status);
    else

        diagramEditor=model.getDiagramEditor;
        commandProcessor=diagramEditor.commandProcessor;
        inputArgs=struct;
        inputArgs.model=model;
        inputArgs.target=target;
        inputArgs.blockInfo=blockInfo;
        inputArgs.objectsAdded=objectsAdded;
        inputArgs.input=input;
        inputArgs.pasteBlocksFcn=@pasteBlocks;
        inputArgs.commandProcessor=commandProcessor;

        SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
        cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.PasteCommand','Custom Paste',inputArgs);
        commandProcessor.execute(cmd);






        transaction.commit;

        out.lastSessionID=getLastSessionID(model,blockInfo,input.lastSessionID);
        out.selection=[objectsAdded.SessionID];





        if isempty(supportedTypes)
            updateSelection(model,objectsAdded);
        end
    end

end

function blockInfo=getBlockInfoForDiagram(model,input)

    selectedUUID='';
    if isfield(input,'UUID')
        selectedUUID=input.UUID;
    end

    sessionIDs=unique(input.sessionIDs);
    blockInfo=getBlockInfo(model,sessionIDs,selectedUUID);

end

function blockInfo=getBlockInfoForObjects(model,objs)

    sessionIDs=get(objs,{'SessionID'});
    sessionIDs=[sessionIDs{:}];
    blockInfo=getBlockInfo(model,sessionIDs,'');

end

function blockInfo=getBlockInfo(model,sessionIDs,selectedUUID)


    template=struct('sessionID','','UUID','','x','','y','','width','','height','');


    props=getBlockAppearanceProperties;
    for i=1:numel(props)
        template.(props{i})='';
    end

    blockInfo=repmat(template,1,numel(sessionIDs));
    count=0;

    for i=1:numel(sessionIDs)
        next=sessionIDs(i);
        block=model.getEntitiesInMap(next);
        if~isempty(block)
            count=count+1;
            block=block(1);


            sizeInfo=block.getSize;
            posInfo=getBlockAbsolutePosition(model,block);


            blockInfo(count).sessionID=next;
            blockInfo(count).isSource=strcmp(block.uuid,selectedUUID);
            blockInfo(count).UUID=getAttributeValue(block,'uuid');
            blockInfo(count).x=posInfo.x;
            blockInfo(count).y=posInfo.y;
            blockInfo(count).width=sizeInfo.width;
            blockInfo(count).height=sizeInfo.height;
            blockInfo(count).annotation=getAttributeValue(block,'annotation');


            blockInfo(count)=SimBiology.web.diagram.utilhandler('getBlockInfo',block,blockInfo(count));
        end
    end

    if count==0
        blockInfo=[];
    else
        blockInfo=blockInfo(1:count);
    end

end

function pasteBlocks(operations,model,target,blockInfo,objectsAdded,input)

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        blocksNeedingConfiguration=[];
        source='diagram';

        for i=1:numel(objectsAdded)
            if blockSupportedInDiagram(objectsAdded(i))||isa(objectsAdded(i),'SimBiology.Event')
                SimBiology.web.diagram.eventhandler('addBlockToDiagramAfterObjectAdded',operations,model,syntax.root,objectsAdded(i),source,blocksNeedingConfiguration);
            end
        end

        setBlockInfo(operations,model,target,blockInfo,objectsAdded,input);
    end

end

function setBlockInfo(operations,model,target,blockInfo,objectsAdded,input)

    if isempty(blockInfo)
        return;
    end


    source=input.source;


    annotationSessionID=input.lastSessionID;



    if isa(target,'SimBiology.Model')
        target=updateTarget(model,objectsAdded);
    end


    allBlocks=model.getAllEntitiesInMap;
    targetBlock=model.getEntitiesInMap(target.sessionID);


    if any(strcmp(input.source,{'diagramShortCut','table'}))
        [x,y]=findDropForPasteShortCut(model,target,targetBlock,blockInfo,objectsAdded,allBlocks);
    else
        x=input.x;
        y=input.y;
    end

    [top,left]=getTopLeftCorner(blockInfo);




    adjustPosition=~doesObjectAddNeedAutomaticPlacement(source);




    compartmentsUpdated={};
    for i=1:numel(blockInfo)
        next=blockInfo(i);
        if next.sessionID>0
            block=model.getEntitiesInMap(next.sessionID);
            if~isempty(block)
                blockInfo(i).block=block;
                if strcmp(blockInfo(i).block.type,'compartment')
                    compartmentsUpdated{end+1}=blockInfo(i);%#ok<AGROW>
                end
            end
        end
    end





    if~isempty(compartmentsUpdated)
        compartmentsUpdated=[compartmentsUpdated{:}];
        compartmentBlocks=[compartmentsUpdated.block];
        [~,idx]=sort(arrayfun(@calcArea,compartmentsUpdated));
        compartmentBlocks=compartmentBlocks(idx);
        compartmentsUpdated=compartmentsUpdated(idx);




        compartmentsUpdated=getNewPositionForCompartmentBlocks(compartmentBlocks,compartmentsUpdated,model,x,y,top,left);
        blocksUpdated=cell(1,length(compartmentsUpdated));
        compartmentBlocks=cell(1,length(compartmentsUpdated));
        compartmentPositions=cell(1,length(compartmentsUpdated));

        for i=1:length(compartmentsUpdated)
            blocksUpdated{i}=compartmentsUpdated(i);
            compartmentBlocks{i}=compartmentsUpdated(i).block;
            compartmentPositions{i}=compartmentsUpdated(i).newPosition;
        end

        compartmentBlocks=[compartmentBlocks{:}];
    else
        blocksUpdated={};
        compartmentBlocks=[];
        compartmentPositions={};
    end

    for i=1:numel(blockInfo)
        next=blockInfo(i);

        if next.sessionID<0
            annotationSessionID=annotationSessionID-1;
            next=createAnnotationBlock(operations,model,next,annotationSessionID);
        end

        if isfield(next,'block')&&~strcmp(next.block.type,'compartment')
            next.newPosition=[];
            if adjustPosition
                next.newPosition=getNewPositionForBlock(next,model,x,y,top,left,compartmentBlocks,compartmentPositions);
                operations.setSize(next.block,next.width,next.height);
                operations.setPosition(next.block,next.newPosition.x,next.newPosition.y);
            end

            blocksUpdated{end+1}=next;%#ok<AGROW>
        end
    end

    blocksUpdated=[blocksUpdated{:}];



    if~isempty(blocksUpdated)&&adjustPosition
        adjustSizesAndShiftDownAndToRight(operations,model,target,targetBlock,blocksUpdated,objectsAdded);
    end

    blocksToReparent={};
    for i=1:numel(blocksUpdated)
        next=blocksUpdated(i);
        block=next.block;

        SimBiology.web.diagram.utilhandler('setBlockInfo',operations,block,next);


        if adjustPosition
            operations.setSize(block,next.width,next.height);
            operations.setPosition(block,next.newPosition.x,next.newPosition.y);




            if isa(target,'SimBiology.Compartment')
                if strcmp(next.block.type,'species')


                    verifyPlacementOfSpeciesBlock(operations,model,next.block,next,compartmentBlocks,compartmentPositions);
                elseif~strcmp(next.block.type,'compartment')
                    blocksToReparent{end+1}=next.block;%#ok<AGROW>
                end
            elseif strcmp(next.block.type,'species')



                verifyPlacementOfSpeciesBlock(operations,model,next.block,next,compartmentBlocks,compartmentPositions);
            elseif any(strcmpi(next.block.type,{'reaction','rate','repeatedAssignment','parameter'}))


                blocksToReparent{end+1}=next.block;%#ok<AGROW>
            end
        end
    end

    if~isempty(blocksToReparent)
        blocksToReparent=[blocksToReparent{:}];
        SimBiology.web.diagram.layouthandler('reparentBlocks',operations,model,allBlocks,blocksToReparent);
    end

end

function blockInfo=getNewPositionForCompartmentBlocks(compartmentBlocks,blockInfo,model,x,y,top,left)


    positions=cell(1,length(compartmentBlocks));


    for i=length(compartmentBlocks):-1:1
        blockInfo(i).newPosition=[];
        compartmentPosition=[];



        compartmentPosition.x=(blockInfo(i).x-left)+x;
        compartmentPosition.y=(blockInfo(i).y-top)+y;
        compartmentPosition.absX=compartmentPosition.x;
        compartmentPosition.absY=compartmentPosition.y;

        obj=sbioselect(model,'SessionID',blockInfo(i).sessionID);
        target=obj.Owner;
        if~isempty(target)
            targetBlock=model.getEntitiesInMap(target.SessionID);
        end

        if isa(target,'SimBiology.Compartment')
            pos=getCompartmentBlockPosition(model,targetBlock,compartmentBlocks,positions);
            compartmentPosition.x=compartmentPosition.x-pos.x;
            compartmentPosition.y=compartmentPosition.y-pos.y;
            compartmentPosition=adjustPositionForCompartmentOwner(model,target,compartmentBlocks,positions,compartmentPosition);
        end

        compartmentPosition.width=blockInfo(i).width;
        compartmentPosition.height=blockInfo(i).height;
        compartmentPosition.left=compartmentPosition.x;
        compartmentPosition.top=compartmentPosition.y;
        compartmentPosition.right=compartmentPosition.left+compartmentPosition.width;
        compartmentPosition.bottom=compartmentPosition.top+compartmentPosition.height;

        blockInfo(i).newPosition=compartmentPosition;
        positions{i}=compartmentPosition;
    end

end

function out=adjustPositionForCompartmentOwner(model,target,compartmentBlocks,positions,out)

    if isa(target,'SimBiology.Compartment')
        owner=target.Owner;
        if~isempty(owner)
            ownerBlock=model.getEntitiesInMap(owner.SessionID);
            pos=getCompartmentBlockPosition(model,ownerBlock,compartmentBlocks,positions);
            out.x=out.x-pos.x;
            out.y=out.y-pos.y;
            out=adjustPositionForCompartmentOwner(model,owner,compartmentBlocks,positions,out);
        end
    end

end

function pos=getNewPositionForBlock(blockInfo,model,x,y,top,left,compartmentBlocks,positions)

    pos=[];



    pos.x=(blockInfo.x-left)+x;
    pos.y=(blockInfo.y-top)+y;
    pos.absX=pos.x;
    pos.absY=pos.y;

    obj=sbioselect(model,'SessionID',blockInfo.sessionID);
    if isa(obj,'SimBiology.Species')
        target=obj.Parent;
        targetBlock=model.getEntitiesInMap(target.SessionID);

        targetPos=getCompartmentBlockPosition(model,targetBlock,compartmentBlocks,positions);
        pos.x=pos.x-targetPos.x;
        pos.y=pos.y-targetPos.y;
        pos=adjustPositionForCompartmentOwner(model,target,compartmentBlocks,positions,pos);
    end

    pos.width=blockInfo.width;
    pos.height=blockInfo.height;
    pos.left=pos.x;
    pos.top=pos.y;
    pos.right=pos.left+pos.width;
    pos.bottom=pos.top+pos.height;

end

function out=getCompartmentBlockPosition(model,block,compartmentBlocks,positions)

    out={};
    for i=1:length(compartmentBlocks)
        if strcmp(compartmentBlocks(i).uuid,block.uuid)
            out=positions{i};
            break;
        end
    end

    if isempty(out)
        pt=block.getPosition;
        absPt=getBlockAbsolutePosition(model,block);
        out.x=pt.x;
        out.y=pt.y;
        out.absX=absPt.x;
        out.absY=absPt.y;
    end





end

function adjustSizesAndShiftDownAndToRight(operations,model,target,targetBlock,blockInfo,objectsAdded)


    blockRect=getBoundingRect(blockInfo);

    if~isequal(target,model)


        targetAbsolutePosition=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,targetBlock);
        blockRect.x=blockRect.x-targetAbsolutePosition.x;
        blockRect.right=blockRect.right-targetAbsolutePosition.x;
        blockRect.y=blockRect.y-targetAbsolutePosition.y;
        blockRect.bottom=blockRect.bottom-targetAbsolutePosition.y;
    end
    blockRect.left=blockRect.x;
    blockRect.top=blockRect.y;



    addedBlockSessionIDs=[objectsAdded.SessionID];
    SimBiology.web.diagram.placementhandler('adjustSizesAndShiftDownAndToRight',operations,model,targetBlock,blockRect,addedBlockSessionIDs);

    for i=1:numel(blockInfo)

        next=blockInfo(i);
        pos=next.newPosition;
        operations.setPosition(blockInfo(i).block,pos.x,pos.x);
    end

end

function[bLeft,bTop]=findDropForPasteShortCut(model,target,targetBlock,blockInfo,objectsAdded,allBlocks)


    top=inf;
    left=inf;
    bottom=0;
    right=0;

    for i=1:length(blockInfo)
        next=blockInfo(i);
        top=min(top,next.y);
        left=min(left,next.x);
        right=max(right,next.x+next.width);
        bottom=max(bottom,next.y+next.height);
    end

    width=right-left;
    height=bottom-top;


    occupancyMap=buildOccupanceMap(model,target,targetBlock,objectsAdded,allBlocks);


    [success,rect]=findRectangle(occupancyMap,width,height,true);


    if~isempty(targetBlock)
        bPos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,targetBlock);
    else
        bPos.x=0;
        bPos.y=0;
    end

    if success
        bLeft=bPos.x+rect(1);
        bTop=bPos.y+rect(3);
    else
        canvasRect=occupancyMap.Canvas;
        if isa(target,'SimBiology.Model')
            bLeft=canvasRect(1);
            bTop=canvasRect(4)+40;
        else

            bSize=targetBlock.getSize;
            bLeft=bPos.x+10;
            bTop=bPos.y+bSize.height;
        end
    end

end

function occupancyMap=buildOccupanceMap(model,target,targetBlock,objectsAdded,allBlocks)


    blocksAddedSessionIDs=get(objectsAdded,{'SessionID'});
    blocksAddedSessionIDs=[blocksAddedSessionIDs{:}];
    isNewBlock=false(1,length(allBlocks));
    for i=1:length(allBlocks)
        sessionID=allBlocks(i).getAttribute('sessionID').value;
        isNewBlock(i)=any(sessionID==blocksAddedSessionIDs);
    end

    blocksAdded=allBlocks(isNewBlock);
    allBlocks=allBlocks(~isNewBlock);


    if isa(target,'SimBiology.Model')
        diagramRect=getDiagramRectangle(model,blocksAdded);
        canvasRect=[diagramRect.left,diagramRect.right,diagramRect.top,diagramRect.bottom];
        canvasCoordinates=canvasRect;
        occupancyMap=SimBiology.web.diagram.OccupancyMap(canvasCoordinates);
    elseif isa(target,'SimBiology.Compartment')
        targetSize=targetBlock.getSize;
        canvasRect=[0,targetSize.width,0,targetSize.height];


        canvasMargins=[10,-10,10,-10];
        canvasCoordinates=canvasRect+canvasMargins;
        occupancyMap=SimBiology.web.diagram.OccupancyMap(canvasCoordinates);
        allBlocks=SimBiology.web.diagram.placementhandler('getBlocksWithinCompartmentBounds',targetBlock,blocksAdded);
    end

    SimBiology.web.diagram.placementhandler('addBlocksToOccupancyMap',occupancyMap,model,allBlocks,true,false);

end

function rect=getBoundingRect(blocks)

    top=inf;
    left=inf;
    bottom=0;
    right=0;

    for i=1:length(blocks)
        next=blocks(i).newPosition;
        top=min(top,next.absY);
        left=min(left,next.absX);
        right=max(right,next.absX+next.width);
        bottom=max(bottom,next.absY+next.height);
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

function verifyPlacementOfSpeciesBlock(operations,model,block,blockInfo,compartmentBlocks,compartmentPositions)




    sessionID=getAttributeValue(block,'sessionID');
    species=sbioselect(model,'Type','species','SessionID',sessionID);
    compartment=species.Parent;
    compBlock=model.getEntitiesInMap(compartment.SessionID);




    sizeInfo=block.getSize;
    speciesRect.top=blockInfo.newPosition.absY;
    speciesRect.left=blockInfo.newPosition.absX;
    speciesRect.bottom=speciesRect.top+sizeInfo.height;
    speciesRect.right=speciesRect.left+sizeInfo.width;

    compPos=getCompartmentBlockPosition(model,compBlock,compartmentBlocks,compartmentPositions);
    sizeInfo=compBlock.getSize;
    compRect.top=compPos.absY;
    compRect.left=compPos.absX;
    compRect.bottom=compRect.top+sizeInfo.height;
    compRect.right=compRect.left+sizeInfo.width;

    if~rectContains(compRect,speciesRect)


        SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,[],species,false);
    end

end

function[top,left]=getTopLeftCorner(blockInfo)

    top=inf;
    left=inf;

    for i=1:numel(blockInfo)
        x=blockInfo(i).x;
        y=blockInfo(i).y;

        if(x<left)
            left=x;
        end

        if(y<top)
            top=y;
        end
    end

end

function next=createAnnotationBlock(operations,model,next,sessionID)



    obj.Name='';
    obj.Type='annotation';
    obj.SessionID=sessionID;
    obj.UUID=-1;


    if model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        newBlock=SimBiology.web.diagramhandler('createBlock',operations,model,syntax.root,obj);


        operations.setAttributeValue(newBlock,'annotation',next.annotation);
        operations.setAttributeValue(newBlock,'uuid',newBlock.uuid);
        operations.setAttributeValue(newBlock,'parentSessionID',model.SessionID);


        next.block=newBlock;
        next.sessionID=sessionID;
        next.UUID=newBlock.uuid;
    end

end

function lastSessionID=getLastSessionID(model,blockInfo,lastSessionID)

    for i=1:numel(blockInfo)
        next=blockInfo(i);
        block=model.getEntitiesInMap(next.sessionID);

        if~isempty(block)&&(next.sessionID<0)
            lastSessionID=lastSessionID-1;
        end
    end

end

function out=blockSupportedInDiagram(obj)

    out=SimBiology.web.diagramhandler('blockSupportedInDiagram',obj);

end

function out=calcArea(blockInfo)

    out=blockInfo.width*blockInfo.height;

end

function out=getBlockAbsolutePosition(model,block)

    out=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,block);

end

function out=getAttributeValue(blocks,property)

    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);

end

function rect=getDiagramRectangle(model,blocksToExclude)

    rect=SimBiology.web.diagram.layouthandler('getDiagramRectangle',model,blocksToExclude);

end

function out=doesObjectAddNeedAutomaticPlacement(source)

    out=~any(strcmp(source,{'diagram','diagramShortCut','table'}));

end

function props=getBlockAppearanceProperties

    props=SimBiology.web.diagram.utilhandler('getBlockAppearanceProperties');

end

function out=rectContains(rect1,rect2)

    out=rect2.left>rect1.left&&rect2.top>rect1.top&&rect2.bottom<rect1.bottom&&rect2.right<rect1.right;

end

function updateSelection(model,objs)

    sessionIDs=[objs.SessionID];
    types=get(objs,{'Type'});
    idx=strcmp('rule',types);
    for i=1:length(objs)
        if idx(i)
            types{i}=objs(i).RuleType;
        end
    end

    SimBiology.web.diagramhandler('sendObjectSelectionEvent',model.SessionID,sessionIDs,types);

end

function target=updateTarget(model,objectsAdded)

    target=model;
    try
        comps=sbioselect(objectsAdded,'Type','compartment');
        if isempty(comps)
            species=sbioselect(objectsAdded,'Type','species');
            parents=get(species,{'Parent'});
            parents=[parents{:}];
            parents=unique(parents);

            if numel(parents)==1
                target=parents;
            end
        end
    catch
    end
end
