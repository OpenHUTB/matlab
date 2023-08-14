function[isInstalled,spName]=isHDLCoderSoCSPInstalled(obj)







    if obj.isAlteraIP
        [isInstalled,spName]=hdlturnkey.ishdlalterasocspinstalled;
    elseif obj.isXilinxIP
        [isInstalled,spName]=hdlturnkey.ishdlzynqspinstalled;
    elseif obj.isMicrochipIP
        [isInstalled,spName]=hdlturnkey.ishdlmicrochipspinstalled;
    else
        isInstalled=false;
        spName='';
    end