function out=alignmenthandler(action,varargin)











    out=[];

    switch(action)
    case 'alignBlocks'
        alignBlocks(varargin{:});
    end

end

function alignBlocks(varargin)

    input=[varargin{:}];
    model=SimBiology.web.modelhandler('getModelFromSessionID',input(1).modelSessionID);

    if model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)alignBlocksOperations(operations,model,input));
    end

end

function alignBlocksOperations(operations,model,input)

    transaction=SimBiology.Transaction.create(model);
    currentValues={};
    newValues={};

    for j=1:numel(input)
        blocks=input(j).blocks;
        action=input(j).action;
        value=input(j).value;


        idx=strcmp({blocks.pin},'false');
        blocks=blocks(idx);
        if(numel(value)~=1)
            value=value(idx);
        end

        for i=1:numel(blocks)
            next=getBlocksFromUUID(model,blocks(i).sessionID,blocks(i).diagramUUID);
            switch(action)
            case 'x'
                position=next.getPosition;
                newPosition=[getValue(value,i),position.y];
            case 'y'
                position=next.getPosition;
                newPosition=[position.x,getValue(value,i)];
            end

            operations.setPosition(next,newPosition(1),newPosition(2));


            currentValue=struct;
            currentValue.sessionID=blocks(i).sessionID;
            currentValue.diagramUUID=blocks(i).diagramUUID;
            currentValue.position=[position.x,position.y];

            newValue=struct;
            newValue.sessionID=blocks(i).sessionID;
            newValue.diagramUUID=blocks(i).diagramUUID;
            newValue.position=newPosition;

            currentValues{end+1}=currentValue;%#ok<*AGROW>
            newValues{end+1}=newValue;%#ok<*AGROW>
        end
    end

    currentValues=[currentValues{:}];
    newValues=[newValues{:}];
    transaction.push(@()SimBiology.web.diagram.undo.positionLambda(model,currentValues,newValues));
    transaction.commit();

end

function out=getValue(value,index)

    if numel(value)==1
        out=value(1);
    else
        out=value(index);
    end

end

function blocks=getBlocksFromUUID(model,sessionID,UUID)

    blocks=SimBiology.web.diagram.utilhandler('getBlocksFromUUID',model,sessionID,UUID);

end
