function location=setSupportPackageRoot(spRoot)
































    validateattributes(spRoot,{'char','string'},{'nonempty','scalartext'},'matlabshared.supportpkg.setSupportPackageRoot','SPROOT');


    rootHandler=matlabshared.supportpkg.internal.SupportPackageRootHandler.getHandler();



    try
        rootHandler.setInstallRoot(spRoot);
    catch Ex
        myException=MException(message('supportpkgservices:supportpackageroot:UnableToSetSPRoot'));
        myException=addCause(myException,Ex);
        throw(myException);
    end

end