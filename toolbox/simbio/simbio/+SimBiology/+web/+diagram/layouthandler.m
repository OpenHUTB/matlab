function out=layouthandler(action,varargin)











    out={action};

    switch(action)
    case 'getBlockAbsolutePosition'
        out=getBlockAbsolutePosition(varargin{:});
    case 'getDiagramRectangle'
        out=getDiagramRectangle(varargin{:});
    case 'layoutDiagram'
        layoutDiagram(varargin{:});
    case 'layoutDiagramHelper'
        layoutDiagramHelper(varargin{:});
    case 'layoutCompartment'
        layoutCompartment(varargin{:});
    case 'reparentBlocks'
        reparentBlocks(varargin{:});
    case 'reparentAllBlocks'
        reparentAllBlocks(varargin{:});
    end

end

function layoutDiagram(model,syntax,operations,inputs)

    blocks=model.getAllEntitiesInMap;
    layoutDiagramUndoHelper(model,syntax,operations,inputs,blocks)

end

function layoutDiagramUndoHelper(model,syntax,operations,inputs,blocks)

    transaction=SimBiology.Transaction.create(model);

    [currentValue,newValue]=layoutDiagramHelper(model,syntax,operations,inputs,blocks);

    transaction.push(@()SimBiology.web.diagram.undo.positionLambda(model,currentValue,newValue));
    transaction.commit();

end

function[currentValue,newValue]=layoutDiagramHelper(model,syntax,operations,inputs,blocks)


    currentValue=[];
    newValue=[];


    adjacencyInfo=getModelAdjacencyInfo(model);
    newCompartmentSizeMap=containers.Map('KeyType','double','ValueType','any');
    currentCompartmentSizeMap=containers.Map('KeyType','double','ValueType','any');

    if inputs.setCompartmentSize


        topLevelCompartments=sbioselect(model.Compartments,'Where','Owner','==',[]);
        for i=1:numel(topLevelCompartments)
            estimateCompartmentSize(topLevelCompartments(i),newCompartmentSizeMap);
        end


        for i=1:numel(model.Compartments)
            compBlock=model.getEntitiesInMap(model.Compartments(i).SessionID);


            currentSize=compBlock.getSize;
            currentCompartmentSizeMap(model.Compartments(i).SessionID)=[currentSize.width,currentSize.height];


            size=newCompartmentSizeMap(model.Compartments(i).SessionID);
            operations.setSize(compBlock,size(1),size(2));
        end
    else
        newCompartmentSizeMap=containers.Map('KeyType','double','ValueType','any');
        for i=1:numel(model.Compartments)
            compSessionID=model.Compartments(i).SessionID;
            compBlock=model.getEntitiesInMap(compSessionID);
            compSize=compBlock.getSize;

            currentCompartmentSizeMap(model.Compartments(i).SessionID)=[compSize.width,compSize.height];
            newCompartmentSizeMap(model.Compartments(i).SessionID)=[compSize.width,compSize.height];
        end
    end

    if~isempty(blocks)

        [currentValue,newValue]=layoutTopLevelCompartments(model,operations,adjacencyInfo,newCompartmentSizeMap,currentCompartmentSizeMap,inputs.layoutType);


        compartments=model.Compartments;
        numCompartments=numel(compartments);
        c1=cell(1,numCompartments);
        n1=cell(1,numCompartments);
        for i=1:numCompartments

            [c1{i},n1{i}]=layoutIndividualCompartment(operations,compartments(i),model,adjacencyInfo,inputs.layoutType);
        end
        currentValue=horzcat(currentValue,c1{:});
        newValue=horzcat(newValue,n1{:});


        currentState=cell(1,numel(blocks));
        for i=1:numel(blocks)
            if~strcmp(blocks(i).type,'compartment')&&~strcmp(blocks(i).type,'species')
                sessionID=blocks(i).getAttribute('sessionID').value;
                parent=getDiagramSessionID(syntax,blocks(i));
                currentState{i}=getCurrentPositionStateForUndo(sessionID,blocks(i),parent);
            end
        end


        reparentAllExpressionsToRoot(operations,syntax,blocks);


        layoutExpressionBlocks(operations,model);


        reparentBlocks(operations,model,blocks,[]);


        newState=cell(1,numel(blocks));
        for i=1:numel(blocks)
            if~strcmp(blocks(i).type,'compartment')&&~strcmp(blocks(i).type,'species')
                sessionID=blocks(i).getAttribute('sessionID').value;
                parent=getDiagramSessionID(syntax,blocks(i));
                newState{i}=getCurrentPositionStateForUndo(sessionID,blocks(i),parent);
            end
        end

        currentState=[currentState{:}];
        newState=[newState{:}];
        currentValue=horzcat(currentValue,currentState);
        newValue=horzcat(newValue,newState);
    end


