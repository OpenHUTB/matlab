











function[bResultStatus,ResultDescription]=modelAdvisorCheck_ProperBusUsage(system,model)











    modelName=get_param(model,'name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
    encodedModelName=[encodedModelName{:}];

    [status,results]=loc_CheckForBusToVectorConversion(system,model,encodedModelName,false);

    bResultStatus=status;
    ResultDescription=results;

end


