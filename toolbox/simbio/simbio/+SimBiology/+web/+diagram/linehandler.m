function out=linehandler(action,varargin)











    out=[];

    switch(action)
    case 'createLine'
        out=createLine(varargin{:});
    case 'createLineBetweenBlocks'
        out=createLineBetweenBlocks(varargin{:});
    case 'deleteLinesFromDiagram'
        deleteLinesFromDiagram(varargin{:});
    case 'getLineBetweenBlocks'
        out=getLineBetweenBlocks(varargin{:});
    case 'getLineBetweenBlocksUsingSessionID'
        out=getLineBetweenBlocksUsingSessionID(varargin{:});
    case 'getLHSLines'
        out=getLHSLines(varargin{:});
    case 'getLineOfType'
        out=getLineOfType(varargin{:});
    case 'removeLHSLines'
        removeLHSLines(varargin{:});
    case 'configureLineProperty'
        configureLineProperty(varargin{:});
    case 'getDefaultProperties'
        out=getDefaultProperties;
    end


end

function line=createLine(operations,model,sourceSessionID,destinationSessionID,sourceCloneIndex,destinationCloneIndex,type)

    if iscell(sourceSessionID)
        sourceSessionID=sourceSessionID{1};
    end

    if iscell(destinationSessionID)
        destinationSessionID=destinationSessionID{1};
    end

    line=[];
    sourceBlock=model.getEntitiesInMap(sourceSessionID);
    destinationBlock=model.getEntitiesInMap(destinationSessionID);

    if~isempty(sourceBlock)&&~isempty(destinationBlock)
        sourceBlock=sourceBlock(sourceCloneIndex);
        destinationBlock=destinationBlock(destinationCloneIndex);

        line=createLineBetweenBlocks(operations,sourceBlock,destinationBlock,type);
    end

end

function line=createLineBetweenBlocks(operations,sourceBlock,destinationBlock,type)

    assert(~isempty(sourceBlock)&&~isempty(destinationBlock));

    sourceBlock=sourceBlock(1);
    destinationBlock=destinationBlock(1);


    existingLine=getLineBetweenBlocks(sourceBlock,destinationBlock);
    if~isempty(existingLine)
        props.linecolor=existingLine.getAttribute('linecolor').value;
        props.linewidth=existingLine.getAttribute('linewidth').value;
        operations.destroy(existingLine,false);
    else
        props=getDefaultProperties();
    end


    line=operations.createConnection(sourceBlock,destinationBlock);


    operations.setType(line,'line');
    operations.setAttributeValue(line,'type',type);
    operations.setAttributeValue(line,'sourceSessionID',sourceBlock.getAttribute('sessionID').value);
    operations.setAttributeValue(line,'destinationSessionID',destinationBlock.getAttribute('sessionID').value);

    operations.setAttributeValue(line,'sourceUUID',sourceBlock.getAttribute('uuid').value);
    operations.setAttributeValue(line,'destinationUUID',destinationBlock.getAttribute('uuid').value);

    operations.setAttributeValue(line,'sourceBlockUUID',sourceBlock.uuid);
    operations.setAttributeValue(line,'destinationBlockUUID',destinationBlock.uuid);
    operations.setAttributeValue(line,'fade','none');


    endPointsVisible=strcmp(sourceBlock.getAttribute('visible').value,'true')&&strcmp(destinationBlock.getAttribute('visible').value,'true');
    operations.setAttributeValue(line,'visible',logical2string(endPointsVisible));



    endPointsActive=strcmp(sourceBlock.getAttribute('active').value,'true')||strcmp(destinationBlock.getAttribute('active').value,'true');
    operations.setAttributeValue(line,'active',logical2string(endPointsActive));


    operations.setAttributeValue(line,'linecolor',props.linecolor);
    operations.setAttributeValue(line,'linewidth',props.linewidth);

end

function out=getDefaultProperties



    out.linecolor='rgb(66, 66, 66)';
    out.linewidth=1;

end

