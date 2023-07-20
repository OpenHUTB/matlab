function setSystemToUseShortName(ddsMf0Model,value)



    systemInModel=dds.internal.getSystemInModel(ddsMf0Model);
    if isempty(systemInModel)

        return;
    end

    if isempty(systemInModel.TypeMap)
        systemInModel.createIntoTypeMap(struct('metaClass','dds.datamodel.types.TypeMap','UsingShortNames',value));
    else
        systemInModel.TypeMap.UsingShortNames=value;
    end
end