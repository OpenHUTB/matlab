function out=rulehandler(action,varargin)











    out=[];

    switch(action)
    case 'addBlock'
        out=addBlock(varargin{:});
    case 'createLines'
        createLines(varargin{:});
    case 'objectDeleted'
        objectDeleted(varargin{:});
    case 'propertyChanged'
        propertyChanged(varargin{:});
    case 'showLines'
        showLines(varargin{:});
    end

end

function block=addBlock(operations,model,syntaxRoot,rule,needAutomaticLayout,checkForOverlap)

    block=createBlock(operations,model,syntaxRoot,rule);


    if~isempty(block)
        configureConnections(operations,model,syntaxRoot,rule,block,needAutomaticLayout,checkForOverlap);
    end

end

function createLines(operations,model,rule)



    updateRuleLinesOnBlock(operations,model,rule);

end

function showLines(operations,model,rule)

    updateRuleLinesOnBlock(operations,model,rule);

end

function updateRuleLinesOnBlock(operations,model,rule)

    lhs=getLHSSessionID(rule);
    rhs=[];
    lhsLineToAdd=[];
    rhsLineToAdd=[];

    if isShowLines(model,rule)
        rhs=getExpressionSessionIDs(rule);
        rhs=setdiff(rhs,lhs);
    end







    if~isempty(lhs)
        line=getLineBetweenBlocksUsingSessionID(model,rule.SessionID,lhs);
        if isempty(line)
            lhsLineToAdd(end+1)=lhs;
        else
            operations.setAttributeValue(line,'type','lhsLine');
        end
    end

    for i=1:numel(rhs)
        line=getLineBetweenBlocksUsingSessionID(model,rule.SessionID,rhs(i));
        if isempty(line)
            rhsLineToAdd(end+1)=rhs(i);%#ok<AGROW>
        else
            operations.setAttributeValue(line,'type','usageLine');
        end
    end


    for i=1:numel(lhsLineToAdd)
        createLine(operations,model,rule.SessionID,lhsLineToAdd(i),1,1,'lhsLine');
    end

    for i=1:numel(rhsLineToAdd)
        createLine(operations,model,rule.SessionID,rhsLineToAdd(i),1,1,'usageLine');
    end


    block=model.getEntitiesInMap(rule.SessionID);
    connections=block.connections;
    allSessionIDs=horzcat(lhs,rhs);

    for i=1:numel(connections)


        s1=connections(i).getAttribute('sourceSessionID').value;
        s2=connections(i).getAttribute('destinationSessionID').value;


        if(s1==rule.SessionID&&~any(allSessionIDs==s2))||(s2==rule.SessionID&&~any(allSessionIDs==s1))
            operations.destroy(connections(i),false);
        end
    end

end

function objectDeleted(operations,model,rule)





    lhsLine=getLineOfType(model,rule.sessionID,'lhsLine');
    oldLHSObj=[];
    oldLHSBlock=[];

    if~isempty(lhsLine)
        oldLHS=lhsLine.getAttribute('sourceSessionID').value;
        if(oldLHS==rule.SessionID)
            oldLHS=lhsLine.getAttribute('destinationSessionID').value;
        end

        oldLHSObj=sbioselect(rule.Parent,'SessionID',oldLHS);
        oldLHSBlock=model.getEntitiesInMap(oldLHS);
    end

    removeLHSBlock(operations,model,oldLHSObj,oldLHSBlock,rule);

end

function propertyChanged(operations,model,syntax,rule,input)

    if strcmp(input.property,'RuleType')
        handleRuleTypePropertyChanged(operations,model,syntax,rule,input);
        return;
    end

    if~isSupportedRuleType(rule.RuleType)
        return;
    end

    if strcmp(input.property,'Name')
        handleNamePropertyChanged(operations,model,input);
        return;
    end

    if strcmp(input.property,'Active')
        handleActivePropertyChanged(operations,model,rule);
        return;
    end


    if~strcmp(input.property,'Rule')
        return;
    end


    block=model.getEntitiesInMap(rule.SessionID);


    lhsLine=getLineOfType(model,rule.sessionID,'lhsLine');
    oldLHSObj=[];
    oldLHSBlock=[];

    if~isempty(lhsLine)
        oldLHS=lhsLine.getAttribute('sourceSessionID').value;
        if(oldLHS==rule.SessionID)
            oldLHS=lhsLine.getAttribute('destinationSessionID').value;
        end

        oldLHSObj=sbioselect(rule.Parent,'SessionID',oldLHS);
        oldLHSBlock=model.getEntitiesInMap(oldLHS);
    end

    if~isempty(block)


        if~block.hasAttribute('needsConfiguration')
            configureConnections(operations,model,syntax.root,rule,block,false,false);
        else



            removeLHSLines(operations,block);


            blocksNeedingConfiguration=findBlocksAndEraseNeedsConfiguration(operations,model);
            sourceBlock=block;
            destinationBlock=blocksNeedingConfiguration(~ismember({blocksNeedingConfiguration.uuid},block.uuid));

            createLineBetweenBlocks(operations,sourceBlock,destinationBlock,'lhsLine');
        end

        removeLHSBlock(operations,model,oldLHSObj,oldLHSBlock,[]);
    end