end

function[currentValue,newValue]=layoutTopLevelCompartments(model,operations,adjacencyInfo,newCompartmentSizeMap,currentCompartmentSizeMap,layoutType)


    currentValue={};
    newValue={};

    topLevelCompartments=sbioselect(model.Compartments,'Where','Owner','==',[]);

    if isempty(topLevelCompartments)
        currentValue=[currentValue{:}];
        newValue=[newValue{:}];
        return;
    end

    numTopLevelCompartments=numel(topLevelCompartments);
    if numTopLevelCompartments==1

        block=model.getEntitiesInMap(topLevelCompartments(1).SessionID);
        currentValue=getCurrentPositionStateForUndo(topLevelCompartments(1).SessionID,block,[]);
        newValue=getNewPositionStateForUndo(topLevelCompartments(1).SessionID,block,100,100,[]);
        currentValue.size=currentCompartmentSizeMap(topLevelCompartments(1).SessionID);
        newValue.size=newCompartmentSizeMap(topLevelCompartments(1).SessionID);


        operations.setPosition(block,100,100);

        return;
    end


    reactionIndex=(adjacencyInfo.mask==0);
    speciesIndex=(adjacencyInfo.mask==1);

    upperMatrix=adjacencyInfo.matrix(speciesIndex,reactionIndex);
    lowerMatrix=adjacencyInfo.matrix(reactionIndex,speciesIndex);
    stoich=upperMatrix+lowerMatrix';


    cNames=get(topLevelCompartments,{'name'});
    speciesNames=adjacencyInfo.names(adjacencyInfo.mask==1);

    collapsedMatrixParts=cell(1,numTopLevelCompartments);
    for i=1:numTopLevelCompartments

        idx=cellfun(@(x)startsWith(x,cNames{i}),speciesNames);
        collapsedMatrixParts{i}=sum(stoich(idx,:),1);
    end
    collapsedMatrix=vertcat(collapsedMatrixParts{:});


    collapsedMatrix=collapsedMatrix*collapsedMatrix';


    collapsedMatrix=collapsedMatrix-diag(diag(collapsedMatrix));


    g=graph(collapsedMatrix,cNames);


    fig=figure('visible',false);
    deleteCleanup=onCleanup(@()delete(fig));
    ax=axes(fig);
    plotHandle=plot(ax,g,'layout',layoutType);


    x=plotHandle.XData;
    y=plotHandle.YData;



    x=x-min(x);
    y=y-min(y);


    radii=zeros(1,numTopLevelCompartments);
    for i=1:numTopLevelCompartments
        size=newCompartmentSizeMap(topLevelCompartments(i).SessionID);
        radii(i)=hypot(size(1)/2,size(2)/2);
    end


    d=pdist([x',y']);
    d=squareform(d);

    radiiSum=radii+radii';


    scaleBy=max(triu(radiiSum./d,1),[],'all')+100;

    x=(x*scaleBy);
    y=(y*scaleBy);

    assert(numel(x)==numTopLevelCompartments);
    assert(numel(y)==numTopLevelCompartments);


    for i=1:numTopLevelCompartments
        block=model.getEntitiesInMap(topLevelCompartments(i).SessionID);
        size=newCompartmentSizeMap(topLevelCompartments(i).SessionID);
        if~isempty(block)
            x(i)=x(i)-size(1)/2;
            y(i)=y(i)-size(2)/2;
        end
    end


    x=x-min(x)+100;
    y=y-min(y)+100;

    currentValue=cell(numTopLevelCompartments,1);
    newValue=cell(numTopLevelCompartments,1);
    for i=1:numTopLevelCompartments
        block=model.getEntitiesInMap(topLevelCompartments(i).SessionID);
        if~isempty(block)

            cValue=getCurrentPositionStateForUndo(topLevelCompartments(i).SessionID,block,[]);
            nValue=getNewPositionStateForUndo(topLevelCompartments(i).SessionID,block,x(i),y(i),[]);
            cValue.size=currentCompartmentSizeMap(topLevelCompartments(i).SessionID);
            nValue.size=newCompartmentSizeMap(topLevelCompartments(i).SessionID);
            currentValue{i}=cValue;
            newValue{i}=nValue;


            operations.setPosition(block,x(i),y(i));
        end
    end

    currentValue=[currentValue{:}];
    newValue=[newValue{:}];

