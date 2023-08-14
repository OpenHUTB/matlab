function returnList=getModelParameters(modelName,harnessName)






    [modelToUse,deactivateHarness,currHarness,oldHarness]=stm.internal.util.resolveHarness(modelName,harnessName);
    returnList=getModelParameterHelper(modelToUse,modelName,harnessName);


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name);
        end
    end
end

function paraList=getModelParameterHelper(modelToUse,originalModel,harnessName)


    import stm.internal.MRT.share.getVariableStruct;
    args=stm.internal.Parameters.getFindVarsArgs(modelToUse);
    vars=stm.internal.MRT.share.MRTFindVar(modelToUse,args{:});

    paraList=getVariableStruct(vars,originalModel,harnessName);
end
