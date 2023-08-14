function registerImplParamInfo(this)





    this.addImplParamInfo('BidirectionalPort','ENUM','off',{'on','off'});

    this.addImplParamInfo('BalanceDelays','ENUM','on',{'on','off'});

    tab2Name=message('hdlcoder:hdlblockdialog:TargetSpecificationTab').getString;
    tab2Group1Name=message('hdlcoder:hdlblockdialog:IOPortSpecificationGroup').getString;

    panelLayout1=struct;
    panelLayout1.tabName=tab2Name;
    panelLayout1.tabPosition=2;
    panelLayout1.groupName=tab2Group1Name;
    panelLayout1.groupPosition=1;

    this.addImplParamInfo('IOInterface','STRING','',[],panelLayout1);
    this.addImplParamInfo('IOInterfaceMapping','STRING','',[],panelLayout1);

    this.addImplParamInfo('IOInterfaceOptions','MxARRAY',{},[],panelLayout1);
