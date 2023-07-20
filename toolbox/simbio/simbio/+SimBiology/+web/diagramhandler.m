function out=diagramhandler(action,varargin)











    out={action};

    switch(action)
    case 'initDiagramSyntax'
        out=SimBiology.web.diagram.inithandler('initDiagramSyntax',varargin{1});
    case 'initDiagramEditor'
        out=SimBiology.web.diagram.inithandler('initDiagramEditor',varargin{:});


    case 'addBlockToLibrary'
        out=addBlockToLibrary(action,varargin{:});
    case 'alignBlocks'
        SimBiology.web.diagram.alignmenthandler('alignBlocks',varargin{:});
    case 'applyBlockStyle'
        out=SimBiology.web.diagram.utilhandler('applyBlockStyle',varargin{:});
    case 'createBlockInDiagram'
        out=createBlockInDiagram(varargin{:});
    case 'configureBlockProperty'
        configureBlockProperty(varargin{1});
    case 'configureLineProperty'
        configureLineProperty(varargin{1});
    case 'deleteFromDiagram'
        deleteFromDiagram(varargin{:});
    case 'layoutDiagram'
        layoutDiagram(varargin{:});
    case 'layoutCompartment'
        layoutCompartment(varargin{:});
    case 'mergeBlocks'
        mergeBlocks(varargin{:});
    case 'positionBlocks'
        positionBlocks(varargin{:});
    case 'searchCleared'
        searchCleared(varargin{:});
    case 'searchComplete'
        searchComplete(varargin{:});
    case 'setZIndex'
        SimBiology.web.diagram.utilhandler('setZIndex',varargin{:});
    case 'showBlocks'
        showBlocks(varargin{:});
    case 'stateDropped'
        stateDropped(varargin{:})
    case 'removeBlockFromLibrary'
        out=removeBlockFromLibrary(action,varargin{:});
    case 'renameObjectFromDiagram'
        out=renameObjectFromDiagram(varargin{:});
    case 'reparentBlocks'
        reparentBlocks(varargin{:});
    case 'userConnectedBlocks'
        userConnectedBlocks(varargin{:});
    case 'userMovedLine'
        userMovedLine(varargin{:});
    case 'userCanceledLineMove'
        userCanceledLineMove(varargin{:});
    case{'cut','copy','paste'}
        out=SimBiology.web.diagram.clipboardhandler(action,varargin{:});


    case 'blockSupportedInDiagram'
        out=blockSupportedInDiagram(varargin{:});
    case 'configureBlock'
        configureBlock(varargin{:});
    case 'configureLinePropertyOperations'
        configureLinePropertyOperations(varargin{:});
    case 'configureVisiblePropertyOnBlock'
        configureVisiblePropertyOnBlock(varargin{:});
    case 'createBlock'
        out=createBlock(varargin{:});
    case 'deleteBlocks'
        deleteBlocks(varargin{:});
    case 'deleteBlocksFalse'
        deleteBlocksFalse(varargin{:});
    case 'getAttributeValue'
        out=getAttributeValue(varargin{:});
    case 'getDefaultProperties'
        out=getDefaultProperties(varargin{:});
    case 'getParentObjects'
        out=getParentObjects(varargin{:});
    case 'getSupportedExpressionTypes'
        out=getSupportedExpressionTypes;
    case 'getSupportedRuleTypes'
        out=getSupportedRuleTypes;
    case 'isSupportedBlockType'
        out=isSupportedBlockType(varargin{:});
    case 'isSupportedRuleType'
        out=isSupportedRuleType(varargin{:});
    case 'eraseNeedsConfiguration'
        eraseNeedsConfiguration(varargin{:});
    case 'findBlocksThatNeedConfiguration'
        out=findBlocksThatNeedConfiguration(varargin{:});
    case 'sendObjectSelectionEvent'
        sendObjectSelectionEvent(varargin{:});
    case 'setAttributeValue'
        setAttributeValue(varargin{:});
    case 'setProperty'
        configureBlockPropertyOperations(varargin{:});
    case 'showBlocksInternal'
        showBlocksInternal(varargin{:});
    case 'fixMap'
        fixMap(varargin{:});
    case 'configureForUndoMove'
        configureForUndoMove(varargin{:});
    case 'moveBlocks'
        moveBlocks(varargin{:});
    end

end

function out=addBlockToLibrary(action,inputs)

    out=SimBiology.web.diagram.palettehandler(action,inputs);

end

function out=removeBlockFromLibrary(action,inputs)

    out=SimBiology.web.diagram.palettehandler(action,inputs);

end

function out=createBlockInDiagram(inputs)

    out=inputs;



    drawnow;


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    syntax=model.getDiagramSyntax;

    delta=jsondecode(inputs.delta);

    blockTF=string({delta.added.type})=='diagram.editor.model.Entity';
    assert(sum(blockTF)==1);

    block=syntax.findElement(delta.added(blockTF).uuid);


    if strcmp(inputs.type,'annotation')
        if~isempty(block)


            SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);

            blockInfo.sessionID=inputs.sessionID;
            blockInfo.uuid=block.uuid;
            blockInfo.type=inputs.type;


            configureAnnotationBlock(model,blockInfo);
        end
    else







        oldBlock=model.getEntitiesInMap(0);
        if~isempty(oldBlock)
            model.deleteEntitiesInMap(0,oldBlock);
        end
        model.addEntitiesToMap(0,block);
        SimBiology.web.modelhandler('createObjectInternal',inputs);
    end

end

