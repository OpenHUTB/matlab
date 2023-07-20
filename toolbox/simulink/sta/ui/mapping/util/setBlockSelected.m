function setBlockSelected(modelName,portName,value)





    if Simulink.iospecification.InportProperty.checkModelName(modelName)
        portH=find_system(get_param(modelName,'Handle'),...
        'SearchDepth',1,'Name',portName);

        if~isempty(portH)
            set(portH,'Selected',value);
        end
    end