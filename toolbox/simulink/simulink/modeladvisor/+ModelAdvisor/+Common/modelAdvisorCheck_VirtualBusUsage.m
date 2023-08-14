







function[bResultStatus,ResultDescription]=modelAdvisorCheck_VirtualBusUsage(system,model)







    bResultStatus=false;
    ResultDescription={};

    modelName=get_param(model,'name');
    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
    encodedModelName=[encodedModelName{:}];


    [bResultStatus,results]=loc_CheckForBusToVectorConversion(system,model,encodedModelName,true);

    ResultDescription=[ResultDescription,results];
end


