function out=reactionhandler(action,varargin)











    out=[];

    switch(action)
    case 'addBlock'
        out=addBlock(varargin{:});
    case 'createLines'
        createLines(varargin{:});
    case 'propertyChanged'
        propertyChanged(varargin{:});
    case 'showLines'
        showLines(varargin{:});
    case 'updateLines'
        updateLines(varargin{:});
    end

end

function block=addBlock(operations,model,syntaxRoot,obj,blocksNeedingConfiguration,needAutomaticLayout,checkForOverlap)

    block=createBlock(operations,model,syntaxRoot,obj);




    types=getAttributeValue(blocksNeedingConfiguration,'type');

    speciesBlocks=[];
    if numel(blocksNeedingConfiguration)==2&&all(strcmp(types,'species'))
        speciesBlocks=blocksNeedingConfiguration;
        createReactionLinesBetweenTwoSpeciesBlocks(operations,obj,block,blocksNeedingConfiguration);
    else
        createLines(operations,model,obj);
    end


    if~isempty(block)&&needAutomaticLayout
        positionSingleBlock(operations,model,block,[],obj,checkForOverlap,speciesBlocks);
    end

end

function createLines(operations,model,reaction)



    reactants=reaction.Reactants.get({'SessionID'});
    products=reaction.Products.get({'SessionID'});

    reactants=[reactants{:}];
    products=[products{:}];


    reactantProduct=intersect(reactants,products);
    if~isempty(reactantProduct)
        reactants=setdiff(reactants,reactantProduct);
        products=setdiff(products,reactantProduct);
    end

    expressionSessionIDs=[];
    if isShowLines(model,reaction)
        expressionSessionIDs=getExpressionSessionIDs(reaction);
    end



    addReactionLinesHelper(operations,model,reaction.SessionID,reactantProduct,reactants,products,expressionSessionIDs);

end

function addReactionLinesHelper(operations,model,reactionSessionID,reactantProduct,reactants,products,expressionSessionIDs)

    for j=1:numel(reactantProduct)
        createLine(operations,model,reactionSessionID,reactantProduct(j),1,1,'reactantProductLine');
    end

    for j=1:numel(reactants)
        createLine(operations,model,reactants(j),reactionSessionID,1,1,'reactantLine');
    end

    for j=1:numel(products)
        createLine(operations,model,reactionSessionID,products(j),1,1,'productLine');
    end

    for j=1:numel(expressionSessionIDs)
        createLine(operations,model,reactionSessionID,expressionSessionIDs(j),1,1,'usageLine');
    end


end

function createReactionLinesBetweenTwoSpeciesBlocks(operations,reaction,reactionBlock,speciesBlocks)

    reactants=reaction.Reactants.get({'SessionID'});
    products=reaction.Products.get({'SessionID'});
    reactants=[reactants{:}];
    products=[products{:}];


    eraseNeedsConfiguration(operations,speciesBlocks);


    reactantProduct=intersect(reactants,products);
    if~isempty(reactantProduct)
        reactants=setdiff(reactants,reactantProduct);
        products=setdiff(products,reactantProduct);
    end

    if numel(reactants)~=1||numel(products)~=1
        error('There should be one reaction and one product when the user connects two distinct species');
    end



    sessionIds=getAttributeValue(speciesBlocks,'sessionID');
    sessionIds=[sessionIds{:}];
    reactantBlock=speciesBlocks(sessionIds==reactants(1));
    productBlock=speciesBlocks(sessionIds==products(1));


    createLineBetweenBlocks(operations,reactantBlock,reactionBlock,'reactantLine');
    createLineBetweenBlocks(operations,reactionBlock,productBlock,'productLine');

end

function propertyChanged(operations,model,syntax,obj,input)


    if strcmp(input.property,'Reaction')
        updateLines(operations,model,syntax,obj);
    elseif strcmp(input.property,'Name')
        handleNamePropertyChanged(operations,model,input)
    elseif strcmp(input.property,'Active')
        handleActivePropertyChanged(operations,model,obj)
    end

end

function handleNamePropertyChanged(operations,model,input)

    blocks=model.getEntitiesInMap(input.obj);
    setAttributeValue(operations,blocks,lower(input.property),input.value);

end

function handleActivePropertyChanged(operations,model,obj)

    block=model.getEntitiesInMap(obj.SessionID);
    setAttributeValue(operations,block.connections,'active',logical2string(~obj.Active));

