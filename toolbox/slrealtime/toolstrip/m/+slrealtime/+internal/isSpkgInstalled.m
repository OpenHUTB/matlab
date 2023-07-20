function result=isSpkgInstalled()





    installedSupportPackages=matlabshared.supportpkg.getInstalled;
    result=false;


    if~isempty(installedSupportPackages)
        result=any(strcmpi('Simulink Real-Time Target Support Package',...
        {installedSupportPackages.Name}));
    end

end

