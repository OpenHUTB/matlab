










function[bResultStatus,ResultDescription]=modelAdvisorCheck_BusTreatedAsVector(system,model)







    bResultStatus=false;%#ok
    ResultDescription={};%#ok

    modelName=get_param(model,'name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
    encodedModelName=[encodedModelName{:}];




    [bResultStatus,ResultDescription]=loc_CheckForBusToVectorConversion(system,model,encodedModelName,false);
end


