function out=eventObjhandler(action,varargin)











    out=[];

    switch(action)
    case 'addBlock'
        out=addBlock(varargin{:});
    case 'createLines'
        createLines(varargin{:});
    case 'deleteBlock'
        deleteBlock(varargin{:});
    case 'eventAdded'
        eventAdded(varargin{:});
    case 'eventDeleted'
        eventDeleted(varargin{:});
    case 'eventExpressionStatus'
        eventExpressionStatus(varargin{:});
    case 'eventPropertyChanged'
        eventPropertyChanged(varargin{:});
    case 'propertyChanged'
        propertyChanged(varargin{:});
    case 'updateLines'
        updateLines(varargin{:});
    end

end

function block=addBlock(operations,model,syntaxRoot,obj,checkForOverlap)

    block=createBlock(operations,model,syntaxRoot,obj);
    newCloneBlocks=createLines(operations,model,syntaxRoot,obj);



    if~isempty(newCloneBlocks)
        for i=1:numel(newCloneBlocks)
            positionSingleBlock(operations,model,newCloneBlocks(i),[],obj,checkForOverlap);
        end
    end


    if~isempty(block)
        positionSingleBlock(operations,model,block,[],obj,checkForOverlap);
    end

end

function newCloneBlocks=createLines(operations,model,root,event)




    [lhs,~]=parseeventfcns(event);
    lhs=vertcat(lhs{:});
    out=SimBiology.web.modelhandler('resolveTokens',event,lhs,[],[]);
    sessionIDs=out.sessionIDs;
    newCloneBlocks=[];



    isCloned=mat2str(numel(sessionIDs)>1);
    eventBlock=model.getEntitiesInMap(event.SessionID);

    if isempty(eventBlock)
        return;
    end


    operations.setAttributeValue(eventBlock,'cloned',isCloned);

    for j=1:numel(sessionIDs)
        if j>1

            eventBlock=createBlock(operations,model,root,event);
            operations.setAttributeValue(eventBlock,'cloned',isCloned);
            operations.setAttributeValue(eventBlock,'cloneIndex',j);

            if isempty(newCloneBlocks)
                newCloneBlocks=eventBlock;
            else
                newCloneBlocks(end+1)=eventBlock;%#ok<AGROW>
            end
        end


        createLine(operations,model,event.SessionID,sessionIDs(j),j,1,'lhsLine');
    end

end

function deleteBlock(eventBlocks,modelSessionID,type)

    sessionIds=getSessionIDs(eventBlocks);

    for i=1:numel(eventBlocks)
        if~eventBlocks(i).isValid
            continue;
        end

        if strcmp(eventBlocks(i).getAttribute('cloned').value,'true')
            deleteLinesFromDiagram(modelSessionID,{eventBlocks(i).connections.uuid});
        else
            SimBiology.web.modelhandler('deleteObject',struct('modelSessionID',modelSessionID,'objectIDs',sessionIds(i),'type',type,'forceDelete',true));
        end
    end

end

function eventAdded(operations,model,event)



    if~isempty(model)&&model.hasDiagramSyntax
        params=getParametersToAdd(event);
        syntax=model.getDiagramSyntax;

        for i=1:numel(params)
            block=model.getEntitiesInMap(params(i).SessionID);

            if isempty(block)
                block=createBlock(operations,model,syntax.root,params(i));
                positionSingleBlock(operations,model,block,[],params(i),true);

                if params(i).Constant
                    setAttributeValue(operations,block,'constant','true');
                end
            end

            operations.setAttributeValue(block,'event','true');
        end
    end

end

function eventDeleted(operations,syntax,model,event)



    refreshDueToEventChange(operations,model,model.Parameters,model.Rules,setdiff(model.Events,event),syntax);

end

function eventExpressionStatus(operations,syntax,model)

    refreshDueToEventChange(operations,model,model.Parameters,model.Rules,model.Events,syntax);

end

function eventPropertyChanged(operations,model,syntax)

    refreshDueToEventChange(operations,model,model.Parameters,model.Rules,model.Events,syntax);

end

function refreshDueToEventChange(operations,model,params,rules,events,syntax)


    expressionParams=getAllParametersToAdd(rules,events);
    expressionSessionIDs=get(expressionParams,{'SessionID'});
    expressionSessionIDs=[expressionSessionIDs{:}];


    for i=1:numel(params)
        next=params(i).SessionID;
        block=model.getEntitiesInMap(next);

        if~isempty(block)
            if~ismember(next,expressionSessionIDs)
                deleteBlocks(operations,model,block);
            else
                operations.setAttributeValue(block,'event','false');
            end
        end
    end


    params=getParametersToAdd(events);
    for i=1:numel(params)
        block=model.getEntitiesInMap(params(i).SessionID);
        if isempty(block)
            block=createBlock(operations,model,syntax.root,params(i));
            positionSingleBlock(operations,model,block,[],params(i),true);
        end
        operations.setAttributeValue(block,'event','true');
    end

end

function propertyChanged(operations,model,syntax,obj,input)


    if strcmp(input.property,'EventFcns')
        updateLines(operations,syntax,model,obj);
    elseif strcmp(input.property,'Name')
        handleNamePropertyChanged(operations,model,input)
    end

end