end

function layoutCompartment(inputs)

    model=inputs.model;

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)layoutCompartmentUndoHelper(operations,inputs));
    end

end

function layoutCompartmentUndoHelper(operations,inputs)

    model=inputs.model;
    transaction=SimBiology.Transaction.create(model);

    [currentValue,newValue]=layoutCompartmentOperations(operations,inputs);

    transaction.push(@()SimBiology.web.diagram.undo.positionLambda(model,currentValue,newValue));
    transaction.commit();

end

function[currentValue,newValue]=layoutCompartmentOperations(operations,inputs)


    model=inputs.model;
    compartment=sbioselect(model,'SessionID',inputs.sessionID);


    adjacencyInfo=getModelAdjacencyInfo(model);


    syntax=model.getDiagramSyntax;
    blocks=model.getAllEntitiesInMap;

    [currentValue,newValue]=layoutIndividualCompartment(operations,compartment,model,adjacencyInfo,inputs.layout);


    compBlock=model.getEntitiesInMap(compartment.SessionID);


    numBlocks=numel(blocks);
    expressionCurrent=cell(1,numBlocks);
    expressionNew=cell(1,numBlocks);

    for i=1:numBlocks
        block=blocks(i);

        if ismember(block.type,{'reaction','rate','repeatedAssignment'})




            if strcmp(block.diagram.uuid,compBlock.subdiagram.uuid)&&~isempty(block.connections)

                modelComponent=sbioselect(model,'SessionID',block.getAttribute('sessionID').value);


                expressionCurrent{i}=getCurrentPositionStateForUndo(modelComponent.SessionID,block,compartment.SessionID);


                reparentAllExpressionsToRoot(operations,syntax,block);


                positionSingleBlock(operations,model,block,blocks,modelComponent,false,[]);


                parent=getDiagramSessionID(syntax,block);
                expressionNew{i}=getCurrentPositionStateForUndo(modelComponent.SessionID,block,parent);
            end
        end
    end

    expressionCurrent=[expressionCurrent{:}];
    expressionNew=[expressionNew{:}];
    currentValue=horzcat(currentValue,expressionCurrent);
    newValue=horzcat(newValue,expressionNew);

end