function configureAnnotationBlock(model,blockInfo)


    syntax=model.getDiagramSyntax();
    blockToAdd=syntax.findElement(blockInfo.uuid);
    assert(~isempty(blockToAdd));
    model.addEntitiesToMap(blockInfo.sessionID,blockToAdd);

    blockConfiguration=struct('Type',blockInfo.type,'Name','','SessionID',blockInfo.sessionID,'UUID',blockInfo.uuid);
    props=getDefaultProperties(blockInfo.type);





    syntax.modify(@(operations)configureBlock(operations,blockToAdd,blockConfiguration,props));

    sendObjectSelectionEvent(model.SessionID,blockInfo.sessionID,{blockInfo.type});





    fixMapBlock=model.getEntitiesInMap(0);
    if~isempty(fixMapBlock)
        model.deleteEntitiesInMap(0,fixMapBlock);
    end

    transaction=SimBiology.Transaction.create(model);
    transaction.push(@()removeAnnotationBlock(model,blockInfo));
    transaction.commit();
end


function removeAnnotationBlock(model,blockInfo)








    syntax=model.getDiagramSyntax;
    syntax.modify(@(operations)deleteAnnotationBlocksOperations(operations,model,blockInfo.sessionID));

    transaction=SimBiology.Transaction.create(model);
    transaction.push(@()configureAnnotationBlock(model,blockInfo));
    transaction.commit();
end

function block=createBlock(operations,model,root,obj)



    block=operations.createEntity(root);
    props=getDefaultProperties(obj.Type);

    configureBlock(operations,block,obj,props);

    model.addEntitiesToMap(obj.SessionID,block);

end

function configureBlock(operations,b,obj,props)


    type=getObjectType(obj);


    operations.setTitle(b,obj.Name);
    operations.setType(b,type);


    operations.setAttributeValue(b,'sessionID',obj.SessionID);
    operations.setAttributeValue(b,'uuid',obj.UUID);


    operations.setAttributeValue(b,'textcolor',props.textcolor);
    operations.setAttributeValue(b,'facecolor',props.facecolor);
    operations.setAttributeValue(b,'edgecolor',props.edgecolor);
    operations.setAttributeValue(b,'textLocation',props.textLocation);
    operations.setAttributeValue(b,'fontFamily',props.fontFamily);
    operations.setAttributeValue(b,'fontWeight',props.fontWeight);
    operations.setAttributeValue(b,'fontSize',props.fontSize);
    operations.setAttributeValue(b,'visible',props.visible);
    operations.setAttributeValue(b,'rotate',props.rotate);
    operations.setAttributeValue(b,'split','none');
    operations.setAttributeValue(b,'name',obj.Name);
    operations.setAttributeValue(b,'fade','none');
    operations.setAttributeValue(b,'zIndex',props.zIndex);
    operations.setAttributeValue(b,'textAlign',props.textAlign);
    operations.setAttributeValue(b,'lines','hide');


    operations.setAttributeValue(b,'type',getObjectType(obj));


    operations.setAttributeValue(b,'pin',props.pin);
    operations.setAttributeValue(b,'active','false');
    operations.setAttributeValue(b,'boundaryCondition',getBoolString(obj,'BoundaryCondition'));
    operations.setAttributeValue(b,'constant',getBoolString(obj,'Constant'));
    operations.setAttributeValue(b,'dosed','false');
    operations.setAttributeValue(b,'dosedDisabled','false');
    operations.setAttributeValue(b,'hasDuplicateName',getBoolString(obj,'HasDuplicateName'));
    operations.setAttributeValue(b,'variant','false');
    operations.setAttributeValue(b,'variantDisabled','false');
    operations.setAttributeValue(b,'event','false');
    operations.setAttributeValue(b,'initialAssignment','false');
    operations.setAttributeValue(b,'repeatAssignment','false');
    operations.setAttributeValue(b,'error','false');
    operations.setAttributeValue(b,'plot','false');
    operations.setAttributeValue(b,'reversible',getBoolString(obj,'Reversible'));

    if ismember(type,{'species','parameter'})
        operations.setAttributeValue(b,'unused',logical2string(obj.InUseCount==0));
    else
        operations.setAttributeValue(b,'unused','false');
    end
    if isa(obj,'SimBiology.ModelComponent')
        operations.setAttributeValue(b,'hasDuplicateName',logical2string(obj.HasDuplicateName));
    else
        operations.setAttributeValue(b,'hasDuplciateName','false');
    end





    operations.setAttributeValue(b,'cloneIndex',props.cloneIndex);
    operations.setAttributeValue(b,'cloned',props.cloned);



    operations.setAttributeValue(b,'annotation',props.annotation);
    operations.setAttributeValue(b,'autoResizeBlock',props.autoResizeBlock);


    operations.setAttributeValue(b,'shape',props.shape);
    operations.setAttributeValue(b,'shapeRadius',props.shapeRadius);
    operations.setAttributeValue(b,'imageData',props.imageData);


    operations.setSize(b,props.width,props.height);



    if strcmp(obj.Type,'parameter')&&isa(obj.Parent,'SimBiology.KineticLaw')
        operations.setAttributeValue(b,'parentSessionID',obj.Parent.Parent.SessionID);
    elseif strcmp(obj.Type,'compartment')&&~isempty(obj.Owner)
        operations.setAttributeValue(b,'parentSessionID',obj.Owner.SessionID);
    elseif strcmp(obj.Type,'species')
        operations.setAttributeValue(b,'parentSessionID',obj.Parent.SessionID);
    elseif isprop(obj,'Parent')
        operations.setAttributeValue(b,'parentSessionID',obj.Parent.SessionID);
    end

    if strcmp(type,'compartment')

        if~b.subdiagram.isValid
            operations.createSubdiagram(b);
        end

        operations.setAttributeValue(b,'zIndex',-1);
    end


    if b.hasAttribute('needsConfiguration')
        operations.eraseAttribute(b,'needsConfiguration');
    end

end

function configureLineProperty(inputs)

    SimBiology.web.diagram.linehandler('configureLineProperty',inputs);

end

