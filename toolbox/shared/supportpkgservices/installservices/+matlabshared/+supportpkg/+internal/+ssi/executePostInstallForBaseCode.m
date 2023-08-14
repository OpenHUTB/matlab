function executePostInstallForBaseCode(baseCode)













    validateattributes(baseCode,{'char'},{'nonempty'},'executePreUninstallForBaseCode','baseCode',1);

    spPkgInfo=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(baseCode);


    if isempty(spPkgInfo)||isempty(spPkgInfo.PostInstallCmd)
        return;
    end
    try
        matlabshared.supportpkg.internal.ssi.util.evaluateCmd(spPkgInfo.PostInstallCmd);
    catch ex
        baseException=MException(message('supportpkgservices:installservices:PostInstallCmdError',baseCode));
        baseException=addCause(baseException,ex);
        throwAsCaller(baseException);
    end

end