function updateLines(operations,syntax,model,obj)


    blocks=model.getEntitiesInMap(obj.SessionID);



    idx=arrayfun(@(x)x.hasAttribute('needsConfiguration'),blocks);
    block=blocks(idx);



    if isempty(block)
        [lhs,~]=parseeventfcns(obj);
        lhs=vertcat(lhs{:});
        out=SimBiology.web.modelhandler('resolveTokens',obj,lhs,[],[]);
        eventLHSSessionIDs=out.sessionIDs;








        for i=1:numel(blocks)

            lhsLines=getLHSLines(blocks(i));



            for j=1:numel(lhsLines)
                lhsSessionID=lhsLines{j}.getAttribute('destinationSessionID').value;



                idx=ismember(eventLHSSessionIDs,lhsSessionID);
                if~any(idx)
                    operations.destroy(lhsLines{j},false);
                else

                    eventLHSSessionIDs(find(ismember(eventLHSSessionIDs,lhsSessionID),1))=[];
                end
            end
        end



        addDeleteEventBlocksForPropertyChange(operations,syntax,model,obj,blocks,eventLHSSessionIDs);
    else

        blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model);
        eraseNeedsConfiguration(operations,blocksNeedingConfiguration);


        types=getAttributeValue(blocksNeedingConfiguration,'type');
        sourceBlock=blocksNeedingConfiguration(ismember(types,'event'));
        destinationBlock=blocksNeedingConfiguration(~ismember({blocksNeedingConfiguration.uuid},sourceBlock.uuid));


        isCloned=numel(blocksNeedingConfiguration)>1;

        if isCloned


            clonedIndex=SimBiology.web.diagram.clonehandler('findCloneIndex',blocks);
            clonedBlock=createCloneAndAddLineHelper(operations,model,syntax,obj,isCloned,clonedIndex,destinationBlock);
            positionSingleBlock(operations,model,clonedBlock,[],obj,true);
        else

            createLineBetweenBlocks(operations,sourceBlock,destinationBlock,'lhsLine');
        end
    end

end

function addDeleteEventBlocksForPropertyChange(operations,syntax,model,eventObj,eventBlocks,eventLHSSessionIDs)


    numEventBlocks=numel(eventBlocks);
    isCloned=numEventBlocks>1;
    newClonedBlocks={};

    for i=1:numel(eventLHSSessionIDs)
        destinationBlock=model.getEntitiesInMap(eventLHSSessionIDs(i));
        if~isempty(destinationBlock)

            destinationBlock=destinationBlock(1);

            if isCloned


                newClonedBlocks{end+1}=createCloneAndAddLineHelper(operations,model,syntax,eventObj,isCloned,numEventBlocks+i,destinationBlock);%#ok<AGROW>
            else


                createLineBetweenBlocks(operations,eventBlocks(1),destinationBlock,'lhsLine');
            end
        end
    end


    for i=1:numel(newClonedBlocks)
        positionSingleBlock(operations,model,newClonedBlocks{i},[],eventObj,true);
    end


    allEventBlocks=model.getEntitiesInMap(eventObj.SessionID);
    isCloned=numel(allEventBlocks)>1;



    if isCloned
        for i=1:numel(allEventBlocks)
            if isempty(getLHSLines(allEventBlocks(i)))
                deleteBlocksFalse(operations,model,allEventBlocks(i));
            end
        end
    end


    allEventBlocks=model.getEntitiesInMap(eventObj.SessionID);
    for i=1:numel(allEventBlocks)
        operations.setAttributeValue(allEventBlocks(i),'cloneIndex',i);
        operations.setAttributeValue(allEventBlocks(i),'cloned',logical2string(isCloned));
    end

end

function clonedEventBlock=createCloneAndAddLineHelper(operations,model,syntax,eventObj,isCloned,cloneIndex,destinationBlock)

    clonedEventBlock=createBlock(operations,model,syntax.root,eventObj);
    operations.setAttributeValue(clonedEventBlock,'cloned',logical2string(isCloned));
    operations.setAttributeValue(clonedEventBlock,'cloneIndex',cloneIndex);


    createLineBetweenBlocks(operations,clonedEventBlock,destinationBlock,'lhsLine');

end

function handleNamePropertyChanged(operations,model,input)

    blocks=model.getEntitiesInMap(input.obj);
    setAttributeValue(operations,blocks,lower(input.property),input.value);

end

function out=getSessionIDs(blocks)

    out=getAttributeValue(blocks,'sessionID');

    if iscell(out)
        out=[out{:}];
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

function deleteBlocks(operations,model,blocks)

    SimBiology.web.diagramhandler('deleteBlocks',operations,model,blocks);

end

function deleteBlocksFalse(operations,model,blocks)

    SimBiology.web.diagramhandler('deleteBlocksFalse',operations,model,blocks);

end

function deleteLinesFromDiagram(modelSessionID,lines)

    SimBiology.web.diagram.linehandler('deleteLinesFromDiagram',modelSessionID,lines);

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

function lhsLines=getLHSLines(block)

    lhsLines=SimBiology.web.diagram.linehandler('getLHSLines',block);

end

function params=getParametersToAdd(events)

    params=SimBiology.web.diagram.utilhandler('getParametersToAdd',[],events);

end

function params=getAllParametersToAdd(rules,events)

    params=SimBiology.web.diagram.utilhandler('getParametersToAdd',rules,events);

end

function positionSingleBlock(operations,model,block,allBlocks,obj,checkForOverlap)

    SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,allBlocks,obj,checkForOverlap);

end

function out=logical2string(value)

    out=SimBiology.web.diagram.utilhandler('logical2string',value);

end

function setAttributeValue(operations,blocks,property,value)

    SimBiology.web.diagramhandler('setAttributeValue',operations,blocks,property,value);
end