function configureBlockProperty(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;

        if strcmp(inputs.property,'cloned')





            configureBlockPropertyOperations([],model,syntax.root,inputs);
        elseif strcmp(inputs.property,'annotationSize')


            syntax.modify(@(operations)configureAnnotationSizeProperty(operations,model,inputs));
        elseif~isUndoable(inputs.property)


            syntax.modify(@(operations)configureBlockIndicatorProperty(operations,model,syntax.root,inputs));
        else


            syntax.modify(@(operations)configureBlockPropertiesUndoHelper(operations,model,syntax.root,inputs));
        end
    end

end

function configureBlockIndicatorProperty(operations,model,root,inputs)


    for i=1:numel(inputs.selection)
        inputs.selection(i).value=inputs.value;
    end

    configureBlockPropertyOperations(operations,model,root,inputs);

end

function configureBlockPropertiesUndoHelper(operations,model,root,inputs)

    transaction=SimBiology.Transaction.create(model);


    for i=1:numel(inputs.selection)
        inputs.selection(i).value=inputs.value;
    end


    isCloneProp=isClonedProperty(inputs.property);
    currentInputs=inputs;

    for i=1:numel(inputs.selection)
        if isCloneProp



            block=getBlocksFromUUID(model,[inputs.selection(i).sessionID],{inputs.selection(i).diagramUUID});
        else


            block=getBlocksFromSessionID(model,[inputs.selection(i).sessionID]);


            assert(numel(block)>=1);
            block=block(1);
        end

        currentInputs.selection(i).value=block.getAttribute(inputs.property).value;
    end

    configureBlockPropertyOperations(operations,model,root,inputs);
    doFunction=@configureBlockPropertyOperations;
    transaction.push(@()SimBiology.web.diagram.undo.configureBlockPropertyOperationsLambda(doFunction,model,currentInputs,inputs));
    transaction.commit();

end

function positionBlocks(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)positionBlocksUndoHelper(operations,model,syntax,inputs));
    end

end

function positionBlocksUndoHelper(operations,model,syntax,inputs)

    transaction=SimBiology.Transaction.create(model);
    currentInputs=inputs;

    for i=1:numel(inputs.positionInfo)

        if~isnumeric(inputs.positionInfo(i).width)
            inputs.positionInfo(i).width=str2double(inputs.positionInfo(i).width);
        end

        if~isnumeric(inputs.positionInfo(i).height)
            inputs.positionInfo(i).height=str2double(inputs.positionInfo(i).height);
        end

        if~isnumeric(inputs.positionInfo(i).x)
            inputs.positionInfo(i).x=str2double(inputs.positionInfo(i).x);
        end

        if~isnumeric(inputs.positionInfo(i).y)
            inputs.positionInfo(i).y=str2double(inputs.positionInfo(i).y);
        end



        block=getBlocksFromUUID(model,inputs.positionInfo(i).sessionID,inputs.positionInfo(i).diagramUUID);
        blockSize=block.getSize;
        blockPos=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,block);


        currentInputs.positionInfo(i).x=blockPos.x;
        currentInputs.positionInfo(i).y=blockPos.y;
        currentInputs.positionInfo(i).width=blockSize.width;
        currentInputs.positionInfo(i).height=blockSize.height;
    end

    for i=1:numel(currentInputs.reparentInfo)
        obj=sbioselect(model,'Type',currentInputs.reparentInfo(i).type,'SessionID',currentInputs.reparentInfo(i).object);
        if isequal(obj.Parent,model)

            currentInputs.reparentInfo(i).parent=-1;
        else
            currentInputs.reparentInfo(i).parent=obj.Parent.SessionID;
        end
    end

    configureBlockPropertyOperations(operations,model,syntax.root,inputs);
    doFunction=@configureBlockPropertyOperations;
    transaction.push(@()SimBiology.web.diagram.undo.configureBlockPropertyOperationsLambda(doFunction,model,currentInputs,inputs));
    transaction.commit();

end

function configureBlockPropertyOperations(operations,model,root,inputs)

    switch inputs.property
    case 'size'
        configureSizeProperty(operations,model,inputs);
    case{'positionOnly','position'}
        configurePositionProperty(operations,model,inputs);
    case{'positionOnLoad'}




        configurePositionOnLoad(operations,model,inputs);
    case 'shape'

        configureShapeProperty(operations,model,inputs);
    case 'visible'

        configureVisibleProperty(operations,model,inputs);
    case 'cloned'
        switch inputs.value
        case 'join'
            SimBiology.web.diagram.clonehandler('join',inputs);
        case 'clone'
            SimBiology.web.diagram.clonehandler('clone',root,inputs);
        case 'split'
            SimBiology.web.diagram.clonehandler('split',root,inputs);
        end
    case 'lines'
        configureLinePropertyOperations(operations,model,inputs);
    case 'pin'

        for i=1:numel(inputs.selection)

            block=getBlocksFromUUID(model,[inputs.selection(i).sessionID],{inputs.selection(i).diagramUUID});
            if~isempty(block)
                property=inputs.property;
                value=inputs.selection(i).value;
                operations.setAttributeValue(block,property,value);
            end
        end
    otherwise
        for i=1:numel(inputs.selection)

            blocks=getBlocksFromSessionID(model,inputs.selection(i).sessionID);
            if~isempty(blocks)
                blocks=blocks([blocks.isValid]);
                property=inputs.property;
                value=inputs.selection(i).value;

                for j=1:numel(blocks)
                    operations.setAttributeValue(blocks(j),property,value);
                end
            end
        end
    end

end

function configureAnnotationSizeProperty(operations,model,inputs)

    block=getBlocksFromUUID(model,inputs.selection.sessionID,inputs.selection.diagramUUID);
    if~isempty(block)
        operations.setSize(block,inputs.value(1),inputs.value(2));
    end

end

function configureSizeProperty(operations,model,inputs)

    for i=1:numel(inputs.positionInfo)
        block=getBlocksFromUUID(model,inputs.positionInfo(i).sessionID,inputs.positionInfo(i).diagramUUID);
        if~isempty(block)
            operations.setSize(block,inputs.positionInfo(i).width,inputs.positionInfo(i).height);
        end
    end

