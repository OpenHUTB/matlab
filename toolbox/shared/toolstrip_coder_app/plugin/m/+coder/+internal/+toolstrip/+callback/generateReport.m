function generateReport(cbinfo)




    if~coder.internal.toolstrip.license.isMATLABCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','MATLAB Coder');
    end

    if~coder.internal.toolstrip.license.isSimulinkCoder

        DAStudio.error('SimulinkCoderApp:toolstrip:licenseForActionNotFound','Simulink Coder');
    end

    selectedSystem=coder.internal.toolstrip.util.getSelectedSystem(cbinfo);
    rtw.report.generate(selectedSystem.Handle);

