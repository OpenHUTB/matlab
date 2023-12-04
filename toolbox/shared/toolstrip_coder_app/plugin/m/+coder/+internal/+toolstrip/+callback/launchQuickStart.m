function launchQuickStart(cbinfo)

    if coder.internal.toolstrip.util.checkUseEmbeddedCoderFeatures(cbinfo)
        if strcmp(get_param(cbinfo.model.handle,'IsERTTarget'),'on')
            locCheckEmbeddedCoder();

            selectedSystem=coder.internal.toolstrip.util.getSelectedSystem(cbinfo);


            if isa(selectedSystem,'Simulink.SubSystem')
                subsystemBlock=SLM3I.SLDomain.handle2DiagramElement(selectedSystem.Handle);
                if SLStudio.Utils.objectIsValidSubsystemBlock(subsystemBlock)
                    coder.internal.wizard.slcoderWizard(selectedSystem.getFullName,'Start');
                    return;
                end
            end

            model=bdroot(cbinfo.model.handle);
            coder.internal.wizard.slcoderWizard(model,'Start');
        else
            locCheckSimulinkCoder();

            model=bdroot(cbinfo.model.handle);
            simulinkcoder.internal.wizard.slcoderWizard(model,'Start');
        end
    end

end


function locCheckMATLABCoder()

    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Matlab_Coder');
    end
end

function locCheckSimulinkCoder()

    locCheckMATLABCoder();
    if~coder.internal.toolstrip.license.isSimulinkCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Real-Time_Workshop');
    end
end

function locCheckEmbeddedCoder()

    locCheckSimulinkCoder();
    if~coder.internal.toolstrip.license.isEmbeddedCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','RTW_Embedded_Coder');
    end
end