end

function configurePositionProperty(operations,model,inputs)

    syntax=model.getDiagramSyntax();





    isReparentOperation=isfield(inputs,'reparentInfo')&&~isempty(inputs.reparentInfo);
    if isReparentOperation
        tfIsComponentReparenting=ismember([inputs.positionInfo.sessionID],[inputs.reparentInfo.object]);
    else
        tfIsComponentReparenting=false(1,numel(inputs.positionInfo));
    end
    for i=1:numel(inputs.positionInfo)
        block=getBlocksFromUUID(model,inputs.positionInfo(i).sessionID,inputs.positionInfo(i).diagramUUID);
        if~isempty(block)
            if tfIsComponentReparenting(i)


                parentSessionID=inputs.reparentInfo(i).parent;
                parentBlock=model.getEntitiesInMap(parentSessionID);
            else




















                parentBlock=block.getParent();
                if parentBlock==syntax.root
                    parentBlock=[];
                else
                    parentBlock=block.getParent().getParent();
                end
            end
            blockIsCompartmentOrSpecies=block.type=="compartment"||block.type=="species";
            useRelativePosition=~isempty(parentBlock)&&blockIsCompartmentOrSpecies;
            if useRelativePosition



                newParentAbsolutePosition=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',model,parentBlock);
                inputs.positionInfo(i).x=inputs.positionInfo(i).x-newParentAbsolutePosition.x;
                inputs.positionInfo(i).y=inputs.positionInfo(i).y-newParentAbsolutePosition.y;
            end
            operations.setPosition(block,inputs.positionInfo(i).x,inputs.positionInfo(i).y);
            if~blockIsCompartmentOrSpecies



                operations.setParent(block,syntax.root);
                SimBiology.web.diagram.layouthandler('reparentBlocks',operations,model,[],block);
            end
        end
    end

    if isReparentOperation

        reparentBlocks(inputs);
    end

end

function configurePositionOnLoad(operations,model,inputs)





    blocks=getBlocksFromUUID(model,[inputs.selection.sessionID],{inputs.selection.diagramUUID});
    x=inputs.value(1);
    y=inputs.value(2);

    if~isnumeric(x)
        x=str2double(x);
    end

    if~isnumeric(y)
        y=str2double(y);
    end


    for i=1:numel(blocks)
        operations.setPosition(blocks(i),x,y);
    end

end

function configureVisibleProperty(operations,model,inputs)

    for i=1:numel(inputs.selection)
        value=inputs.selection(i).value;
        if strcmp(value,'true')
            blocks=getBlocksFromSessionID(model,inputs.selection(i).sessionID);
        else
            blocks=getBlocksFromUUID(model,inputs.selection(i).sessionID,inputs.selection(i).diagramUUID);
        end

        if~isempty(blocks)
            blocks=blocks([blocks.isValid]);
            for j=1:numel(blocks)
                configureVisiblePropertyOnBlock(operations,blocks(j),value);
            end
        end
    end

end

function configureVisiblePropertyOnBlock(operations,block,value)

    operations.setAttributeValue(block,'visible',value);
    connections=block.connections;

    for i=1:numel(connections)
        if strcmp(value,'true')

            sourceBlock=connections(i).source;
            destinationBlock=connections(i).destination;
            sourceVisible=getAttributeValue(sourceBlock,'visible');
            destinationVisible=getAttributeValue(destinationBlock,'visible');

            if strcmp(sourceVisible,'true')&&strcmp(destinationVisible,'true')
                operations.setAttributeValue(connections(i),'visible',value);
            end
        else

            operations.setAttributeValue(connections(i),'visible',value);
        end
    end

    if strcmp(value,'true')

        parentBlock=block.diagram.parentEntity;
        if~isempty(parentBlock)&&parentBlock.isValid
            configureVisiblePropertyOnBlock(operations,parentBlock,'true');
        end
    else
        type=getAttributeValue(block,'type');


        if strcmp(type,'compartment')
            children=block.subdiagram.entities;
            for i=1:numel(children)
                configureVisiblePropertyOnBlock(operations,children(i),value)
            end
        end
    end

end

function configureShapeProperty(operations,model,inputs)

    for i=1:numel(inputs.selection)

        blocks=getBlocksFromSessionID(model,inputs.selection(i).sessionID);
        property=inputs.property;
        value=inputs.selection(i).value;

        if~isempty(blocks)
            blocks=blocks([blocks.isValid]);
        end

        for j=1:numel(blocks)


            if isShapeEnum(value)
                operations.setAttributeValue(blocks(j),property,value);


                operations.setAttributeValue(blocks(j),'imageData','');


                shapeRadius=getShapeRadius(value,blocks(j).type);
                operations.setAttributeValue(blocks(j),'shapeRadius',shapeRadius);
            else

                info=SimBiology.web.diagram.utilhandler('getImageData',value);
                operations.setAttributeValue(blocks(j),property,info.filename);
                operations.setAttributeValue(blocks(j),'imageData',info.imageData);
            end
        end
    end

end

function configureLinePropertyOperations(operations,model,inputs)



    for i=1:numel(inputs.selection)
        block=getBlocksFromSessionID(model,inputs.selection(i).sessionID);
        property=inputs.property;
        value=inputs.selection(i).value;

        if~isempty(block)
            operations.setAttributeValue(block,property,value);
        end
    end

    for i=1:numel(inputs.selection)
        obj=sbioselect(model,'SessionID',inputs.selection(i).sessionID);
        switch(obj.Type)
        case 'reaction'
            SimBiology.web.diagram.reactionhandler('showLines',operations,model,obj);
        case 'rule'
            SimBiology.web.diagram.rulehandler('showLines',operations,model,obj);
        end
    end

end

function showBlocks(inputs)


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)showBlocksOperations(operations,model,inputs));
    end

end

