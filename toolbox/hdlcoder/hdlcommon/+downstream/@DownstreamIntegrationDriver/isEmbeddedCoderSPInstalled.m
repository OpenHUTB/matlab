function[isInstalled,spName]=isEmbeddedCoderSPInstalled(obj)




    if obj.isAlteraIP
        [isInstalled,spName]=hdlturnkey.isECoderAlteraSoCSPInstalled;
    elseif obj.isXilinxIP
        [isInstalled,spName]=hdlturnkey.isECoderZynqSPInstalled;
    else
        isInstalled=false;
        spName='';
    end