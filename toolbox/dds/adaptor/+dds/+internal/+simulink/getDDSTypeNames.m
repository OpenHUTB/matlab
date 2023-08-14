function ddstypes=getDDSTypeNames(modelName)





    ddstypes={};
    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    if isempty(ddsMf0Model)
        return;
    end
    system=dds.internal.getSystemInModel(ddsMf0Model);
    if~isempty(system)
        typeLibs=system(1).TypeLibraries;
        for libs=1:typeLibs.Size
            ddstypes=[ddstypes,...
            dds.internal.simulink.Util.getDDSTypeNamesHelper(...
            typeLibs(libs).Elements)];
        end
    end
end

