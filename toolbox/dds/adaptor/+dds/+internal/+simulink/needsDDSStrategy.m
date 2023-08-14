function out=needsDDSStrategy(modelName)






    out=false;
    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(modelName);
    if~isempty(ddsMf0Model)
        stf=get_param(modelName,'SystemTargetFile');
        if isequal(stf,'slrealtime.tlc')


            out=true;
        else
            out=dds.internal.simulink.Util.checkIfModelMappingIsSetToDDS(modelName);
        end
    end
end