end

function updateLines(operations,model,syntax,obj)


    block=model.getEntitiesInMap(obj.SessionID);


    reactants=obj.Reactants.get({'SessionID'});
    products=obj.Products.get({'SessionID'});
    reactants=[reactants{:}];
    products=[products{:}];


    reactantProduct=intersect(reactants,products);
    if~isempty(reactantProduct)
        reactants=setdiff(reactants,reactantProduct);
        products=setdiff(products,reactantProduct);
    end

    if~isempty(block)


        if~block.hasAttribute('needsConfiguration')
            updateReactionLinesOnBlock(operations,model,obj,block,reactants,products,reactantProduct);
        else


            blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model);


            eraseNeedsConfiguration(operations,blocksNeedingConfiguration);

            sourceBlock=block;
            destinationBlock=blocksNeedingConfiguration(~ismember({blocksNeedingConfiguration.uuid},block.uuid));
            destinationSessionID=destinationBlock.getAttribute('sessionID').value;




            existingLines=getLineBetweenBlocksUsingSessionID(model,obj.SessionID,destinationSessionID);
            if~isempty(existingLines)
                operations.destroy(existingLines,false);
            end

            if any(reactants==destinationSessionID)
                createLineBetweenBlocks(operations,destinationBlock,sourceBlock,'reactantLine');
            elseif any(products==destinationSessionID)
                createLineBetweenBlocks(operations,sourceBlock,destinationBlock,'productLine');
            elseif any(reactantProduct==destinationSessionID)
                createLineBetweenBlocks(operations,sourceBlock,destinationBlock,'reactantProductLine');
            end
        end
    end

end

function updateReactionLinesOnBlock(operations,model,obj,block,reactants,products,reactantProduct)

    newReactants=[];
    newProducts=[];
    newReactantProducts=[];
    newExpressionLines=[];
    reactionSessionID=obj.SessionID;
    reactionBlock=model.getEntitiesInMap(reactionSessionID);
    expressionSessionID=[];

    if isShowLines(model,obj)
        expressionSessionID=getExpressionSessionIDs(obj);
    end









    for i=1:numel(reactants)
        reactantLine=getLineBetweenBlocksUsingSessionID(model,reactionSessionID,reactants(i));
        if isempty(reactantLine)
            newReactants(end+1)=reactants(i);%#ok<AGROW>
        else

            if getAttribute(reactantLine,'sourceSessionID').value==reactants(i)

                operations.setAttributeValue(reactantLine,'type','reactantLine');
            else

                speciesBlock=model.getEntitiesInMap(reactants(i));
                speciesBlock=getBlockWithUUID(speciesBlock,reactantLine.getAttribute('sourceBlockUUID').value);
                createLineBetweenBlocks(operations,speciesBlock,reactionBlock,'reactantLine');
            end
        end
    end

    for i=1:numel(products)
        productLine=getLineBetweenBlocksUsingSessionID(model,reactionSessionID,products(i));
        if isempty(productLine)
            newProducts(end+1)=products(i);%#ok<AGROW>
        else

            if getAttribute(productLine,'sourceSessionID').value==reactionSessionID
                operations.setAttributeValue(productLine,'type','productLine');
            else
                speciesBlock=model.getEntitiesInMap(products(i));
                speciesBlock=getBlockWithUUID(speciesBlock,productLine.getAttribute('destinationBlockUUID').value);
                createLineBetweenBlocks(operations,reactionBlock,speciesBlock,'productLine');
            end
        end
    end

    for i=1:numel(reactantProduct)
        reactantProductLine=getLineBetweenBlocksUsingSessionID(model,reactionSessionID,reactantProduct(i));
        if isempty(reactantProductLine)
            newReactantProducts(end+1)=reactantProduct(i);%#ok<AGROW>
        else

            if getAttribute(reactantProductLine,'sourceSessionID').value==reactionSessionID
                operations.setAttributeValue(reactantProductLine,'type','reactantProductLine');
            else
                speciesBlock=model.getEntitiesInMap(reactantProduct(i));
                speciesBlock=getBlockWithUUID(speciesBlock,reactantProductLine.getAttribute('destinationBlockUUID').value);
                createLineBetweenBlocks(operations,reactionBlock,speciesBlock,'reactantProductLine');
            end
        end
    end

    for i=1:numel(expressionSessionID)
        expressionLine=getLineBetweenBlocksUsingSessionID(model,reactionSessionID,expressionSessionID(i));
        if isempty(expressionLine)
            newExpressionLines(end+1)=expressionSessionID(i);%#ok<AGROW>
        else

            if getAttribute(expressionLine,'sourceSessionID').value==reactionSessionID
                operations.setAttributeValue(expressionLine,'type','usageLine');
            else
                speciesBlock=model.getEntitiesInMap(expressionSessionID(i));
                speciesBlock=getBlockWithUUID(speciesBlock,expressionLine.getAttribute('destinationBlockUUID').value);
                createLineBetweenBlocks(operations,reactionBlock,speciesBlock,'usageLine');
            end
        end
    end


    addReactionLinesHelper(operations,model,reactionSessionID,newReactantProducts,newReactants,newProducts,newExpressionLines);


    connections=block.connections;
    allSessionIDs=horzcat(reactants,products,reactantProduct,expressionSessionID);

    for i=1:numel(connections)


        s1=connections(i).getAttribute('sourceSessionID').value;
        s2=connections(i).getAttribute('destinationSessionID').value;


        if(s1==reactionSessionID&&~any(allSessionIDs==s2))||(s2==reactionSessionID&&~any(allSessionIDs==s1))
            operations.destroy(connections(i),false);
        end
    end

