function registerImplParamInfo(this)





    this.registerImplParamInfo@hdldefaults.AbstractPort;

    if slfeature('StreamingMatrixWorkflow')
        tab2Name=message('hdlcoder:hdlblockdialog:StreamingMatrixTab').getString;
        tab2Group1Name=message('hdlcoder:hdlblockdialog:StreamingMatrixGeneralGroup').getString;

        panelLayout2=struct;
        panelLayout2.tabName=tab2Name;
        panelLayout2.tabPosition=3;
        panelLayout2.groupName=tab2Group1Name;
        panelLayout2.groupPosition=1;

        this.addImplParamInfo('ConvertToSamples','ENUM','off',{'on','off'},panelLayout2);
    end
