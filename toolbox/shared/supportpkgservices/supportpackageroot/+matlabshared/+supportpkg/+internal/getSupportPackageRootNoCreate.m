function spRoot=getSupportPackageRootNoCreate()














    try
        rootHandler=matlabshared.supportpkg.internal.SupportPackageRootHandler.getHandler();
        spRoot=rootHandler.getInstallRootNoCreate(struct('ErrorIfDefaultsMaxed',false));
        if~isdir(spRoot)
            spRoot='';
        end
    catch ex
        baseException=MException(message('supportpkgservices:supportpackageroot:UnableToReadSPRoot'));
        baseException=addCause(baseException,ex);
        throwAsCaller(baseException);
    end
end