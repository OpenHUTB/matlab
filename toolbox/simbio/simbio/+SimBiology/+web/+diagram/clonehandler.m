function out=clonehandler(action,varargin)











    out=[];

    switch(action)
    case 'blockMergeHelper'
        blockMergeHelper(varargin{:});
    case 'clone'
        clone(varargin{:});
    case 'cloneInternal'
        cloneInternal(varargin{:});
    case 'findCloneIndex'
        out=findCloneIndex(varargin{:});
    case 'join'
        join(varargin{:});
    case 'joinInternal'
        joinInternal(varargin{:});
    case 'merge'
        merge(varargin{:});
    case 'mergeWithUndo'
        mergeWithUndo(varargin{:});
    case 'split'
        split(varargin{:});
    case 'splitInternal'
        splitInternal(varargin{:});
    case 'getUUIDsInMap'
        out=getUUIDsInMap(varargin{:});
    end

end

function clone(root,input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    diagramEditor=model.getDiagramEditor;
    commandProcessor=diagramEditor.commandProcessor;

    input.model=model;
    input.input=input;
    input.root=root;
    input.cloneInternalFcn=@cloneInternal;
    input.commandProcessor=commandProcessor;

    SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
    cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.CloneCommand','Custom Clone',input);
    commandProcessor.execute(cmd);

end

function cloneInternal(operations,root,input)


    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);

    for i=1:numel(input.selection)
        obj=sbioselect(model,'SessionID',input.selection(i).sessionID);
        blocks=model.getEntitiesInMap(input.selection(i).sessionID);
        UUIDs={blocks.uuid};
        selectedBlock=blocks(ismember(UUIDs,input.selection(i).diagramUUID));

        if isempty(selectedBlock)
            continue;
        end

        selectedBlock=selectedBlock(1);
        dosed=getAttributeValue(selectedBlock,'dosed');
        dosedDisabled=getAttributeValue(selectedBlock,'dosedDisabled');
        hasDuplicateName=getAttributeValue(selectedBlock,'hasDuplicateName');
        variant=getAttributeValue(selectedBlock,'variant');
        variantDisabled=getAttributeValue(selectedBlock,'variantDisabled');
        blockInfo=getBlockInfo(selectedBlock);


        clonedIndex=findCloneIndex(blocks)+1;



        if strcmp(obj.type,'species')

            parentBlock=model.getEntitiesInMap(obj.Parent.SessionID);
            clonedBlock=createBlock(operations,model,parentBlock.subdiagram,obj);
            operations.setAttributeValue(clonedBlock,'dosed',dosed);
            operations.setAttributeValue(clonedBlock,'dosedDisabled',dosedDisabled);
            operations.setAttributeValue(clonedBlock,'hasDuplicateName',hasDuplicateName);
            operations.setAttributeValue(clonedBlock,'variant',variant);
            operations.setAttributeValue(clonedBlock,'variantDisabled',variantDisabled);
        else
            clonedBlock=createBlock(operations,model,root,obj);
        end

        operations.setAttributeValue(clonedBlock,'cloned','true');
        operations.setAttributeValue(clonedBlock,'cloneIndex',clonedIndex);
        setBlockInfo(operations,clonedBlock,blockInfo)


        pos=selectedBlock.getPosition;
        operations.setPosition(clonedBlock,floor(pos.x+5),floor(pos.y+5));


        bsize=selectedBlock.getSize;
        operations.setSize(clonedBlock,bsize.width,bsize.height);



        operations.setAttributeValue(selectedBlock,'cloned','true');
    end

end

