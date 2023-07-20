function out=specieshandler(action,varargin)











    out=[];

    switch(action)
    case 'addBlock'
        out=addBlock(varargin{:});
    case 'deleteBlock'
        deleteBlock(varargin{:});
    case 'propertyChanged'
        propertyChanged(varargin{:});
    end

end

function block=addBlock(operations,model,obj,needAutomaticLayout)

    parentBlock=model.getEntitiesInMap(obj.Parent.SessionID);
    block=createBlock(operations,model,parentBlock.subdiagram,obj);


    if~isempty(block)&&needAutomaticLayout
        positionSingleBlock(operations,model,block,[],obj);
    end

end

function deleteBlock(speciesBlocks,modelSessionID)

    model=SimBiology.web.modelhandler('getModelFromSessionID',modelSessionID);
    diagramEditor=model.getDiagramEditor;
    commandProcessor=diagramEditor.commandProcessor;

    for i=1:numel(speciesBlocks)
        if~speciesBlocks(i).isValid
            continue;
        end

        sessionID=getAttributeValue(speciesBlocks(i),'sessionID');
        if strcmp(speciesBlocks(i).getAttribute('cloned').value,'true')
            input=struct;
            input.model=model;
            input.speciesBlock=speciesBlocks(i);
            input.sessionID=sessionID;
            input.deleteSpeciesCloneOperationsFcn=@deleteSpeciesCloneOperations;
            input.commandProcessor=commandProcessor;

            SimBiology.web.diagram.utilhandler('verifyUndoStackSize',model);
            cmd=commandProcessor.createCustomCommand('SimBiology.web.diagram.commands.DeleteSpeciesCloneCommand','Custom Clone Delete',input);
            commandProcessor.execute(cmd);



            remainingClones=model.getEntitiesInMap(sessionID);
            if isempty(remainingClones)
                SimBiology.web.modelhandler('deleteObject',struct('modelSessionID',modelSessionID,'objectIDs',sessionID,'type','species','forceDelete',true));
            end
        else
            SimBiology.web.modelhandler('deleteObject',struct('modelSessionID',modelSessionID,'objectIDs',sessionID,'type','species','forceDelete',true));
        end
    end

end

function deleteSpeciesCloneOperations(operations,model,speciesBlock,sessionID)



    deleteLinesFromDiagram(model.SessionID,{speciesBlock.connections.uuid});


    deleteBlocks(operations,model,speciesBlock);


    remainingClones=model.getEntitiesInMap(sessionID);

    if numel(remainingClones)==1


        setAttributeValue(operations,remainingClones,'cloned','false');
        setAttributeValue(operations,remainingClones,'cloneIndex',1);
    elseif numel(remainingClones)>1
        setAttributeValue(operations,remainingClones,'cloned','true');

        for i=1:numel(remainingClones)
            setAttributeValue(operations,remainingClones(i),'cloneIndex',i);
        end
    end

end

function deleteBlocks(operations,model,blocks)

    SimBiology.web.diagramhandler('deleteBlocks',operations,model,blocks);

end

function propertyChanged(operations,model,input)

    if strcmp(input.property,'Name')
        handleNamePropertyChanged(operations,model,input);
    end

end

function handleNamePropertyChanged(operations,model,input)

    blocks=model.getEntitiesInMap(input.obj);
    setAttributeValue(operations,blocks,lower(input.property),input.value);

end

function block=createBlock(operations,model,parent,obj)

    block=SimBiology.web.diagramhandler('createBlock',operations,model,parent,obj);

end

function deleteLinesFromDiagram(modelSessionID,lines)

    SimBiology.web.diagram.linehandler('deleteLinesFromDiagram',modelSessionID,lines);

end

function out=getAttributeValue(blocks,property)

    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);

end

function positionSingleBlock(operations,model,block,allBlocks,obj)

    SimBiology.web.diagram.placementhandler('positionSingleBlock',operations,model,block,allBlocks,obj,true);

end

function setAttributeValue(operations,blocks,property,value)

    SimBiology.web.diagramhandler('setAttributeValue',operations,blocks,property,value);
end
