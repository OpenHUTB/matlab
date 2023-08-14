function mapInputsCB(cbinfo)
    model=cbinfo.studio.App.blockDiagramHandle;

    if~isempty(model)
        modelName=get_param(model,'Name');
        inputconnector('Model',modelName);
    end
end
