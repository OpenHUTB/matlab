function executePreUninstallForBaseCode(baseCode)













    validateattributes(baseCode,{'char'},{'nonempty'},'executePreUninstallForBaseCode','baseCode',1);

    spPkgInfo=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(baseCode);


    if isempty(spPkgInfo)
        return;
    end
    try
        if~isempty(spPkgInfo.PreUninstallCmd)

            matlabshared.supportpkg.internal.ssi.util.evaluateCmd(spPkgInfo.PreUninstallCmd);
        end
        matlabshared.supportpkg.internal.ssi.util.executeThirdPartyRemoveCmd(baseCode);
    catch ex
        baseException=MException(message('supportpkgservices:installservices:PreUninstallCmdError',baseCode));
        baseException=addCause(baseException,ex);
        throwAsCaller(baseException);
    end
end