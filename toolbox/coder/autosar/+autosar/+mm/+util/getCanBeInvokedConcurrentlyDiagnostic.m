




function retValue=getCanBeInvokedConcurrentlyDiagnostic(modelName)

    retValue=true;
    try
        m3iModel=autosar.api.Utils.m3iModel(modelName);
        arRoot=m3iModel.RootPackage.front();
        diag=autosar.mm.util.XmlOptionsAdapter.get(...
        arRoot,'CanBeInvokedConcurrentlyDiagnostic');
        retValue=strcmp(diag,'Error');

    catch
        return;
    end

end
