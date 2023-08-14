function out=compartmenthandler(action,varargin)











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

function block=addBlock(operations,model,syntaxRoot,obj,needAutomaticLayout)

    parent=obj.Owner;
    if isempty(parent)

        block=createBlock(operations,model,syntaxRoot,obj);
    else

        parentBlock=model.getEntitiesInMap(parent.SessionID);
        block=createBlock(operations,model,parentBlock.subdiagram,obj);
    end


    if~isempty(block)&&needAutomaticLayout
        positionSingleBlock(operations,model,block,[],obj);
    end

end

function deleteBlock(compartmentBlocks,model)

    for i=1:numel(compartmentBlocks)
        if~compartmentBlocks(i).isValid
            continue;
        end

        sessionID=getAttributeValue(compartmentBlocks(i),'sessionID');
        compartment=sbioselect(model,'SessionID',sessionID);
        if~isempty(compartment)
            deleteCompartment(model,compartment);
        end
    end

end

function deleteCompartment(model,compartment)

    children=sbioselect(compartment,'Owner',compartment);
    if~isempty(children)
        for i=1:length(children)
            deleteCompartment(model,children(i));
        end
    end

    SimBiology.web.modelhandler('deleteObject',struct('modelSessionID',model.SessionID,'objectIDs',compartment.SessionID,'type','compartment','forceDelete',true));

end

function propertyChanged(operations,model,~,~,input)

    if strcmp(input.property,'Name')
        handleNamePropertyChanged(operations,model,input);
    elseif strcmp(input.property,'Owner')

    end

end

function handleNamePropertyChanged(operations,model,input)

    block=model.getEntitiesInMap(input.obj);
    setAttributeValue(operations,block,lower(input.property),input.value);

end

function block=createBlock(operations,model,parent,obj)

    block=SimBiology.web.diagramhandler('createBlock',operations,model,parent,obj);

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
