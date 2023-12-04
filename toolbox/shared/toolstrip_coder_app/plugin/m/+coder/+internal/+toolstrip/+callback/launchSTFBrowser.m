function out=launchSTFBrowser(cbInfo)
    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Matlab_Coder');
    end

    if~coder.internal.toolstrip.license.isSimulinkCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Simulink Coder');
    end

    mdl=cbInfo.model.handle;
    cs=getActiveConfigSet(mdl);
    configset.internal.util.launchSTFBrowser(cs);

end


