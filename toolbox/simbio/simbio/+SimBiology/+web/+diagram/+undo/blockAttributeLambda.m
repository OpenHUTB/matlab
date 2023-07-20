function blockAttributeLambda(model,oldValues,newValues)




    if~isempty(model)
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)blockAttributeOperations(operations,model,oldValues));
    end

    redoTransaction=SimBiology.Transaction.create(model);
    redoTransaction.push(@()SimBiology.web.diagram.undo.blockAttributeLambda(model,newValues,oldValues));
    redoTransaction.commit();

end


function blockAttributeOperations(operations,model,values)

    visibleSet=false;

    for i=1:numel(values)
        block=getBlockFromUUID(model,values(i).sessionID,values(i).diagramUUID);
        propStruct=values(i).values;
        props=fieldnames(propStruct);

        for j=1:numel(props)
            property=props{j};
            value=propStruct.(property);

            switch(property)
            case 'visible'
                visibleSet=true;
                SimBiology.web.diagramhandler('configureVisiblePropertyOnBlock',operations,block,value);
            case 'position'
                setPosition(operations,model,block,value);
            case 'lines'
                setExpressionLines(operations,model,block,value)
            otherwise
                operations.setAttributeValue(block,property,value);
            end
        end
    end

    SimBiology.web.eventhandler('undoInDiagram',model.SessionID,[values.sessionID],visibleSet);

end


function setPosition(operations,model,block,value)


    x=value(1);
    y=value(2);
    width=value(3);
    height=value(4);

    operations.setSize(block,width,height);

    syntax=model.getDiagramSyntax;
    operations.setPosition(block,x,y);
    operations.setParent(block,syntax.root);
    SimBiology.web.diagram.layouthandler('reparentBlocks',operations,model,[],block);

end


function setExpressionLines(operations,model,block,value)

    selection=struct;
    selection.diagramUUID=block.uuid;
    selection.sessionID=block.getAttribute('sessionID').value;
    selection.type=block.getAttribute('type').value;

    inputs=struct;
    inputs.modelSessionID=model.SessionID;
    inputs.property='lines';
    inputs.selection=selection;
    inputs.value=value;

    for i=1:numel(inputs.selection)
        inputs.selection(i).value=value;
    end

    SimBiology.web.diagramhandler('configureLinePropertyOperations',operations,model,inputs);

end


function block=getBlockFromUUID(model,sessionID,UUID)

    block=SimBiology.web.diagram.utilhandler('getBlocksFromUUID',model,sessionID,UUID);

end