function[currentValue,newValue]=layoutIndividualCompartment(operations,compartment,model,adjacencyInfo,layoutType)


    currentValue={};
    newValue={};


    compartmentBlock=model.getEntitiesInMap(compartment.SessionID);
    if isempty(compartmentBlock)
        currentValue=[currentValue{:}];
        newValue=[newValue{:}];
        return;
    end


    numSpecies=numel(compartment.Species);


    [adj,speciesSessionIds]=splitAdjacencyMatrix(model,compartment,adjacencyInfo);

    if isempty(adj)


        adj=ones(numSpecies,numSpecies);
    end



    maxSpeciesBlockSize=struct("height",0,"width",0);
    totalNumSpeciesBlocks=0;
    for i=1:numel(speciesSessionIds)
        blocks=model.getEntitiesInMap(speciesSessionIds(i));
        numBlocks=numel(blocks);
        if numBlocks>1




            adj=[adj(1:totalNumSpeciesBlocks,:);...
            repmat(adj(totalNumSpeciesBlocks+1,:),numBlocks,1);...
            adj(totalNumSpeciesBlocks+2:end,:)];
            adj=[adj(:,1:totalNumSpeciesBlocks),...
            repmat(adj(:,totalNumSpeciesBlocks+1),1,numBlocks),...
            adj(:,totalNumSpeciesBlocks+2:end)];
        end
        for j=1:numBlocks
            blockSize=getSize(blocks(j));
            maxSpeciesBlockSize.height=max(maxSpeciesBlockSize.height,blockSize.height);
            maxSpeciesBlockSize.width=max(maxSpeciesBlockSize.width,blockSize.width);
        end
        totalNumSpeciesBlocks=totalNumSpeciesBlocks+numBlocks;
    end


    if~isempty(model.Reactions)
        upperMatrix=adj(1:totalNumSpeciesBlocks,totalNumSpeciesBlocks+1:end);
        lowerMatrix=adj(totalNumSpeciesBlocks+1:end,1:totalNumSpeciesBlocks);
        adj=upperMatrix+lowerMatrix';


        adj=adj*adj';
    end


    adj=adj-diag(diag(adj));


    g=graph(adj);


    fig=figure('visible',false);
    deleteCleanup=onCleanup(@()delete(fig));
    ax=axes(fig);
    plotHandle=plot(ax,g,'layout',layoutType);


    x=plotHandle.XData;
    y=plotHandle.YData;

    if~isempty(x)

        x=rescaleHelper(x);
        y=rescaleHelper(y);
    end


    compSize=compartmentBlock.getSize();

    margin=20;







    requiredAreaForNonCompartments=struct("height",2*totalNumSpeciesBlocks*maxSpeciesBlockSize.height,...
    "width",2*totalNumSpeciesBlocks*maxSpeciesBlockSize.width);
    if totalNumSpeciesBlocks>0


        requiredAreaForNonCompartments.height=requiredAreaForNonCompartments.height+2*margin;
        requiredAreaForNonCompartments.width=requiredAreaForNonCompartments.width+2*margin;
    end



    subCompartments=compartment.Compartments;

    numSubCompartments=numel(subCompartments);
    for i=numSubCompartments:-1:1
        subCompartmentBlocks(i)=model.getEntitiesInMap(subCompartments(i).SessionID);
        subCompSize(i)=subCompartmentBlocks(i).getSize();
    end
    top=margin;
    left=requiredAreaForNonCompartments.width+margin;
    if numSubCompartments>0

        maxSubCompWidth=max([subCompSize.width]);
        left=max(left,compSize.width-margin-maxSubCompWidth);
    end
    requiredArea=requiredAreaForNonCompartments;
    currentValue=cell(1,numSubCompartments);
    newValue=cell(1,numSubCompartments);
    for i=1:numSubCompartments


        currentValue{i}=getCurrentPositionStateForUndo(subCompartments(i).SessionID,subCompartmentBlocks(i),[]);
        newValue{i}=getNewPositionStateForUndo(subCompartments(i).SessionID,subCompartmentBlocks(i),left,top,[]);



        operations.setPosition(subCompartmentBlocks(i),left,top);
        requiredArea.width=max(requiredArea.width,left+subCompSize(i).width+margin);
        requiredArea.height=max(requiredArea.height,top+subCompSize(i).height+margin);

        top=top+subCompSize(i).height+margin;

    end
    if requiredArea.width>compSize.width||requiredArea.height>compSize.height
        requiredArea.height=max(requiredArea.height,compSize.height);
        requiredArea.width=max(requiredArea.width,compSize.width);


        currentValue{end+1}=getCurrentSizeStateForUndo(compartment.SessionID,compartmentBlock);
        newValue{end+1}=getNewSizeStateForUndo(compartment.SessionID,compartmentBlock,requiredArea.width,requiredArea.height);

        operations.setSize(compartmentBlock,requiredArea.width,requiredArea.height);

        parentCompartment=compartment.Owner;
        if isempty(parentCompartment)
            parentBlock=[];
        else
            parentBlock=model.getEntitiesInMap(parentCompartment.SessionID);
        end
        compPosition=compartmentBlock.getPosition();

        blockRect.x=compPosition.x;
        blockRect.y=compPosition.y;
        blockRect.left=blockRect.x;
        blockRect.top=blockRect.y;
        blockRect.bottom=blockRect.y+requiredArea.height;
        blockRect.right=blockRect.x+requiredArea.width;
        SimBiology.web.diagram.placementhandler("adjustSizesAndShiftDownAndToRight",...
        operations,model,parentBlock,blockRect,compartment.SessionID);
    end





    availableAreaForNonCompartments=requiredAreaForNonCompartments;
    if numel(subCompartments)==0
        compSize=compartmentBlock.getSize();
        availableAreaForNonCompartments.height=max(availableAreaForNonCompartments.height,compSize.height);
        availableAreaForNonCompartments.width=max(availableAreaForNonCompartments.width,compSize.width);
    end



    availableAreaForNonCompartments.height=availableAreaForNonCompartments.height-2*margin-maxSpeciesBlockSize.height;
    availableAreaForNonCompartments.width=availableAreaForNonCompartments.width-2*margin-maxSpeciesBlockSize.width;
    x=margin+availableAreaForNonCompartments.width*x;
    y=margin+availableAreaForNonCompartments.height*y;


    currentSpeciesValues=cell(1,totalNumSpeciesBlocks);
    newSpeciesValues=cell(1,totalNumSpeciesBlocks);
    blockIdx=1;
    for i=1:numel(speciesSessionIds)
        blocks=model.getEntitiesInMap(speciesSessionIds(i));
        for j=1:numel(blocks)
            currentSpeciesValues{blockIdx}=getCurrentPositionStateForUndo(speciesSessionIds(i),blocks(j),[]);
            newSpeciesValues{blockIdx}=getNewPositionStateForUndo(speciesSessionIds(i),blocks(j),x(blockIdx),y(blockIdx),[]);

            operations.setPosition(blocks(j),x(blockIdx),y(blockIdx));
            blockIdx=blockIdx+1;
        end
    end

    currentValue=[currentValue{:},currentSpeciesValues{:}];
    newValue=[newValue{:},newSpeciesValues{:}];

