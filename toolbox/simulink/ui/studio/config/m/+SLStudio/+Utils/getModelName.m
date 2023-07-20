function modelName=getModelName(cbinfo,varargin)




    if(nargin>1)
        useTopModel=varargin{1};
    else
        useTopModel=true;
    end

    if(useTopModel)
        model=cbinfo.model;
    else
        model=cbinfo.editorModel;
    end

    if~isempty(model)&&(isa(model,'Simulink.BlockDiagram'))
        modelName=model.Name;
    else
        modelName='';
    end
end
