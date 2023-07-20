function eventhandler(action,varargin)











    switch(action)
    case 'expressionStatusChanged'
        expressionStatusChanged(varargin{:});
    case 'objectAdded'
        objectAdded(varargin{:});
    case 'objectDeleted'
        objectDeleted(varargin{:});
    case 'objectMoved'
        objectMoved(varargin{:});
    case 'lhsChanged'
        lhsChanged(varargin{:});
    case 'propertyChanged'
        propertyChanged(varargin{:});
    case 'addBlockToDiagramAfterObjectAdded'
        addBlockToDiagramAfterObjectAdded(varargin{:});
    case 'blockAdded'
        blockAdded(varargin{:});
    end

end

function objectAdded(input,model)

    if~isempty(model)&&model.hasDiagramSyntax
        blocksNeedingConfiguration=model.getEntitiesInMap(0);

        syntax=model.getDiagramSyntax;
        interactiveAdd=~isempty(blocksNeedingConfiguration);



        if interactiveAdd
            syntax.modify(@(operations)objectAddedOperations(operations,model,syntax,blocksNeedingConfiguration,input));


            type=input.info.type;
            if strcmp(type,'rule')
                type=input.info.ruletype;
            end
            sendObjectSelectionEvent(model.SessionID,input.info.SessionID,{type});





            if strcmp(type,blocksNeedingConfiguration.type)
                model.deleteEntitiesInMap(0,blocksNeedingConfiguration);
            end

        else
            diagramEditor=model.getDiagramEditor;
            commandProcessor=diagramEditor.commandProcessor;
            input.model=model;
            input.input=input;
            input.blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model);
            input.objectAddedOperationsFcn=@objectAddedOperations;
            input.commandProcessor=commandProcessor;
            obj=sbioselect(model,'SessionID',input.info.SessionID);

            if blockSupportedInDiagram(obj)||isa(obj,'SimBiology.Event')
                syntax=model.getDiagramSyntax;
                syntax.modify(@(operations)eraseNeedsConfiguration(operations,input.blocksNeedingConfiguration));

                SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
                cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.AddCommand','Custom Add',input);
                commandProcessor.execute(cmd);
            end
        end
    end


end

function blockAdded(inputs,model,object)

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)blockAddedOperations(operations,object,model,syntax,inputs));
    end






end

function blockAddedOperations(operations,object,model,syntax,input)

    block=model.getEntitiesInMap(0);



    if isempty(block)
        return
    end

    model.deleteEntitiesInMap(0,block);

    objType=block.type;

    if strcmp(objType,'rule')
        objType=input.info.ruletype;
    end





    if~isempty(block)
        props=getDefaultProperties(block.type);




        existingProps=block.getAttributeKeys();
        for i=1:numel(existingProps)
            if isfield(props,existingProps{i})
                props.(existingProps{i})=block.getAttribute(existingProps{i}).value;
            end
        end

        configureBlock(operations,block,object,props);

        model.addEntitiesToMap(object.SessionID,block);
        eraseNeedsConfiguration(operations,block);
    end

end

function objectAddedOperations(operations,model,syntax,blocksNeedingConfiguration,input)

    block=model.getEntitiesInMap(input.info.SessionID);





    if~isempty(block)
        return;
    end


    objType=input.info.type;
    if strcmp(input.info.type,'rule')
        objType=input.info.ruletype;
    end

    for i=1:numel(blocksNeedingConfiguration)
        type=blocksNeedingConfiguration(i).getAttribute('type').value;
        parentSessionID=blocksNeedingConfiguration(i).getAttribute('parentSessionID').value;



        if strcmp(objType,'species')
            if strcmp(type,objType)&&(parentSessionID==input.info.ScopeSessionID)
                block=blocksNeedingConfiguration(i);
                break;
            end
        elseif strcmp(type,objType)
            block=blocksNeedingConfiguration(i);
            break;
        end
    end

    obj=sbioselect(model,'SessionID',input.info.SessionID);





    if~isempty(block)
        props=getDefaultProperties(obj.type);




        existingProps=block.getAttributeKeys();
        for i=1:numel(existingProps)
            if isfield(props,existingProps{i})
                props.(existingProps{i})=block.getAttribute(existingProps{i}).value;
            end
        end

        configureBlock(operations,block,obj,props);
        model.addEntitiesToMap(obj.SessionID,block);

    elseif blockSupportedInDiagram(obj)||isa(obj,'SimBiology.Event')
        addBlockToDiagramAfterObjectAdded(operations,model,syntax.root,obj,input.source,blocksNeedingConfiguration);
    end


    if~isempty(blocksNeedingConfiguration)
        eraseNeedsConfiguration(operations,blocksNeedingConfiguration);
    end

