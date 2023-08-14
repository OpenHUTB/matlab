function installDir=getThirdPartyToolDir(thirdPartyToolName,spPkgName)








    narginchk(1,2);
    validateattributes(thirdPartyToolName,{'char'},{'nonempty'});
    if isequal(nargin,2)












        validateattributes(spPkgName,{'char'},{'nonempty'});

        hPkgInfo=hwconnectinstaller.PackageInfo;
        spPkg=hPkgInfo.getSpPkgInfo(spPkgName);
        installDir=hPkgInfo.getTpPkgRootDir(thirdPartyToolName,spPkg);
    else



        thirdPartyInstructionSetComponent=thirdPartyToolName;
        installDir=matlab.internal.get3pInstallLocation(...
        thirdPartyInstructionSetComponent);
    end
end