end

function layoutExpressionBlocks(operations,model)


    events=model.Events;
    rules=sbioselect(model.Rules,'RuleType',getSupportedRuleTypes);
    params=SimBiology.web.diagram.utilhandler('getParametersToAdd',rules,events);


    paramBlocks=diagram.interface.Entity.empty;
    for i=numel(params):-1:1
        paramBlocks(i)=model.getEntitiesInMap(params(i).SessionID);
    end
    if~isempty(paramBlocks)
        positionMultipleParameterBlocks(operations,model,paramBlocks);
    end


    for i=1:numel(rules)
        ruleBlock=model.getEntitiesInMap(rules(i).SessionID);


        positionSingleExpressionBlock(operations,model,ruleBlock);
    end


    reactions=model.Reactions;
    for i=1:numel(reactions)
        reactionBlock=model.getEntitiesInMap(reactions(i).SessionID);


        positionSingleReactionBlock(operations,model,reactionBlock,model.Reactions(i),false,[]);
    end

end

function out=getBlockAbsolutePositionForReparenting(model,block)


    pos=block.getPosition;
    out.x=pos.x;
    out.y=pos.y;

    if ismember(block.type,{'compartment','species'})
        parentObjs=SimBiology.web.diagramhandler('getParentObjects',model,block);
        sessionIDs=get(parentObjs,{'SessionID'});
        sessionIDs=[sessionIDs{:}];

        for i=1:numel(sessionIDs)
            parentBlock=model.getEntitiesInMap(sessionIDs(i));
            parentPos=parentBlock.getPosition;
            out.x=out.x+parentPos.x;
            out.y=out.y+parentPos.y;
        end
    end

