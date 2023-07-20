function registerImplParamInfo(this)




    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('FlattenHierarchy','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('BalanceDelays','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('DistributedPipelining','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('StreamingFactor','POSINT',0);
    this.addImplParamInfo('SharingFactor','POSINT',0);
    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});

    this.addImplParamInfo('AdaptivePipelining','ENUM','inherit',{'inherit','on','off'});


    this.addImplParamInfo('ClockRatePipelining','ENUM','inherit',{'inherit','on','off'});


    tab2Name=message('hdlcoder:hdlblockdialog:TargetSpecificationTab').getString;
    tab2Group1Name=message('hdlcoder:hdlblockdialog:TargetParameterGroup').getString;
    panelLayout=struct;
    panelLayout.tabName=tab2Name;
    panelLayout.tabPosition=2;
    panelLayout.groupName=tab2Group1Name;
    panelLayout.groupPosition=1;
    this.addImplParamInfo('ProcessorFPGASynchronization','STRING','',[],panelLayout);
    this.addImplParamInfo('TestPointMapping','MxARRAY',{},[],panelLayout);
    this.addImplParamInfo('TunableParameterMapping','MxARRAY',{},[],panelLayout);
    this.addImplParamInfo('AdditionalTargetInterfaces','MxARRAY',{},[],panelLayout);


    tab2Group2Name=message('hdlcoder:hdlblockdialog:IPcoreParameterGroup').getString;
    panelLayout.groupName=tab2Group2Name;
    panelLayout.groupPosition=2;
    this.addImplParamInfo('IPCoreName','STRING','',[],panelLayout);
    this.addImplParamInfo('IPCoreVersion','STRING','',[],panelLayout);
    this.addImplParamInfo('IPCoreAdditionalFiles','STRING','',[],panelLayout);
    this.addImplParamInfo('IPDataCaptureBufferSize','ENUM','128',...
    {'128','256','512','1024','2048','4096','8192','16384','32768','65536','131072','262144','524288','1048576'},panelLayout);
    this.addImplParamInfo('IPDataCaptureSequenceDepth','ENUM','1',...
    {'1','2','3','4','5','6','7','8','9','10'},panelLayout);
    this.addImplParamInfo('IncludeDataCaptureControlLogicEnable','ENUM','off',{'off','on'},panelLayout);
    this.addImplParamInfo('AXI4SlavePortToPipelineRegisterRatio','ENUM','auto',...
    {'auto','off','10','20','35','50'},panelLayout);
    this.addImplParamInfo('AXI4RegisterReadback','ENUM','off',{'off','on'},panelLayout);
    this.addImplParamInfo('GenerateDefaultAXI4Slave','ENUM','on',{'off','on'},panelLayout);
    this.addImplParamInfo('ExposeDUTClockEnablePort','ENUM','off',{'off','on'},panelLayout);
    this.addImplParamInfo('ExposeDUTCEOutPort','ENUM','off',{'off','on'},panelLayout);
    this.addImplParamInfo('AXI4SlaveIDWidth','STRING','',[],panelLayout);