end

function addBlockToDiagramAfterObjectAdded(operations,model,syntaxRoot,obj,source,blocksNeedingConfiguration)



    needAutomaticLayout=SimBiology.web.diagram.clipboardhandler('doesObjectAddNeedAutomaticPlacement',source);


    checkForOverlap=~isempty(source);

    switch lower(obj.Type)
    case 'species'
        SimBiology.web.diagram.specieshandler('addBlock',operations,model,obj,needAutomaticLayout);
    case 'compartment'
        SimBiology.web.diagram.compartmenthandler('addBlock',operations,model,syntaxRoot,obj,needAutomaticLayout);
    case 'rule'
        SimBiology.web.diagram.rulehandler('addBlock',operations,model,syntaxRoot,obj,needAutomaticLayout,checkForOverlap);
    case 'reaction'
        SimBiology.web.diagram.reactionhandler('addBlock',operations,model,syntaxRoot,obj,blocksNeedingConfiguration,needAutomaticLayout,checkForOverlap);
    case 'event'
        SimBiology.web.diagram.eventObjhandler('eventAdded',operations,model,obj);
    end



end

function objectDeleted(input,model)

    if~strcmp(input.objType,'sbiomodel')
        if~isempty(model)&&model.hasDiagramSyntax
            blocks=model.getEntitiesInMap(input.obj);
            obj=sbioselect(model,'SessionID',input.obj);

            if~any(strcmp(input.message,{'undo','redo'}))
                if~isempty(blocks)||isa(obj,'SimBiology.Event')||isa(obj,'SimBiology.Parameter')
                    diagramEditor=model.getDiagramEditor;
                    commandProcessor=diagramEditor.commandProcessor;
                    input.model=model;
                    input.input=input;
                    input.objectDeletedOperationsFcn=@objectDeletedOperations;
                    input.commandProcessor=commandProcessor;

                    SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
                    cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.DeleteCommand','Custom Delete',input);
                    commandProcessor.execute(cmd);
                end
            else



                syntax=model.getDiagramSyntax;
                syntax.modify(@(operations)objectDeletedOperations(operations,syntax,blocks,model,obj));
            end
        end
    end

end

function objectDeletedOperations(operations,syntax,blocks,model,obj)

    try
        switch(obj.Type)
        case 'rule'
            SimBiology.web.diagram.rulehandler('objectDeleted',operations,model,obj);
        case 'event'
            SimBiology.web.diagram.eventObjhandler('eventDeleted',operations,syntax,model,obj);
        end
    catch
    end

    deleteBlocks(operations,model,blocks)

end

function objectMoved(input,model)

    if~any(strcmp(input.message,{'undo','redo'}))
        if any(strcmp(input.objType,{'species','compartment'}))


            diagramEditor=model.getDiagramEditor;
            commandProcessor=diagramEditor.commandProcessor;
            input.model=model;
            input.input=input;
            input.objectMovedOperationsFcn=@objectMovedOperations;
            input.commandProcessor=commandProcessor;

            SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
            cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.ObjectMovedCommand','Custom ObjectMoved',input);
            commandProcessor.execute(cmd);
        end
    end

end

function objectMovedOperations(operations,model,syntax,input)


    obj=sbioselect(model,'SessionID',input.sessionID);
    parent=[];

    if isa(obj,'SimBiology.Compartment')
        parent=obj.Owner;
    end

    if isempty(parent)
        parent=obj.Parent;
    end

    sessionID=parent.SessionID;
    blocks=model.getEntitiesInMap(input.sessionID);

    if isa(parent,'SimBiology.Compartment')
        parentBlock=model.getEntitiesInMap(parent.sessionID);
        parentBlock=parentBlock.subdiagram;
    else
        sessionID=model.SessionID;
        parentBlock=syntax.root;
    end

    blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model);




    tfBlockNeedsAutoPlacement=~ismember(string({blocks.uuid}),string({blocksNeedingConfiguration.uuid}));
    for i=1:numel(blocks)
        operations.setParent(blocks(i),parentBlock);
        if tfBlockNeedsAutoPlacement(i)
            positionSingleBlock(operations,model,blocks(i),[],obj);
        end
        setAttributeValue(operations,blocks(i),'parentSessionID',sessionID);
        eraseNeedsConfiguration(operations,blocks(i));
    end

end

