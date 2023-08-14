function linkObj=getTargetLinkObj(hCS)




    linkObj={};
    targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
    targetTokens=targetInfo.Tokens;

    if codertarget.data.isParameterInitialized(hCS,'TargetLinkObj')
        obj=codertarget.data.getParameterValue(hCS,'TargetLinkObj');
        [path,name,ext]=fileparts(obj.Name);
        linkObj.Name=codertarget.utils.replaceTokens(hCS,[name,ext],targetTokens);
        linkObj.Path=codertarget.utils.replaceTokens(hCS,path,targetTokens);
    end
end