end

function blockPosition=getBlockAbsolutePosition(model,block)

    pos=block.getPosition();
    blockPosition.x=pos.x;
    blockPosition.y=pos.y;

    syntax=model.getDiagramSyntax();
    subDiagram=block.getParent();
    if subDiagram==syntax.root
        return;
    end

    blockParent=subDiagram.getParent();
    parentPosition=getBlockAbsolutePosition(model,blockParent);
    blockPosition.x=blockPosition.x+parentPosition.x;
    blockPosition.y=blockPosition.y+parentPosition.y;

end

function out=getDiagramRectangle(model,blocksToExclude)

    if nargin==1
        blocksToExclude=[];
    end

    top=inf;
    left=inf;
    bottom=-inf;
    right=-inf;


    topLevelBlocks=model.getDiagramSyntax.root.entities;
    excludeIdx=arrayfun(@(b)any(b==blocksToExclude),topLevelBlocks);
    topLevelBlocks=topLevelBlocks(~excludeIdx);

    if isempty(topLevelBlocks)
        top=0;
        left=0;
        bottom=0;
        right=0;
    else
        for i=1:numel(topLevelBlocks)
            block=topLevelBlocks(i);
            if block.isValid
                size=block.getSize;
                pos=block.getPosition;

                top=min(top,pos.y);
                left=min(left,pos.x);
                right=max(right,pos.x+size.width);
                bottom=max(bottom,pos.y+size.height);
            end
        end
    end

    width=right-left;
    height=bottom-top;
    out=struct('top',top,'left',left,'bottom',bottom,'right',right,'width',width,'height',height);

end

function reparentAllExpressionsToRoot(operations,syntax,blocks)

    expressionBlocks=blocks(arrayfun(@(x)ismember(x.type,getSupportedExpressionTypes),blocks));
    for i=1:numel(expressionBlocks)
        operations.setParent(expressionBlocks(i),syntax.root);
    end

end

function reparentCompartmentsRecursively(operations,model,parentComp)

    childCompartments=parentComp.Compartments;
    if~isempty(childCompartments)

        parentCompBlock=model.getEntitiesInMap(parentComp.SessionID);
        parentAbsPosition=getBlockAbsolutePositionForReparenting(model,parentCompBlock);

        for i=1:numel(childCompartments)

            childCompBlock=model.getEntitiesInMap(childCompartments(i).SessionID);


            operations.setParent(childCompBlock,parentCompBlock.subdiagram);




            childPos=childCompBlock.getPosition;
            operations.setPosition(childCompBlock,childPos.x-parentAbsPosition.x,childPos.y-parentAbsPosition.y);


            if~isempty(childCompartments(i).Compartments)
                reparentCompartmentsRecursively(operations,model,childCompartments(i));
            end
        end
    end

end

function reparentAllBlocks(operations,model)


    topLevelCompartments=sbioselect(model,'Type','Compartment','Where','Owner','==',[]);

    for i=1:numel(topLevelCompartments)
        reparentCompartmentsRecursively(operations,model,topLevelCompartments(i));
    end


    allCompartments=model.Compartments;
    for i=1:numel(allCompartments)

        compBlock=model.getEntitiesInMap(allCompartments(i).SessionID);
        compAbsPosition=getBlockAbsolutePositionForReparenting(model,compBlock);


        species=allCompartments(i).Species;

        for j=1:numel(species)

            speciesBlocks=model.getEntitiesInMap(species(j).SessionID);

            for k=1:numel(speciesBlocks)

                operations.setParent(speciesBlocks(k),compBlock.subdiagram);




                childPos=speciesBlocks(k).getPosition;
                operations.setPosition(speciesBlocks(k),childPos.x-compAbsPosition.x,childPos.y-compAbsPosition.y);
            end
        end
    end


    reparentBlocks(operations,model,[],[]);

