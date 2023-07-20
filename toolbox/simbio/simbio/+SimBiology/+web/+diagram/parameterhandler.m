function out=parameterhandler(action,varargin)











    out=[];

    switch(action)
    case 'deleteBlock'
        deleteBlock(varargin{:});
    case 'propertyChanged'
        propertyChanged(varargin{:});
    end

end

function deleteBlock(paramSessionIDs,modelSessionID,type)

    for i=1:numel(paramSessionIDs)
        SimBiology.web.modelhandler('deleteObject',struct('modelSessionID',modelSessionID,'objectIDs',paramSessionIDs(i),'type',type,'forceDelete',true));
    end

end

function propertyChanged(operations,model,input)

    if strcmp(input.property,'Name')
        handleNamePropertyChanged(operations,model,input);
    end

end

function handleNamePropertyChanged(operations,model,input)

    blocks=model.getEntitiesInMap(input.obj);
    if~isempty(blocks)
        setAttributeValue(operations,blocks,lower(input.property),input.value);
    end

end

function setAttributeValue(operations,blocks,property,value)

    SimBiology.web.diagramhandler('setAttributeValue',operations,blocks,property,value);
end