end

function block=getBlockWithUUID(blocks,UUID)

    for i=1:numel(blocks)
        if strcmp(blocks(i).uuid,UUID)
            block=blocks(i);
            return;
        end
    end

    if numel(blocks)>0
        block=blocks(1);
    else
        block=[];
    end

end

function showLines(operations,model,obj)

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        updateLines(operations,model,syntax,obj);
    end

end

function sessionIDs=getExpressionSessionIDs(reaction)

    reactants=reaction.Reactants.get({'SessionID'});
    products=reaction.Products.get({'SessionID'});

    reactants=[reactants{:}];
    products=[products{:}];
    allStates=union(reactants,products);


    tokens=parserate(reaction);
    sessionIDs=[];

    for i=1:numel(tokens)
        obj=resolveobject(reaction,tokens{i});
        if~isempty(obj)
            sessionID=obj.SessionID;
            if isa(obj,'SimBiology.Parameter')
                sessionIDs(end+1)=sessionID;%#ok<AGROW>
            elseif isa(obj,'SimBiology.Compartment')
                sessionIDs(end+1)=sessionID;%#ok<AGROW>
            elseif isa(obj,'SimBiology.Species')
                if~ismember(sessionID,allStates)
                    sessionIDs(end+1)=sessionID;%#ok<AGROW>
                end
            end
        end
    end

end

function block=createBlock(operations,model,parent,obj)

    block=SimBiology.web.diagramhandler('createBlock',operations,model,parent,obj);

end

function line=createLine(operations,model,sourceSessionID,destinationSessionID,sourceCloneIndex,destinationCloneIndex,type)

    line=SimBiology.web.diagram.linehandler('createLine',operations,model,sourceSessionID,destinationSessionID,sourceCloneIndex,destinationCloneIndex,type);

end

function createLineBetweenBlocks(operations,sourceBlock,destinationBlock,type)

    SimBiology.web.diagram.linehandler('createLineBetweenBlocks',operations,sourceBlock,destinationBlock,type);

end

function eraseNeedsConfiguration(operations,blocksNeedingConfiguration)

    SimBiology.web.diagramhandler('eraseNeedsConfiguration',operations,blocksNeedingConfiguration);

end

function blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model)

    blocksNeedingConfiguration=SimBiology.web.diagramhandler('findBlocksThatNeedConfiguration',model);

end

function out=getAttributeValue(blocks,property)

    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);

end

function existingLines=getLineBetweenBlocksUsingSessionID(model,block1SessionID,block2SessionID)

    existingLines=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',model,block1SessionID,block2SessionID);

end

function out=isShowLines(model,obj)

    out=SimBiology.web.diagram.utilhandler('isShowLines',model,obj);

end

function out=logical2string(value)

    out=SimBiology.web.diagram.utilhandler('logical2string',value);

end

function positionSingleBlock(operations,model,block,allBlocks,obj,checkForOverlap,speciesBlocks)

    SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,allBlocks,obj,checkForOverlap,speciesBlocks);

end

function setAttributeValue(operations,blocks,property,value)

    SimBiology.web.diagramhandler('setAttributeValue',operations,blocks,property,value);

end