end

function reparentBlocks(operations,model,allBlocks,blocksToReparent)






    if isempty(allBlocks)
        allBlocks=model.getAllEntitiesInMap;
    end


    compartmentBlocks=allBlocks(ismember({allBlocks.type},'compartment'));
    [~,idx]=sort(arrayfun(@calcArea,compartmentBlocks));
    compartmentBlocks=compartmentBlocks(idx);


    if~isempty(compartmentBlocks)



        if isempty(blocksToReparent)
            blocksToReparent=allBlocks(arrayfun(@(x)~ismember(x.type,{'species','compartment'}),allBlocks));
        end

        expressionBounds=arrayfun(@getBounds,blocksToReparent,'UniformOutput',false);






        for i=1:numel(compartmentBlocks)
            b1=getBlockAbsolutePositionForReparenting(model,compartmentBlocks(i));
            size=compartmentBlocks(i).getSize;
            compBound=struct('left',b1.x,'top',b1.y,'right',size.width+b1.x,'bottom',size.height+b1.y);

            for j=numel(blocksToReparent):-1:1
                exprBound=expressionBounds{j};
                if rectContains(compBound,exprBound)||rectIntersects(compBound,exprBound)



                    if~strcmp(blocksToReparent(j).uuid,compartmentBlocks(i).uuid)
                        operations.setParent(blocksToReparent(j),compartmentBlocks(i).subdiagram);




                        exprPos=blocksToReparent(j).getPosition;
                        operations.setPosition(blocksToReparent(j),exprPos.x-b1.x,exprPos.y-b1.y);
                    end

                    blocksToReparent(j)=[];
                    expressionBounds(j)=[];
                end
            end
        end
    end

end

function compartmentSizeMap=estimateCompartmentSize(compartment,compartmentSizeMap)


    numSpecies=numel(compartment.Species);


    if isempty(compartment.Compartments)


        x=32*4*sqrt(numSpecies)/0.8;
        x=round(max(250,x),0);


        compartmentSizeMap(compartment.SessionID)=[x,x];
        return;
    end


    for i=1:numel(compartment.Compartments)
        estimateCompartmentSize(compartment.Compartments(i),compartmentSizeMap);
    end



    idx=get(compartment.Compartments,{'SessionID'});



    compSizes=values(compartmentSizeMap,idx);
    totalArea=sum(cellfun(@(x)((x(1)+100)*(x(2)+100)),compSizes));


    totalArea=(totalArea+(36*20*numSpecies))*2;
    x=round(max(500,sqrt(totalArea)));

    compartmentSizeMap(compartment.SessionID)=[x,x];

end

function adjacencyInfo=getModelAdjacencyInfo(model)

    adjacencyInfo=struct;
    if~isempty(model.Reactions)
        [adj,names,mask]=model.getadjacencymatrix();
        adjacencyInfo.matrix=adj;
        adjacencyInfo.names=names;
        adjacencyInfo.mask=mask;
    else
        adjacencyInfo.matrix=[];
        adjacencyInfo.names={};
        adjacencyInfo.mask=[];
    end

end