function showBlocksOperations(operations,model,inputs)

    inputs.value='true';
    showBlocks=inputs;
    hideBlocks=inputs;
    hideBlocks.value='false';
    transaction=SimBiology.Transaction.create(model);

    showBlocksInternal(operations,model,inputs);
    transaction.push(@()SimBiology.web.diagram.undo.setVisibleLambda(model,hideBlocks,showBlocks));
    transaction.commit();

end

function showBlocksInternal(operations,model,inputs)

    sessionIDs=inputs.sessionIDs;
    for i=1:numel(sessionIDs)
        blocks=getBlocksFromSessionID(model,sessionIDs(i));
        for j=1:numel(blocks)
            configureVisiblePropertyOnBlock(operations,blocks(j),inputs.value);
        end
    end

end

function fixMap(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        block=syntax.findElement(inputs.blockUUID);

        assert(block.isValid);



        model.addEntitiesToMap(0,block);
    end

end

function configureForUndoMove(inputs)



    if inputs.isReparentOp






        model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
        delta=jsondecode(inputs.delta);
        idx=string({delta.modified.type})=='diagram.editor.model.Entity';
        blockUUID=string({delta.modified(idx).uuid});
        syntax=model.getDiagramSyntax;

        for i=1:numel(blockUUID)
            block=syntax.findElement(blockUUID(i));







            if strcmp(block.type,'species')||strcmp(block.type,'compartment')
                syntax.modify(@(operations)setNeedsConfiguration(operations,block));
            end
        end
    end

    if inputs.isMergeOp
        model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
        delta=jsondecode(inputs.delta);
        idx=string({delta.modified.type})=='diagram.editor.model.Entity';
        blockUUID=string({delta.modified(idx).uuid});
        syntax=model.getDiagramSyntax;

        for i=1:numel(blockUUID)
            block=syntax.findElement(blockUUID(i));
            sessionID=block.getAttribute('sessionID').value;
            blocks=model.getEntitiesInMap(sessionID);
            uuids={blocks.uuid};

            if~any(strcmp(blockUUID(i),uuids))
                model.addEntitiesToMap(sessionID,block);
            else

            end
        end
    end

end

function deleteFromDiagram(inputs)


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)
        transaction=SimBiology.Transaction.create(model);

        if~isempty(inputs.blocks)
            deleteBlocksFromDiagram(inputs.modelSessionID,inputs.blocks);
        end

        if~isempty(inputs.lines)
            SimBiology.web.diagram.linehandler('deleteLinesFromDiagram',inputs.modelSessionID,inputs.lines);
        end

        transaction.commit;
    end

end

function deleteBlocksFromDiagram(modelSessionID,input)


    model=SimBiology.web.modelhandler('getModelFromSessionID',modelSessionID);

    if~isempty(model)


        idx=ismember(input.types,'annotation');
        if any(idx)
            sessionIDs=input.sessionIDs(idx);
            diagramEditor=model.getDiagramEditor;
            commandProcessor=diagramEditor.commandProcessor;
            inputArgs=struct;
            inputArgs.model=model;
            inputArgs.sessionIDs=sessionIDs;
            inputArgs.deleteAnnotationBlocksOperationsFcn=@deleteAnnotationBlocksOperations;
            inputArgs.commandProcessor=commandProcessor;

            SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
            cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.DeleteAnnotationBlockCommand','Custom Annotation Block Delete',inputArgs);
            commandProcessor.execute(cmd);
        end


        if~isempty(input.sessionIDs)
            types=getSupportedDeleteTypes;



            objIdx=cellfun(@(x)strcmp(x,'parameter'),input.types);
            paramSessionIDs=input.sessionIDs(objIdx);

            for i=1:numel(types)
                objIdx=cellfun(@(x)strcmp(x,types{i}),input.types);
                sessionIDs=unique(input.sessionIDs(objIdx));

                if~isempty(sessionIDs)
                    type=types{i};
                    if isSupportedRuleType(type)
                        type='Rule';
                    end

                    UUIDs=input.uuids(objIdx);
                    blocks=getBlocksFromUUID(model,sessionIDs,UUIDs);

                    switch(type)
                    case 'species'


                        SimBiology.web.diagram.specieshandler('deleteBlock',blocks,modelSessionID);
                    case 'parameter'
                        SimBiology.web.diagram.parameterhandler('deleteBlock',paramSessionIDs,modelSessionID,type);
                    case 'compartment'
                        SimBiology.web.diagram.compartmenthandler('deleteBlock',blocks,model);
                    otherwise
                        SimBiology.web.modelhandler('deleteObject',struct('modelSessionID',modelSessionID,'objectIDs',sessionIDs,'type',type,'forceDelete',true));
                    end
                end
            end
        end
    end

end

function deleteAnnotationBlocksOperations(operations,model,sessionIDs)

    for i=1:numel(sessionIDs)
        annotationBlock=model.getEntitiesInMap(sessionIDs(i));
        deleteBlocks(operations,model,annotationBlock);
    end

end

