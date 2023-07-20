function result=isCommBluetoothInstalled






    installedProducts=ver;
    productNames={installedProducts.Name};
    if~ismember('Communications Toolbox',productNames)
        result=false;
        return
    end


    if~builtin('license','test','Communication_Toolbox')
        result=false;
        return
    end


    installedPackages=matlabshared.supportpkg.getInstalled;
    result=(~isempty(installedPackages)&&any(installedPackages.Name=='Communications Toolbox Library for the Bluetooth Protocol'));
end