end

function configureConnections(operations,model,syntaxRoot,rule,ruleBlock,needAutomaticLayout,checkForOverlap)


    [needLHSBlock,lhsObj]=isLHSBlockNeeded(model,rule);

    if needLHSBlock

        if needAutomaticLayout
            positionSingleBlock(operations,model,ruleBlock,[],rule,checkForOverlap);
        end


        lhsBlock=addLHSBlock(operations,model,syntaxRoot,rule,lhsObj);


        createLines(operations,model,rule);


        positionSingleBlock(operations,model,lhsBlock,[],lhsObj,checkForOverlap);
    else


        createLines(operations,model,rule);


        if needAutomaticLayout
            positionSingleBlock(operations,model,ruleBlock,[],rule,checkForOverlap);
        end
    end

end

function[flag,lhsObj]=isLHSBlockNeeded(model,rule)
    flag=false;
    lhsObj=parserule(rule);
    if~isempty(lhsObj)
        lhsObj=resolveobject(rule,lhsObj{1});
        if~isempty(lhsObj)
            block=model.getEntitiesInMap(lhsObj.SessionID);
            flag=isempty(block);
        end
    end

end

function block=addLHSBlock(operations,model,syntaxRoot,rule,lhsObj)


    block=createBlock(operations,model,syntaxRoot,lhsObj);

    if strcmp(rule.RuleType,'repeatedAssignment')
        setAttributeValue(operations,block,'repeatAssignment','true');
    end

    if lhsObj.Constant
        setAttributeValue(operations,block,'constant','true');
    end

end

function removeLHSBlock(operations,model,oldLHSObj,oldLHSBlock,objToExclude)

    keepBlock=keepParameterBlock(oldLHSObj,objToExclude);
    if~keepBlock
        deleteBlocks(operations,model,oldLHSBlock);
    end

end

function handleNamePropertyChanged(operations,model,input)

    blocks=model.getEntitiesInMap(input.obj);
    setAttributeValue(operations,blocks,lower(input.property),input.value);

end

function handleActivePropertyChanged(operations,model,rule)

    block=model.getEntitiesInMap(rule.SessionID);
    setAttributeValue(operations,block.connections,'active',logical2string(~rule.Active));

end

function handleRuleTypePropertyChanged(operations,model,syntax,rule,input)


    blocks=model.getEntitiesInMap(input.obj);
    if~isempty(blocks)


        objectDeleted(operations,model,rule);
        deleteBlocks(operations,model,blocks)
    end


    if isSupportedRuleType(rule.RuleType)
        addBlock(operations,model,syntax.root,rule,true,false);
    end

end

function sessionID=getLHSSessionID(rule)

    token=parserule(rule);
    sessionID=[];

    if~isempty(token)
        obj=resolveobject(rule,token{1});
        if~isempty(obj)
            sessionID=obj.SessionID;
        end
    end

end

function sessionIDs=getExpressionSessionIDs(rule)


    [~,tokens]=parserule(rule);
    sessionIDs=[];

    for i=1:numel(tokens)
        obj=resolveobject(rule,tokens{i});
        if~isempty(obj)
            sessionIDs(end+1)=obj.SessionID;%#ok<AGROW>
        end
    end

end

function blocksNeedingConfiguration=findBlocksAndEraseNeedsConfiguration(operations,model)

    blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model);
    eraseNeedsConfiguration(operations,blocksNeedingConfiguration);

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

function eraseNeedsConfiguration(operations,blocksNeedingConfiguration)

    SimBiology.web.diagramhandler('eraseNeedsConfiguration',operations,blocksNeedingConfiguration);

end

function blocksNeedingConfiguration=findBlocksThatNeedConfiguration(model)

    blocksNeedingConfiguration=SimBiology.web.diagramhandler('findBlocksThatNeedConfiguration',model);

end

function existingLines=getLineBetweenBlocksUsingSessionID(model,block1SessionID,block2SessionID)

    existingLines=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',model,block1SessionID,block2SessionID);

end

function line=getLineOfType(model,sessionID,type)

    line=SimBiology.web.diagram.linehandler('getLineOfType',model,sessionID,type);

end

function out=isShowLines(model,obj)

    out=SimBiology.web.diagram.utilhandler('isShowLines',model,obj);

end

function out=isSupportedRuleType(type)

    out=SimBiology.web.diagramhandler('isSupportedRuleType',type);

end

function out=logical2string(value)

    out=SimBiology.web.diagram.utilhandler('logical2string',value);

end

function out=keepParameterBlock(param,objToExclude)

    out=SimBiology.web.diagram.utilhandler('keepParameterBlock',param,objToExclude);

end

function positionSingleBlock(operations,model,block,allBlocks,obj,checkForOverlap)

    SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,allBlocks,obj,checkForOverlap);

end

function removeLHSLines(operations,blocks)

    SimBiology.web.diagram.linehandler('removeLHSLines',operations,blocks);

end

function setAttributeValue(operations,blocks,property,value)

    SimBiology.web.diagramhandler('setAttributeValue',operations,blocks,property,value);
end
