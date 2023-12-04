function launchCodeGenAdvisor(cbinfo)
    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','MATLAB Coder');
    end

    if~coder.internal.toolstrip.license.isSimulinkCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Simulink Coder');
    end

    if coder.internal.toolstrip.util.checkUseSlcoderOrEcoderFeaturesBasedOnTarget(cbinfo)

        preSelectedSystem=coder.internal.toolstrip.util.getSelectedSystem(cbinfo);

        defaultValue=cbinfo.model.Name;

        if isa(preSelectedSystem,'Simulink.SubSystem')
            subsystemBlock=SLM3I.SLDomain.handle2DiagramElement(preSelectedSystem.Handle);
            if SLStudio.Utils.objectIsValidSubsystemBlock(subsystemBlock)
                defaultValue=preSelectedSystem.getFullName;
            end
        end

        selectedSystem=modeladvisorprivate('systemselector',defaultValue);
        if isempty(selectedSystem)
            return;
        end

        coder.advisor.internal.runBuildAdvisor(selectedSystem,true,false);

    end
