





function[bResultStatus,ResultDescription]=modelAdvisorCheck_ConstRootOutportWithInterfaceUpgrade(system,model)





    bResultStatus=false;%#ok
    ResultDescription={};%#ok

    modelName=get_param(model,'name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
    encodedModelName=[encodedModelName{:}];


    [bResultStatus,ResultDescription]=loc_CheckForConstRootOutportWithInterface(system,model,encodedModelName);

end
