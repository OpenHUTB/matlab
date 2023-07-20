function location=getSupportPackageRoot(varargin)


















    p=inputParser();
    p.CaseSensitive=false;
    p.addOptional('CreateDir',false,@islogical)
    p.parse(varargin{:});



    if~p.Results.CreateDir
        location=matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
        return;
    end




    rootHandler=matlabshared.supportpkg.internal.SupportPackageRootHandler.getHandler();
    try
        location=rootHandler.getInstallRoot();
    catch ex
        baseException=MException(message('supportpkgservices:supportpackageroot:UnableToReadSPRoot'));
        baseException=addCause(baseException,ex);
        throwAsCaller(baseException);
    end
end