function join(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    diagramEditor=model.getDiagramEditor;
    commandProcessor=diagramEditor.commandProcessor;

    input.model=model;
    input.input=input;
    input.joinInternalFcn=@joinInternal;
    input.commandProcessor=commandProcessor;

    SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
    cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.JoinCommand','Custom Join',input);
    commandProcessor.execute(cmd);

end

function joinInternal(operations,input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);

    for i=1:numel(input.selection)
        blocks=model.getEntitiesInMap(input.selection(i).sessionID);
        UUIDs={blocks.uuid};
        selectedBlock=blocks(ismember(UUIDs,input.selection(i).diagramUUID));

        if isempty(selectedBlock)
            continue;
        end


        selectedBlock=selectedBlock(1);


        operations.setAttributeValue(selectedBlock,'cloned','false');
        operations.setAttributeValue(selectedBlock,'cloneIndex',1);

        blockMergeHelper(operations,model,selectedBlock,blocks);
    end

end

function split(root,input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    diagramEditor=model.getDiagramEditor;
    commandProcessor=diagramEditor.commandProcessor;

    input.model=model;
    input.root=root;
    input.input=input;
    input.splitInternalFcn=@splitInternal;
    input.commandProcessor=commandProcessor;

    SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
    cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.SplitCommand','Custom Split',input);
    commandProcessor.execute(cmd);

end

function splitInternal(operations,root,input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);


    for j=1:numel(input.selection)


        blocks=model.getEntitiesInMap(input.selection(j).sessionID);
        UUIDs={blocks.uuid};
        selectedBlock=blocks(ismember(UUIDs,input.selection(j).diagramUUID));

        if isempty(selectedBlock)
            continue;
        end

        selectedBlock=selectedBlock(1);
        dosed=getAttributeValue(selectedBlock,'dosed');
        dosedDisabled=getAttributeValue(selectedBlock,'dosedDisabled');
        variant=getAttributeValue(selectedBlock,'variant');
        variantDisabled=getAttributeValue(selectedBlock,'variantDisabled');
        componentObj=sbioselect(model,'SessionID',input.selection(j).sessionID);
        blockInfo=getBlockInfo(selectedBlock);



        connections=selectedBlock.connections;


        connectionsToDestroy={};



        clonedIndex=findCloneIndex(blocks);



        bsize=selectedBlock.getSize;
        pos=selectedBlock.getPosition;
        x=pos.x;
        y=pos.y;

        for i=2:numel(connections)
            type=connections(i).getAttribute('type').value;

            if~strcmp(type,'expressionLine')
                clonedIndex=clonedIndex+1;


                operations.setAttributeValue(selectedBlock,'cloned','true');



                if strcmp(componentObj.type,'species')
                    parentBlock=model.getEntitiesInMap(componentObj.Parent.SessionID);
                    clonedBlock=createBlock(operations,model,parentBlock.subdiagram,componentObj);
                    operations.setAttributeValue(clonedBlock,'dosed',dosed);
                    operations.setAttributeValue(clonedBlock,'dosedDisabled',dosedDisabled);
                    operations.setAttributeValue(clonedBlock,'variant',variant);
                    operations.setAttributeValue(clonedBlock,'variantDisabled',variantDisabled);
                else
                    clonedBlock=createBlock(operations,model,root,componentObj);
                end

                operations.setAttributeValue(clonedBlock,'cloned','true');
                operations.setAttributeValue(clonedBlock,'cloneIndex',clonedIndex);
                setBlockInfo(operations,clonedBlock,blockInfo);


                destinationBlock=connections(i).destination;
                sourceBlock=connections(i).source;
                destinationSessionID=destinationBlock.getAttribute('sessionID').value;


                if destinationSessionID==componentObj.sessionID
                    createLineBetweenBlocks(operations,sourceBlock,clonedBlock,type);
                else
                    createLineBetweenBlocks(operations,clonedBlock,destinationBlock,type);
                end



                x=x+5;
                y=y+5;
                operations.setPosition(clonedBlock,x,y);


                operations.setSize(clonedBlock,bsize.width,bsize.height);


                connectionsToDestroy{end+1}=connections(i);%#ok<AGROW>
            end
        end

        for i=1:numel(connectionsToDestroy)

            operations.destroy(connectionsToDestroy{i},false);
        end
    end


end

function merge(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)mergeOperations(operations,model,inputs));
    end

end

function mergeWithUndo(model,inputs)

    diagramEditor=model.getDiagramEditor;
    commandProcessor=diagramEditor.commandProcessor;

    input.model=model;
    input.input=inputs;
    input.mergeOperationsFcn=@mergeOperations;
    input.commandProcessor=commandProcessor;

    SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
    cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.MergeCommand','Custom Merge',input);
    commandProcessor.execute(cmd);

end

function mergeOperations(operations,model,inputs)


    mergeInfo=inputs.mergeInfo;

    mergedIntoBlocks={};
    for i=1:numel(mergeInfo)
        blocks=model.getEntitiesInMap(mergeInfo(i).sessionID);
        UUIDs={blocks.uuid};
        mergeIntoBlock=blocks(ismember(UUIDs,mergeInfo(i).mergeIntoBlock));
        block=blocks(ismember(UUIDs,mergeInfo(i).block));

        if~isempty(mergeIntoBlock)&&~isempty(block)

            blockMergeHelper(operations,model,mergeIntoBlock,block);
            mergedIntoBlocks{end+1}=mergeIntoBlock;%#ok<AGROW>
        end
    end



    if~isempty(mergedIntoBlocks)
        for i=1:numel(mergedIntoBlocks)
            sessionID=mergedIntoBlocks{i}.getAttribute('sessionID').value;

            clones=model.getEntitiesInMap(sessionID);
            if numel(clones)>1
                operations.setAttributeValue(clones(i),'cloned','true');

                for j=1:numel(clones)
                    operations.setAttributeValue(clones(j),'cloneIndex',j);
                end
            else

                operations.setAttributeValue(clones(1),'cloned','false');
                operations.setAttributeValue(clones(1),'cloneIndex',1);
            end

            if i==1

                selectBlockUsingUUID(inputs.modelSessionID,mergedIntoBlocks{i}.uuid);
            end
        end
    end

end

function blockMergeHelper(operations,model,mergeIntoBlock,blocks)

    for i=numel(blocks):-1:1
        if~strcmp(blocks(i).uuid,mergeIntoBlock.uuid)
            connections=blocks(i).connections;



            for j=1:numel(connections)
                sourceBlock=connections(j).source;
                destinationBlock=connections(j).destination;

                if strcmp(sourceBlock.uuid,blocks(i).uuid)
                    sourceBlock=mergeIntoBlock;
                else
                    destinationBlock=mergeIntoBlock;
                end


                type=connections(j).getAttribute('type').value;


                operations.destroy(connections(j),false);
                createLineBetweenBlocks(operations,sourceBlock,destinationBlock,type);
            end



            deleteBlocks(operations,model,blocks(i));
        end
    end





end

function idx=findCloneIndex(blocks)

    idx=zeros(numel(blocks),1);
    for i=1:numel(blocks)
        idx(i)=blocks(i).getAttribute('cloneIndex').value;
    end

    idx=max(idx);

end

function selectBlockUsingUUID(modelSessionID,blockUUID)


    selectionEvent=struct;
    selectionEvent.type='selectBlockUsingUUID';
    selectionEvent.model=modelSessionID;
    selectionEvent.selection={struct('diagramUUID',blockUUID)};

    message.publish('/SimBiology/object',selectionEvent);

end

function out=getUUIDsInMap(model,input)

    sessionIDs=[input.selection.sessionID];
    template=struct('sessionID','','uuid','');
    out=repmat(template,1,numel(sessionIDs));

    for i=1:numel(sessionIDs)
        blocks=model.getEntitiesInMap(sessionIDs(i));
        uuids={blocks.uuid};
        out(i).sessionID=sessionIDs(i);
        out(i).uuid=uuids;
    end

end

function out=getAttributeValue(blocks,property)

    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);

end

function block=createBlock(operations,model,parent,obj)

    block=SimBiology.web.diagramhandler('createBlock',operations,model,parent,obj);

end

function createLineBetweenBlocks(operations,sourceBlock,destinationBlock,type)

    SimBiology.web.diagram.linehandler('createLineBetweenBlocks',operations,sourceBlock,destinationBlock,type);

end

function deleteBlocks(operations,model,blocks)

    SimBiology.web.diagramhandler('deleteBlocks',operations,model,blocks);

end

function blockInfo=getBlockInfo(block)

    blockInfo=SimBiology.web.diagram.utilhandler('getBlockInfo',block);

end

function setBlockInfo(operations,block,blockInfo)

    SimBiology.web.diagram.utilhandler('setBlockInfo',operations,block,blockInfo);
end