function deleteLinesFromDiagram(modelSessionID,lines)

    model=SimBiology.web.modelhandler('getModelFromSessionID',modelSessionID);
    editor=model.getDiagramEditor;
    editorModel=editor.editorModel;

    for i=1:numel(lines)

        diagramLine=editorModel.findElement(lines{i});
        if~isempty(diagramLine)
            sourceSessionID=diagramLine.srcElement.attributes.attributes.getByKey('sessionID').value;
            destinationSessionID=diagramLine.dstElement.attributes.attributes.getByKey('sessionID').value;

            source=sbioselect(model,'SessionID',sourceSessionID);
            destination=sbioselect(model,'SessionID',destinationSessionID);

            if strcmpi(source.Type,'rule')
                SimBiology.web.modelhandler('removeQuantityFromRule',source,destination);
            elseif strcmpi(destination.Type,'rule')
                SimBiology.web.modelhandler('removeQuantityFromRule',destination,source);
            elseif strcmpi(source.Type,'reaction')
                SimBiology.web.modelhandler('removeQuantityFromReaction',source,destination);
            elseif strcmpi(destination.Type,'reaction')
                SimBiology.web.modelhandler('removeQuantityFromReaction',destination,source);
            end
        end
    end

end

function out=getLineBetweenBlocks(block1,block2)


    out=[];


    connections=block1.connections;
    for i=1:numel(connections)
        if strcmp(connections(i).source.uuid,block2.uuid)||strcmp(connections(i).destination.uuid,block2.uuid)
            out=connections(i);
            return;
        end
    end

end

function out=getLineBetweenBlocksUsingSessionID(model,block1SessionID,block2SessionID)


    out=[];


    sourceBlocks=model.getEntitiesInMap(block1SessionID);



    for i=1:numel(sourceBlocks)
        connections=sourceBlocks(i).connections;
        for j=1:numel(connections)
            if connections(j).getAttribute('sourceSessionID').value==block2SessionID||...
                connections(j).getAttribute('destinationSessionID').value==block2SessionID
                out=connections(j);
                return;
            end
        end
    end

end

function out=getLineOfType(model,sessionID,lineType)


    out=[];


    sourceBlocks=model.getEntitiesInMap(sessionID);



    for i=1:numel(sourceBlocks)
        connections=sourceBlocks(i).connections;

        for j=1:numel(connections)
            if strcmp(connections(j).getAttribute('type').value,lineType)
                if isempty(out)
                    out=connections(j);
                else
                    out(end+1)=connections(j);%#ok<AGROW>
                end
            end
        end
    end

end

function out=getLHSLines(block)

    out={};

    connections=block.connections;
    for i=1:numel(connections)
        if strcmpi(connections(i).getAttribute('type').value,'lhsLine')
            out{end+1}=connections(i);%#ok<AGROW>
        end
    end

end

function removeLHSLines(operations,blocks)

    for i=1:numel(blocks)
        connections=blocks(i).connections;
        for j=1:numel(connections)
            if strcmpi(connections(j).getAttribute('type').value,'lhsLine')

                operations.destroy(connections(j),false);
            end
        end
    end

end

function configureLineProperty(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)configureLinePropertyOperations(operations,model,inputs));
    end

end

function configureLinePropertyOperations(operations,model,inputs)

    currentValues={};
    newValues={};
    transaction=SimBiology.Transaction.create(model);

    for i=1:numel(inputs.selection)
        connections=inputs.selection(i).connections;
        line=getLineBetweenBlocksUsingSessionID(model,connections(1),connections(2));
        if~isempty(line)
            currentPropValue=line.getAttribute(inputs.property).value;
            operations.setAttributeValue(line,inputs.property,inputs.value);

            currentValue=struct;
            currentValue.sessionID=connections;
            currentValue.values=struct(inputs.property,currentPropValue);

            newValue=struct;
            newValue.sessionID=connections;
            newValue.values=struct(inputs.property,inputs.value);

            currentValues{end+1}=currentValue;%#ok<AGROW>
            newValues{end+1}=newValue;%#ok<AGROW>
        end
    end


    currentValues=[currentValues{:}];
    newValues=[newValues{:}];

    transaction.push(@()SimBiology.web.diagram.undo.lineAttributeLambda(model,currentValues,newValues));
    transaction.commit();

end

function out=logical2string(value)

    out=SimBiology.web.diagram.utilhandler('logical2string',value);

end