function layoutDiagram(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        input=struct('setCompartmentSize',false,'layoutType',inputs.layout);
        syntax.modify(@(operations)SimBiology.web.diagram.layouthandler('layoutDiagram',model,syntax,operations,input));
    end

end

function layoutCompartment(inputs)


    inputs.model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    SimBiology.web.diagram.layouthandler('layoutCompartment',inputs);

end

function mergeBlocks(inputs)

    SimBiology.web.diagram.clonehandler('merge',inputs);
end

function reparentBlocks(inputs)


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    if isempty(model)||~model.hasDiagramSyntax
        return;
    end

    syntax=model.getDiagramSyntax;


    reparentInfo=inputs.reparentInfo;
    for i=1:length(reparentInfo)
        objToMove=reparentInfo(i).object;
        objType=reparentInfo(i).type;
        newParent=reparentInfo(i).parent;


        if newParent==-1
            newParent=model;
        else
            newParent=findobj(model.Compartments,'SessionID',newParent,'-depth',0);
        end


        objToMove=sbioselect(model,'type',objType,'SessionID',objToMove);


        if~isempty(objToMove)
            blocks=model.getEntitiesInMap(objToMove.SessionID);
            syntax.modify(@(operations)setNeedsConfiguration(operations,blocks));

            if isa(objToMove,'SimBiology.Compartment')
                move(objToMove,newParent);
            else
                move(objToMove,newParent,'force');
            end
        end
    end

end

function moveBlocks(inputs)


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);


    outerTransaction=SimBiology.Transaction.create(model);


    reparentInfo=inputs.reparentInfo;




    assert(isa(reparentInfo,'struct'));

    for i=1:length(reparentInfo)
        objToMove=reparentInfo(i).object;
        objType=reparentInfo(i).type;

        if reparentInfo(i).isReparentOperation

            objToMove=sbioselect(model,'type',objType,'SessionID',objToMove);
            newParent=sbioselect(model,'SessionID',inputs.reparentInfo(i).parent);


            if~isempty(objToMove)


                if isa(objToMove,'SimBiology.Compartment')
                    move(objToMove,newParent);
                    SimBiology.web.codecapturehandler('postObjectMovedEvent',newParent,objToMove,false);
                elseif isa(objToMove,'SimBiology.Species')
                    move(objToMove,newParent,'force');
                    SimBiology.web.codecapturehandler('postObjectMovedEvent',newParent,objToMove,true);
                end
            end
        end
    end



    diagramEditor=model.getDiagramEditor;
    commandProcessor=diagramEditor.commandProcessor;
    input.model=model;
    input.input=inputs;
    input.configurePositionPropertyFcn=@configurePositionProperty;
    input.commandProcessor=commandProcessor;


    SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
    cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.BlockMoveCommand','Block Move',input);
    commandProcessor.execute(cmd);


    if isfield(reparentInfo,'isMergeOperation')
        for i=1:numel(reparentInfo)
            if reparentInfo(i).isMergeOperation
                mergeInfo.sessionID=reparentInfo(i).object;
                mergeInfo.block=reparentInfo(i).blockUUID;
                mergeInfo.mergeIntoBlock=reparentInfo(i).mergeIntoBlockUUID;
                mergeData.mergeInfo=mergeInfo;
                mergeData.modelSessionID=inputs.modelSessionID;
                mergeData.selection.sessionID=reparentInfo(i).object;
                SimBiology.web.diagram.clonehandler('mergeWithUndo',model,mergeData);
            end
        end
    end

    outerTransaction.commit();

end

function stateDropped(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    target=sbioselect(model,'SessionID',input.targetSessionID);
    transaction=SimBiology.Transaction.create(model);

    if isa(target,'SimBiology.Rule')


        state=sbioselect(model,'SessionID',input.stateSessionID);
        SimBiology.web.modelhandler('configureRuleUsingQuantity',target,state);
    end

    transaction.commit;

end

function out=renameObjectFromDiagram(inputs)


    out=SimBiology.web.modelhandler('configureObjectProperty',inputs);


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    source=sbioselect(model,'SessionID',inputs.sessionID);
    if~isempty(source)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        blocks=getBlocksFromSessionID(model,inputs.sessionID);
        syntax.modify(@(operations)setAttributeValue(operations,blocks,'name',source.Name));
    end

end

function userConnectedBlocks(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)
        source=sbioselect(model,'SessionID',inputs.sourceSessionID);
        destination=sbioselect(model,'SessionID',inputs.destinationSessionID);

        sourceType=source.Type;
        destinationType=destination.Type;







        sourceBlocks=model.getEntitiesInMap(inputs.sourceSessionID);
        sourceUUIDs={sourceBlocks.uuid};
        sourceBlock=sourceBlocks(ismember(sourceUUIDs,{inputs.sourceBlockUUID}));

        destBlock=model.getEntitiesInMap(inputs.destinationSessionID);
        destUUIDs={destBlock.uuid};
        destBlock=destBlock(ismember(destUUIDs,{inputs.destinationBlockUUID}));


        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)setNeedsConfiguration(operations,[sourceBlock,destBlock]));


        transaction=SimBiology.Transaction.create(model);

        if strcmp(sourceType,'rule')
            SimBiology.web.modelhandler('configureRuleUsingQuantity',source,destination);
        elseif strcmp(destinationType,'rule')
            SimBiology.web.modelhandler('configureRuleUsingQuantity',destination,source);
        elseif strcmp(sourceType,'event')
            SimBiology.web.modelhandler('addQuantityToEvent',source,destination);
        elseif strcmp(destinationType,'event')
            SimBiology.web.modelhandler('addQuantityToEvent',destination,source);
        elseif strcmp(sourceType,'reaction')
            SimBiology.web.modelhandler('addReactantOrProductToReaction',source,destination,false);
        elseif strcmp(destinationType,'reaction')
            SimBiology.web.modelhandler('addReactantOrProductToReaction',destination,source,true);
        elseif strcmp(destinationType,'species')&&strcmp(sourceType,'species')
            addReactionBetweenSpeciesFromDiagram(model,source,destination,inputs);
        end

        transaction.commit;
    end

end

function addReactionBetweenSpeciesFromDiagram(model,reactant,product,inputs)


    input=struct;
    input.modelSessionID=model.SessionID;
    input.prefs=inputs.prefs;
    input.type='reaction';
    input.value=sprintf('%s -> %s',reactant.PartiallyQualifiedNameReally,product.PartiallyQualifiedNameReally);

    SimBiology.web.modelhandler('createObjectInternal',input);

end

