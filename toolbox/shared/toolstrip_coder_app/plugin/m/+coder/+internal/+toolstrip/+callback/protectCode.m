function protectCode(userdata,cbinfo)




    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','MATLAB Coder');
    end

    if~coder.internal.toolstrip.license.isSimulinkCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Simulink Coder');
    end

    switch userdata
    case 'currentModel'
        pm=Simulink.ModelReference.ProtectedModel.CreatorDialog(cbinfo.model.name);
        if~isempty(pm)
            Simulink.ModelReference.ProtectedModel.showDialog(pm);
        end
    case 'selectedModel'
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidModelReferenceBlock(block)
            pm=Simulink.ModelReference.ProtectedModel.CreatorDialog(block.handle);
            if~isempty(pm)
                Simulink.ModelReference.ProtectedModel.showDialog(pm);
            end
        end
    end
end