function propertyChanged(input,model)

    if~isempty(model)&&model.hasDiagramSyntax
        obj=sbioselect(model,'SessionID',input.obj);

        if~isempty(obj)
            if~any(strcmp(input.message,{'undo','redo'}))
                if isa(obj,'SimBiology.Event')&&strcmp(input.property,'EventFcns')



                elseif isa(obj,'SimBiology.Rule')&&strcmp(input.property,'Rule')




                elseif blockSupportedInDiagram(obj)||isa(obj,'SimBiology.Event')||isa(obj,'SimBiology.Parameter')||isa(obj,'SimBiology.Rule')



                    if(doesPropertyChangeNeedCommand(model,obj,input.property,input.message))
                        diagramEditor=model.getDiagramEditor;
                        commandProcessor=diagramEditor.commandProcessor;
                        input.model=model;
                        input.input=input;
                        input.propertyChangedOperationsFcn=@propertyChangedOperations;
                        input.commandProcessor=commandProcessor;

                        SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
                        cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.PropertyChangedCommand','Custom PropertyChanged',input);
                        commandProcessor.execute(cmd);
                    else
                        syntax=model.getDiagramSyntax;
                        syntax.modify(@(operations)propertyChangedOperations(operations,model,syntax,obj,input));
                    end
                end
            elseif~doesPropertyChangeNeedCommand(model,obj,input.property,input.message)
                syntax=model.getDiagramSyntax;
                syntax.modify(@(operations)propertyChangedOperations(operations,model,syntax,obj,input));
            end
        end
    end

end

function propertyChangedOperations(operations,model,syntax,obj,input)

    try
        switch(obj.Type)
        case 'rule'
            SimBiology.web.diagram.rulehandler('propertyChanged',operations,model,syntax,obj,input);
        case 'reaction'
            SimBiology.web.diagram.reactionhandler('propertyChanged',operations,model,syntax,obj,input);
        case 'species'
            SimBiology.web.diagram.specieshandler('propertyChanged',operations,model,input);
        case 'compartment'
            SimBiology.web.diagram.compartmenthandler('propertyChanged',operations,model,syntax,obj,input);
        case 'event'
            SimBiology.web.diagram.eventObjhandler('eventPropertyChanged',operations,model,syntax);
        case 'parameter'
            SimBiology.web.diagram.parameterhandler('propertyChanged',operations,model,input);
        end
    catch ex %#ok<NASGU>

        findBlocksAndEraseNeedsConfiguration(operations,syntax);
    end

end

function out=doesPropertyChangeNeedCommand(model,obj,property,message)










    switch(property)
    case 'RuleType'
        out=true;
    case 'Reaction'
        if any(strcmp(message,{'undo','redo'}))



            out=true;
        else




            out=didReactionLayoutChange(model,obj);
        end
    otherwise
        out=false;
    end

end

function out=didReactionLayoutChange(model,obj)


    reactants=sort(unique([obj.Reactants.SessionID]));
    products=sort(unique([obj.Products.SessionID]));



    allReactants=[obj.Reactants.SessionID];
    allProudcts=[obj.Products.SessionID];

    if(numel(allReactants)~=numel(reactants))||(numel(allProudcts)~=numel(products))
        out=true;
        return;
    end


    sessionID=obj.SessionID;
    block=model.getEntitiesInMap(sessionID);
    connections=block.connections;
    currentReactants=[];
    currentProducts=[];

    for i=1:numel(connections)

        lineType=connections(i).getAttribute('type').value;
        sourceSessionID=connections(i).getAttribute('sourceSessionID').value;
        destinationSessionID=connections(i).getAttribute('destinationSessionID').value;
        nextSessionID=sourceSessionID;
        if(sessionID==sourceSessionID)
            nextSessionID=destinationSessionID;
        end

        switch(lineType)
        case 'reactantLine'
            currentReactants=[currentReactants,nextSessionID];
        case 'productLine'
            currentProducts=[currentProducts,nextSessionID];
        case 'reactantProductLine'
            currentReactants=[currentReactants,nextSessionID];
            currentProducts=[currentProducts,nextSessionID];
        end
    end

    currentReactants=sort(unique(currentReactants));
    currentProducts=sort(unique(currentProducts));

    out=~isequal(reactants,currentReactants)||~isequal(products,currentProducts);


end

function lhsChanged(input,model)

    if~isempty(model)&&model.hasDiagramSyntax
        undoLHSValues=cell(1,numel(input.obj));
        for i=1:numel(input.obj)
            undoLHSValues{i}=getParameterBlockInfo(model,input.oldLHS{i});
        end

        diagramEditor=model.getDiagramEditor;
        commandProcessor=diagramEditor.commandProcessor;
        input.model=model;
        input.sessionID=get(input.obj,'SessionID');
        input.undoInfo=undoLHSValues;
        input.lhsChangedOperationsFcn=@lhsChangedOperations;
        input.commandProcessor=commandProcessor;

        SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
        cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.LHSChangedCommand','Custom LHS Changed',input);
        commandProcessor.execute(cmd);
    end

