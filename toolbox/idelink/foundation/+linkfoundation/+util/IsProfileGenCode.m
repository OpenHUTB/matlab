function resp=IsProfileGenCode(modelName)




    modelName=convertStringsToChars(modelName);

    cs=getActiveConfigSet(modelName);
    resp=strcmpi(get_param(cs,'ProfileGenCode'),'on')||...
    linkfoundation.pil.isProfilePIL(modelName);
