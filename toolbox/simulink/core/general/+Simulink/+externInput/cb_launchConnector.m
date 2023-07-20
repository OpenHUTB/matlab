function cb_launchConnector(dlgHandle)





    model=dlgHandle.getSource.getBlock.getParent.Name;

    aConnectorDlg=Simulink.sta.ScenarioConnector('Model',model);
    show(aConnectorDlg);