function resp=GetLinkProductUsed(modelName)





    cs=getActiveConfigSet(modelName);
    userData=get_param(cs,'TargetHardwareResources');






    resp=regexprep(userData.tag,'tgtpref.*','');

end