function[adj,speciesSessionIds]=splitAdjacencyMatrix(model,compartment,adjacencyInfo)



    isMultiCompartment=numel(model.Compartments)>1;

    if~isMultiCompartment
        adj=adjacencyInfo.matrix;
        speciesSessionIds=[compartment.Species.SessionID];
        return;
    end



    compNamePrefix=sprintf('%s.',compartment.Name);
    speciesIdx=cellfun(@(x)startsWith(x,compNamePrefix),adjacencyInfo.names);
    reactionIdx=find(adjacencyInfo.mask==0);

    upper=adjacencyInfo.matrix(speciesIdx,reactionIdx);
    lower=adjacencyInfo.matrix(reactionIdx,speciesIdx);



    adj=antidiag(upper,lower);


    numSpecies=numel(find(speciesIdx));
    zeroHorz=find(all(adj==0));
    zeroHorz=zeroHorz(zeroHorz>numSpecies);

    zeroVert=find(all(adj'==0));
    zeroVert=zeroVert(zeroVert>numSpecies);

    unusedReaction=intersect(zeroHorz,zeroVert);


    if~isempty(adj)

        adj(unusedReaction,:)=[];
        adj(:,unusedReaction)=[];
    end


    speciesSessionIds=[compartment.Species.SessionID];

end

function M=antidiag(A,B)

    [nA,mA]=size(A);
    [nB,mB]=size(B);

    M=sparse(nA+nB,mA+mB);

    M(nA+1:end,1:mB)=B;
    M(1:nA,mB+1:end)=A;

end

function state=getCurrentPositionStateForUndo(sessionID,block,parentSessionID)

    state=getStateTemplateForUndo(sessionID,block,parentSessionID);
    position=block.getPosition;
    state.position=[position.x,position.y];

end

function state=getNewPositionStateForUndo(sessionID,block,x,y,parentSessionID)

    state=getStateTemplateForUndo(sessionID,block,parentSessionID);
    state.position=[x,y];

end

function state=getCurrentSizeStateForUndo(sessionID,block)

    state=getStateTemplateForUndo(sessionID,block,[]);
    size=block.getSize;
    state.size=[size.width,size.height];

end

function state=getNewSizeStateForUndo(sessionID,block,width,height)

    state=getStateTemplateForUndo(sessionID,block,[]);
    state.size=[width,height];

end

function state=getStateTemplateForUndo(sessionID,block,parentSessionID)




    state.sessionID=sessionID;
    state.diagramUUID=block.uuid;
    state.position=[];
    state.size=[];
    state.parent=parentSessionID;

end

function sessionID=getDiagramSessionID(syntax,block)

    parentBlock=syntax.findElement(block.diagram.uuid);
    parentBlock=parentBlock.parentEntity;
    if parentBlock.isValid
        sessionID=parentBlock.getAttribute('sessionID').value;
    else
        sessionID=-1;
    end

end

function positionSingleBlock(operations,model,block,allBlocks,component,varargin)

    SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,allBlocks,component,varargin{:});

end

function positionSingleExpressionBlock(operations,model,block)

    SimBiology.web.diagram.placementhandler('positionSingleExpressionBlock',operations,model,block,false);

end

function positionMultipleParameterBlocks(operations,model,paramBlock)

    SimBiology.web.diagram.placementhandler('positionMultipleParameterBlocks',operations,model,paramBlock);

end

function positionSingleReactionBlock(operations,model,block,reaction,checkForOverlap,speciesBlocks)

    SimBiology.web.diagram.placementhandler('positionSingleReactionBlock',operations,model,block,reaction,checkForOverlap,speciesBlocks);

end

function out=rectContains(rect1,rect2)

    out=rect2.left>rect1.left&&rect2.top>rect1.top&&rect2.bottom<rect1.bottom&&rect2.right<rect1.right;

end

function out=rectIntersects(rect1,rect2)

    out=~(rect1.right<rect2.left||rect2.right<rect1.left||rect1.bottom<rect2.top||rect2.bottom<rect1.top);

end

function out=calcArea(x)

    s=x.getSize;
    out=s.width*s.height;

end

function out=getBounds(x)

    pos=x.getPosition;
    size=x.getSize;
    out=struct('left',pos.x,'top',pos.y,'right',size.width+pos.x,'bottom',size.height+pos.y);

end

function types=getSupportedExpressionTypes

    types=SimBiology.web.diagramhandler('getSupportedExpressionTypes');

end

function types=getSupportedRuleTypes

    types=SimBiology.web.diagramhandler('getSupportedRuleTypes');
end


function rescaledX=rescaleHelper(x)

    rangeX=max(x)-min(x);
    if rangeX<=eps(rangeX)
        rescaledX=repmat(0.5,size(x));
    else
        rescaledX=rescale(x);
    end
end