end

function lhsChangedOperations(operations,model,syntax,input)

    sessionIDs=input.sessionID;

    for i=1:numel(sessionIDs)
        obj=sbioselect(model,'SessionID',sessionIDs(i));
        if isa(obj,'SimBiology.Event')
            input.property='EventFcns';
            input.sessionID=sessionIDs(i);
            propertyChangedOperations(operations,model,syntax,obj,input);
        elseif isa(obj,'SimBiology.Rule')
            input.property='Rule';
            input.sessionID=sessionIDs(i);
            propertyChangedOperations(operations,model,syntax,obj,input);
        end
    end

end

function out=getParameterBlockInfo(model,lhsObjs)

    out=[];
    count=1;

    for i=1:numel(lhsObjs)
        if isa(lhsObjs(i),'SimBiology.Parameter')
            block=model.getEntitiesInMap(lhsObjs(i).SessionID);
            if~isempty(block)
                out(count).sessionID=lhsObjs(i).SessionID;%#ok<*AGROW>
                out(count).uuid=block.uuid;
                count=count+1;
            end
        end
    end



end

function expressionStatusChanged(input,model)

    if~isempty(model)&&model.hasDiagramSyntax
        obj=sbioselect(model,'SessionID',input.sessionID);

        if isa(obj,'SimBiology.Reaction')&&any(strcmp(input.message,{'undo','redo'}))
            syntax=model.getDiagramSyntax;
            syntax.modify(@(operations)findBlocksAndEraseNeedsConfiguration(operations,syntax));
        end

        if~isempty(obj)&&(blockSupportedInDiagram(obj)||isa(obj,'SimBiology.Event'))
            syntax=model.getDiagramSyntax;
            syntax.modify(@(operations)expressionStatusChangedOperations(operations,model,syntax,input));
        end
    end

end

function expressionStatusChangedOperations(operations,model,syntax,input)


    blocks=model.getEntitiesInMap(input.sessionID);


    obj=sbioselect(model,'SessionID',input.sessionID);

    if~isempty(blocks)

        isInvalid=isEventStatusInvalid(input.status);
        for i=1:numel(blocks)
            setAttributeValue(operations,blocks(i),'error',logical2string(isInvalid));
        end

        switch(input.objType)
        case 'rule'
            SimBiology.web.diagram.rulehandler('createLines',operations,model,obj);
        case 'reaction'
            SimBiology.web.diagram.reactionhandler('updateLines',operations,model,syntax,obj);
        case 'event'
            SimBiology.web.diagram.eventObjhandler('eventExpressionStatus',operations,syntax,model);
        end
    end

end

function out=isEventStatusInvalid(status)

    out=false;

    for i=1:numel(status)
        out=(~status(i).CanParse)||(~status(i).IsValidLHS)||(status(i).HasConstantLHSError)||(~isempty(status(i).UnresolvedTokens));
        if out
            break;
        end
    end

end

function blocksNeedingConfiguration=findBlocksAndEraseNeedsConfiguration(operations,syntax)

    blocksNeedingConfiguration=findBlocksThatNeedConfiguration(syntax);


    eraseNeedsConfiguration(operations,blocksNeedingConfiguration);

end

function out=blockSupportedInDiagram(obj)

    out=SimBiology.web.diagramhandler('blockSupportedInDiagram',obj);

end

function configureBlock(operations,block,obj,props)

    SimBiology.web.diagramhandler('configureBlock',operations,block,obj,props);

end

function deleteBlocks(operations,model,blocks)

    SimBiology.web.diagramhandler('deleteBlocks',operations,model,blocks);

end

function eraseNeedsConfiguration(operations,blocksNeedingConfiguration)

    SimBiology.web.diagramhandler('eraseNeedsConfiguration',operations,blocksNeedingConfiguration);

end

function blocksNeedingConfiguration=findBlocksThatNeedConfiguration(arg)

    blocksNeedingConfiguration=SimBiology.web.diagramhandler('findBlocksThatNeedConfiguration',arg);

end

function props=getDefaultProperties(type)

    props=SimBiology.web.diagramhandler('getDefaultProperties',type);

end

function positionSingleBlock(operations,model,block,allBlocks,obj)

    SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,allBlocks,obj,false);

end

function out=logical2string(value)

    out=SimBiology.web.diagram.utilhandler('logical2string',value);

end

function sendObjectSelectionEvent(modelSessionID,objSessionID,objType)

    SimBiology.web.diagramhandler('sendObjectSelectionEvent',modelSessionID,objSessionID,objType);

end

function setAttributeValue(operations,blocks,attrName,value)

    SimBiology.web.diagramhandler('setAttributeValue',operations,blocks,attrName,value);
end