function userMovedLine(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        source=sbioselect(model,'SessionID',inputs.sourceSessionID);
        destination=sbioselect(model,'SessionID',inputs.destinationSessionID);
        oldDestination=sbioselect(model,'SessionID',inputs.oldDestinationSessionID);



        sourceType=source.Type;




        sourceBlocks=model.getEntitiesInMap(inputs.sourceSessionID);
        sourceUUIDs={sourceBlocks.uuid};
        sourceBlock=sourceBlocks(strcmp(inputs.sourceBlockUUID,sourceUUIDs));

        destBlock=model.getEntitiesInMap(inputs.destinationSessionID);
        destUUIDs={destBlock.uuid};
        destBlock=destBlock(strcmp(inputs.destinationBlockUUID,destUUIDs));


        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)setNeedsConfiguration(operations,[sourceBlock,destBlock]));


        transaction=SimBiology.Transaction.create(model);

        if strcmp(sourceType,'rule')
            SimBiology.web.modelhandler('configureRuleUsingQuantity',source,destination);
        elseif strcmp(sourceType,'event')
            SimBiology.web.modelhandler('replaceEventLHS',source,destination,oldDestination);
        elseif strcmp(sourceType,'reaction')
            SimBiology.web.modelhandler('replaceQuantityInReaction',source,destination,oldDestination);
        end

        transaction.commit;
    end

end

function userCanceledLineMove(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)userCanceledLineMoveOperations(operations,model,inputs));
    end

end

function userCanceledLineMoveOperations(operations,model,inputs)

    source=sbioselect(model,'SessionID',inputs.sourceSessionID);
    destination=sbioselect(model,'SessionID',inputs.destinationSessionID);




    sourceBlocks=model.getEntitiesInMap(inputs.sourceSessionID);
    sourceUUIDs={sourceBlocks.uuid};
    sourceBlock=sourceBlocks(strcmp(inputs.sourceBlockUUID,sourceUUIDs));

    destBlock=model.getEntitiesInMap(inputs.destinationSessionID);
    destUUIDs={destBlock.uuid};
    destBlock=destBlock(strcmp(inputs.destinationUUID,destUUIDs));

    type='';
    reaction='';
    if isa(source,'SimBiology.Reaction')
        reaction=source;
        species=destination;
    elseif isa(destination,'SimBiology.Reaction')
        reaction=source;
        species=destination;
    elseif isa(source,'SimBiology.Rule')
        type='lhsLine';
    elseif isa(destination,'SimBiology.Rule')
        type='lhsLine';
    end

    if isempty(type)&&~isempty(reaction)
        reactants=reaction.Reactants;
        products=reaction.Products;
        isReactant=any(species==reactants);
        isProduct=any(species==products);
        if isReactant&&isProduct
            type='reactantProductLine';
        elseif isReactant
            type='reactantLine';
        elseif isProduct
            type='productLine';
        end
    end

    line=SimBiology.web.diagram.linehandler('getLineBetweenBlocks',sourceBlock,destBlock);
    linecolor=getAttributeValue(line,'linecolor');
    linewidth=getAttributeValue(line,'linewidth');

    line=SimBiology.web.diagram.linehandler('createLineBetweenBlocks',operations,sourceBlock,destBlock,type);
    operations.setAttributeValue(line,'linecolor',linecolor);
    operations.setAttributeValue(line,'linewidth',linewidth);

end

function searchComplete(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)searchCompleteOperations(operations,model,inputs.sessionID));
    end

end

function searchCompleteOperations(operations,model,sessionIDs)

    allBlocks=model.getAllEntitiesInMap;
    for i=1:length(allBlocks)
        value=getAttributeValue(allBlocks(i),'fade');
        if any(strcmp(value,{'false','none'}))
            setAttributeValue(operations,allBlocks(i),'fade','true');
            setAttributeValue(operations,allBlocks(i).connections,'fade','true');
        end
    end

    for i=1:length(sessionIDs)
        block=model.getEntitiesInMap(sessionIDs(i));
        setAttributeValue(operations,block,'fade','false');
    end

end

function searchCleared(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);
    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)searchClearedOperations(operations,model));
    end

end

function searchClearedOperations(operations,model)

    allBlocks=model.getAllEntitiesInMap;
    for i=1:length(allBlocks)
        value=getAttributeValue(allBlocks(i),'fade');
        if any(strcmp(value,{'false','true'}))
            setAttributeValue(operations,allBlocks(i),'fade','none');
            setAttributeValue(operations,allBlocks(i).connections,'fade','none');
        end
    end

end

function out=blockSupportedInDiagram(component)

    out=false;
    if~isempty(component)


        type=lower(getObjectType(component));
        types=lower(getSupportedTypes);
        out=ismember(type,types);
    end

end

function deleteBlocks(operations,model,blocks)

    for i=1:numel(blocks)
        sessionID=blocks(i).getAttribute('sessionID').value;
        model.deleteEntitiesInMap(sessionID,blocks(i));
        operations.destroy(blocks(i),true);
    end

end

function deleteBlocksFalse(operations,model,blocks)

    for i=1:numel(blocks)
        sessionID=blocks(i).getAttribute('sessionID').value;
        model.deleteEntitiesInMap(sessionID,blocks(i));
        operations.destroy(blocks(i),false);
    end

end

function eraseNeedsConfiguration(operations,blocks)

    for i=1:numel(blocks)
        if blocks(i).hasAttribute('needsConfiguration')
            operations.eraseAttribute(blocks(i),'needsConfiguration');
        end
    end

end

function out=findBlocksThatNeedConfiguration(arg)

    if isa(arg,'SimBiology.Model')
        blocks=arg.getAllEntitiesInMap;
    else

        blocks=SimBiology.web.diagram.utilhandler('getBlocksWalkDiagram',arg);
    end

    idx=arrayfun(@(x)x.hasAttribute('needsConfiguration'),blocks);
    out=blocks(idx);

end

function out=getAttributeValue(blocks,attrName)

    out=repmat({''},numel(blocks),1);

    for i=1:numel(blocks)
        out{i}=blocks(i).getAttribute(attrName).value;
    end

    if numel(out)==1
        out=out{1};
    end

end

function blocks=getBlocksFromSessionID(model,sessionIDs)

    blocks=SimBiology.web.diagram.utilhandler('getBlocksFromSessionID',model,sessionIDs);

end

function blocks=getBlocksFromUUID(model,sessionIDs,UUIDs)

    blocks=SimBiology.web.diagram.utilhandler('getBlocksFromUUID',model,sessionIDs,UUIDs);





end

function out=getBoolString(obj,prop)

    out='false';
    if isprop(obj,prop)
        if obj.(prop)
            out='true';
        end
    end

end

function out=getShapeRadius(type,shape)
    switch(type)
    case 'rounded rectangle'
        switch(shape)
        case 'compartment'
            out=10;
        otherwise
            out=30;
        end
    case 'oval'
        out=40;
    otherwise
        out=0;
    end


end

function out=getDefaultProperties(type)



    out=struct;
    out.facecolor='none';
    out.textcolor="#000000";
    out.edgecolor='#d0b48c';
    out.textLocation='none';
    out.shape='rounded rectangle';
    out.shapeRadius=30;
    out.width=20;
    out.height=20;
    out.pin='false';
    out.visible='true';
    out.cloned='false';
    out.cloneIndex=1;
    out.annotation='';
    out.autoResizeBlock='false';
    out.fontFamily='Arial';
    out.fontWeight='plain';
    out.fontSize=14;
    out.textAlign='left';
    out.rotate=0;
    out.imageData='';
    out.zIndex=1;

    switch(type)
    case 'species'
        out.facecolor='#d4daec';
        out.edgecolor='#99a7d1';
        out.shapeRadius=30;
        out.textLocation='bottom';
        out.width=32;
        out.height=16;
    case 'reaction'
        out.facecolor='#f4cc60';
        out.edgecolor='#7a7a7a';
        out.shape='oval';
        out.shapeRadius=40;
        out.width=15;
        out.height=15;
    case 'parameter'
        out.facecolor='#c4da97';
        out.edgecolor='#619756';
        out.shapeRadius=30;
        out.textLocation='bottom';
        out.width=32;
        out.height=16;
    case 'compartment'
        out.edgecolor='#6679b9';
        out.textLocation='bottom';
        out.shapeRadius=10;
        out.width=200;
        out.height=200;
    case{'event','rule','rate','repeatedAssignment'}
        out.facecolor='#fff4e2';
        out.shape='rectangle';
        out.shapeRadius=0;
    case 'annotation'
        out.shape='rectangle';
        out.shapeRadius=0;
        out.facecolor='#f3f3f3';
        out.edgecolor='#c0c0c0';
        out.width=60;
        out.height=24;
        out.autoResizeBlock='true';
        out.zIndex=3;
    end

end

function type=getObjectType(component)

    type=lower(component.Type);
    if strcmp(type,'rule')
        type=component.RuleType;
    end

end

function parents=getParentsForObjectRecursive(compartment,parents)

    if~isempty(compartment.Owner)
        compartment=compartment.Owner;
        parents{end+1}=compartment;
        parents=getParentsForObjectRecursive(compartment,parents);
    end

end

function parentObjs=getParentObjects(model,block)
    parentObjs={};

    if ismember(block.type,{'species','compartment'})

        obj=sbioselect(model,'SessionID',block.getAttribute('sessionID').value);

        if strcmp(block.type,'species')
            obj=obj.Parent;
            parentObjs{end+1}=obj;
        end



        parentObjs=getParentsForObjectRecursive(obj,parentObjs);
    end

    parentObjs=[parentObjs{:}];

end

function out=isShapeEnum(shape)


    out=ismember(shape,{'triangle','oval','rectangle','rounded rectangle','hexagon','chevron','parallelogram','diamond'});


end

function types=getSupportedExpressionTypes

    types={'reaction','repeatedAssignment','rate'};


end

function types=getSupportedRuleTypes

    types={'rate','repeatedAssignment'};

end

function out=isSupportedBlockType(type)

    out=ismember(type,getSupportedTypes);


end

function types=getSupportedTypes

    types={'repeatedAssignment','rate','reaction','species','compartment'};


end

function types=getSupportedDeleteTypes




    types={'parameter','repeatedAssignment','rate','reaction','species','compartment'};


end

function out=isUndoable(name)

    properties={'hasDuplicateName','unused','plot','active','boundaryCondition','constant','dosed','dosedDisabled','variant','variantDisabled','event','initialAssignment','repeatAssignment','error','reversible'};
    out=~ismember(name,properties);



end

function out=isClonedProperty(name)

    properties={'size','positionOnly','position','positionOnLoad','visible','pin'};
    out=ismember(name,properties);

end

function out=isSupportedRuleType(type)

    out=ismember(type,getSupportedRuleTypes);

end

function out=logical2string(value)

    out=SimBiology.web.diagram.utilhandler('logical2string',value);

end

function sendObjectSelectionEvent(modelSessionID,componentSessionID,type)


    selectionEvent=struct;
    selectionEvent.type='objectSelected';
    selectionEvent.source='Command Line';
    selectionEvent.model=modelSessionID;

    if~iscell(type)
        type={type};
    end

    selection=cell(1,numel(componentSessionID));
    for i=1:length(selection)
        next.sessionID=componentSessionID(i);
        next.type=type{i};
        selection{i}=next;
    end

    selectionEvent.selection=selection;

    message.publish('/SimBiology/object',selectionEvent);

end

function setAttributeValue(operations,blocks,attrName,value)

    for i=1:numel(blocks)
        operations.setAttributeValue(blocks(i),attrName,value);

        if strcmpi(attrName,'name')
            operations.setTitle(blocks(i),value);
        end
    end

end

function setNeedsConfiguration(operations,blocks)

    for i=1:numel(blocks)
        operations.setAttributeValue(blocks(i),'needsConfiguration',true);
    end
end
