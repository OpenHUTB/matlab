function m=createSoCBMask(blkPath)






    [~,blkName]=fileparts(blkPath);
    blkProgName=matlab.lang.makeValidName(blkName);


    switch blkProgName
    case{'MemoryChannel','MemoryController'}
        cbExt='V1';
        iconName=blkProgName;
    case 'MemoryTrafficGenerator'
        iconName='TrafficGenerator';
        cbExt='';
    otherwise
        cbExt='';
    end

    maskcb=['hsb.blkcb2.',blkProgName,'Cb',cbExt];
    mcat='soc:ui:';

    m=feval('soc.internal.SoCBMask',blkPath,blkProgName,maskcb,mcat);
    feval(['l_create',blkProgName,'Mask'],m);
    feval(['l_create',blkProgName,'BlockCallbacks'],blkPath,maskcb);
    l_setBlockIcon(m,blkPath,iconName);
end


function l_createMyInterestingBlockNameMask(m)
    m.mcall('addParameter','Prompt','fooedit','Callback','callbackthatdoesnotexist');
end


function l_createMemoryControllerMask(m)

    m.top.Initialization=...
    ['blkH = gcbh;',newline,...
    'blkDP = ',m.maskcb,'(''MaskInitFcnGetDerivedInfo'',blkH);',newline,...
    m.maskcb,'(''MaskInitFcnSetDerivedInfo'',blkH);',newline];

    m.top.Type='Memory Controller';

    ptagnull='';
    pcbtrue=true;
    pcbfalse=false;
    m.dcText('top','CurrHardwareBoardText',ptagnull,{});
    m.dcLink('top','HardwareBoardLink',ptagnull,{'Row','current'});

    tc=m.dcTabContainer('top','TabContainer',{});
    mt=m.dcTab(tc,'MainTab',{'AlignPrompts','off'});
    pt=m.dcTab(tc,'PerformanceTab',{'AlignPrompts','off'});


    m.pEdit(mt,'NumMasters',ptagnull,'2',pcbtrue,{},{});


    app=m.dcCollapsiblePanel(mt,'AdvancedParametersPanel',{'AlignPrompts','off'});

    m.pPopup(app,'ICArbitrationPolicy',ptagnull,'Round robin',pcbfalse,...
    {'Round robin','Fixed port priority'},...
    {},{});


    thrg=m.dcGroup(app,'TargetHardwareResourcesGroup',{});
    m.pCheckbox(thrg,'UseValuesFromTargetHardwareResources',ptagnull,'on',pcbtrue,{},{});




    cpg=m.dcGroup(thrg,'ControllerGroup',{});

    m.dcText(cpg,'BandwidthRowHdr',ptagnull,{});
    m.pEdit(cpg,'ControllerFrequency',ptagnull,'200',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemorySubsystemClockToolTip'});
    m.pEdit(cpg,'ControllerDataWidth',ptagnull,'64',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemorySubsystemDataWidthToolTip'});
    m.pEdit(cpg,'BandwidthDerating',ptagnull,'2.3',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignRefreshOverheadToolTip'});

    m.dcText(cpg,'ReqToFirstRowHdr',ptagnull,{});
    m.pEdit(cpg,'WriteFirstTransferLatency',ptagnull,'35',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignWriteFirstTransferLatencyToolTip'});
    m.pEdit(cpg,'ReadFirstTransferLatency',ptagnull,'15',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignReadFirstTransferLatencyToolTip'});

    m.dcText(cpg,'LastToDoneRowHdr',ptagnull,{});
    m.pEdit(cpg,'WriteLastTransferLatency',ptagnull,'35',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignWriteLastTransferLatencyToolTip'});
    m.pEdit(cpg,'ReadLastTransferLatency',ptagnull,'15',pcbfalse,{},...
    {'Tooltip','codertarget:ui:FPGADesignReadLastTransferLatencyToolTip'});


    m.dcText(pt,'LaunchPerformanceAppText',ptagnull,{'WordWrap','on'});
    m.dcButton(pt,'LaunchPerformanceAppButton',ptagnull,{'Row','new'});


    hpp=m.dcCollapsiblePanel(pt,'HiddenParametersPanel',{'Visible','off'});
    m.pEdit(hpp,'LastTargetBoard',ptagnull,'ZedBoard',pcbfalse,{'Evaluate','off'},{});
    m.pEdit(hpp,'DiagnosticLevel',ptagnull,'No debug',pcbfalse,{'Evaluate','off'},{});
    m.pEdit(hpp,'MAX_NUM_MASTERS',ptagnull,'12',pcbfalse,{},{});



    tdpp=m.dcCollapsiblePanel(pt,'ToDeleteParametersPanel',{'Visible','off'});
    m.pEdit(tdpp,'DDRRefreshLength',ptagnull,'4',pcbfalse,{},{});
    m.pEdit(tdpp,'DDRRefreshInterval',ptagnull,'7.8',pcbfalse,{},{});
    m.pEdit(tdpp,'PlotTimeResolution',ptagnull,'100e-6',pcbfalse,{},{});
    m.dcButton(tdpp,'PlotBWUsageBtn',ptagnull,{});
    m.dcButton(tdpp,'PlotBurstsExecutedBtn',ptagnull,{});
    m.dcButton(tdpp,'PlotAvgExecTimeBtn',ptagnull,{'Visible','off'});
    m.dcButton(tdpp,'PlotAvgReqToExecTimeBtn',ptagnull,{'Visible','off'});

end
function l_createMemoryControllerBlockCallbacks(blkPath,maskcb)
    cblist={'CopyFcn','DeleteFcn','InitFcn','LoadFcn','PreSaveFcn','UndoDeleteFcn'};
    l_setCallbacks(blkPath,maskcb,cblist);
end


function l_createMemoryChannelMask(m)%#ok<*DEFNU>

    m.top.Initialization=...
    ['blkH = gcbh;',newline,...
    'blkDP = ',m.maskcb,'(''MaskInitFcnGetDerivedInfo'',blkH);',newline,...
    m.maskcb,'(''MaskInitFcnSetDerivedInfo'',blkH);',newline];

    m.top.Type='Memory Channel';

    ptagnull='';
    pcbtrue=true;
    pcbfalse=false;
    m.dcText('top','CurrHardwareBoardText',ptagnull,{});
    m.dcLink('top','HardwareBoardLink',ptagnull,{'Row','current'});
    m.dcLink('top','ShowImplementationInfoLink',ptagnull,{'Row','new'});

    tc=m.dcTabContainer('top','TabContainer',{});
    mt=m.dcTab(tc,'MainTab',{'AlignPrompts','off'});
    dsat=m.dcTab(tc,'DataSignalAttributesTab',{'AlignPrompts','off'});
    pt=m.dcTab(tc,'PerformanceTab',{'AlignPrompts','off'});



    m.pPopup(mt,'ChannelType',ptagnull,'AXI4-Stream FIFO',pcbtrue,...
    {'AXI4-Stream to Software via DMA','AXI4-Stream FIFO',...
    'AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer',...
    'AXI4 Random Access'},...
    {},{});


    m.dcText(mt,'MRRegionSizeText',ptagnull,{});
    m.pEdit(mt,'MRBufferSize',ptagnull,'1024',pcbfalse,{},{});
    m.pEdit(mt,'MRNumBuffers',ptagnull,'8',pcbfalse,{},{});



    app=m.dcCollapsiblePanel(mt,'AdvancedParametersPanel',{'AlignPrompts','off'});
    blpg=m.dcGroup(app,'BurstLengthGroup',{'AlignPrompts','off'});
    m.pEdit(blpg,'BurstLength','WriterChIf','256',pcbfalse,{'Prompt','Writer:'},{});
    m.pEdit(blpg,'BurstLength','ReaderChIf','256',pcbfalse,{'Prompt','Reader:'},{});


    thrg=m.dcGroup(app,'TargetHardwareResourcesGroup',{'AlignPrompts','off'});
    m.pCheckbox(thrg,'UseValuesFromTargetHardwareResources',ptagnull,'on',pcbtrue,{},{});


    m.pCheckbox(thrg,'ReaderWriterUseSameValues',ptagnull,'on',pcbtrue,{},{});

    icpg=m.dcGroup(thrg,'InterconnectGroup',{'AlignPrompts','off'});
    m.dcText(icpg,'FIFODepthRowHdr',ptagnull,{});
    m.pEdit(icpg,'FIFODepth','Writer','10',pcbfalse,{'Prompt','  Writer:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectFIFODepthToolTip'});
    m.pEdit(icpg,'FIFODepth','Reader','10',pcbfalse,{'Prompt','  Reader:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectFIFODepthToolTip'});
    m.dcText(icpg,'FIFOAFullDepthRowHdr',ptagnull,{});
    m.pEdit(icpg,'FIFOAFullDepth','Writer','8',pcbfalse,{'Prompt','  Writer:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectFIFOAFullDepthToolTip'});
    m.pEdit(icpg,'FIFOAFullDepth','Reader','8',pcbfalse,{'Prompt','  Reader:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectFIFOAFullDepthToolTip'});
    m.dcText(icpg,'ICClockFrequencyRowHdr',ptagnull,{});
    m.pEdit(icpg,'ICClockFrequency','Writer','100',pcbfalse,{'Prompt','  Writer:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectInputClockToolTip'});
    m.pEdit(icpg,'ICClockFrequency','Reader','100',pcbfalse,{'Prompt','  Reader:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectInputClockToolTip'});
    m.dcText(icpg,'ICDataWidthRowHdr',ptagnull,{});
    m.pEdit(icpg,'ICDataWidth','Writer','32',pcbfalse,{'Prompt','  Writer:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectInputDataWidthToolTip'});
    m.pEdit(icpg,'ICDataWidth','Reader','32',pcbfalse,{'Prompt','  Reader:'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemoryInterconnectInputDataWidthToolTip'});


    idsg=m.dcGroup(dsat,'InputDataSpecGroup',{'AlignPrompts','off'});
    dtypePos=17;
    dtypeSupport='{b=double|single|int8|uint8|int16|uint16|int32|uint32|int64|uint64|boolean}{s=UDTBinaryPointMode}{g=UDTSignedSign|UDTUnsignedSign}';
    m.pEdit(idsg,'ChDimensions','WriterChIf','1',pcbfalse,{},{});
    m.pDataTypeStr(idsg,'ChType','WriterChIf','uint8',pcbfalse,dtypePos,dtypeSupport,{},{});
    m.pEdit(idsg,'ChFrameSampleTime','WriterChIf','1',pcbfalse,{},{});



    odsg=m.dcGroup(dsat,'OutputDataSpecGroup',{'AlignPrompts','off'});
    m.pCheckbox(odsg,'OutSigSpecMatchesInSigSpec',ptagnull,'on',pcbtrue,{},{});
    dtypePos=21;
    dtypeSupport='{i=Inherit: Same as input}{b=double|single|int8|uint8|int16|uint16|int32|uint32|int64|uint64|boolean}{s=UDTBinaryPointMode}{g=UDTSignedSign|UDTUnsignedSign}';
    m.pEdit(odsg,'ChDimensions','ReaderChIf','1',pcbfalse,{},{});
    m.pDataTypeStr(odsg,'ChTypeWithInh','ReaderChIf','uint8',pcbfalse,dtypePos,dtypeSupport,{},{});
    m.pEdit(odsg,'ChFrameSampleTime','ReaderChIf','1',pcbfalse,{},{});
    m.pCheckbox(odsg,'InsertInactivePixelClocks','ReaderChIf','off',pcbtrue,{},{});
    m.pPopup(odsg,'FrameSize','ReaderChIf','160x120p',pcbfalse,...
    {'160x120p','480p SDTV (720x480p)','576p SDTV (720x576p)','720p HDTV (1280x720p)',...
    '1080p HDTV (1920x1080p)','320x240p','640x480p','800x600p','1024x768p',...
    '1280x768p','1280x1024p','1360x768p','1400x1050p','1600x1200p','1680x1050p',...
    '1920x1200p','16x12p (test mode)'},...
    {},{});


    m.dcText(pt,'LaunchPerformanceAppText',ptagnull,{'WordWrap','on'});
    m.dcButton(pt,'LaunchPerformanceAppButton',ptagnull,{'Row','new'});




    hpp=m.dcCollapsiblePanel(dsat,'HiddenParametersPanel',{'Visible','off'});
    m.pPopup(hpp,'Protocol','Writer','AXI4-Stream',pcbtrue,...
    {'AXI4-Stream','AXI4-Stream Video','AXI4','AXI4-Stream Software'},...
    {},{});
    m.pPopup(hpp,'Protocol','Reader','AXI4-Stream',pcbtrue,...
    {'AXI4-Stream','AXI4-Stream Video','AXI4-Stream Video with Frame Sync','AXI4','AXI4-Stream Software'},...
    {},{});
    dtypePos=26;
    dtypeSupport='{b=double|single|int8|uint8|int16|uint16|int32|uint32|int64|uint64|boolean}{s=UDTBinaryPointMode}{g=UDTSignedSign|UDTUnsignedSign}';
    m.pDataTypeStr(hpp,'ChType','ReaderChIf','uint8',pcbfalse,dtypePos,dtypeSupport,{},{});

    m.pEdit(hpp,'LastTargetBoard',ptagnull,'ZedBoard',pcbfalse,{'Evaluate','off'},{});
    m.pEdit(hpp,'Beta2Compatible',ptagnull,'off',pcbfalse,{'Evaluate','off'},{});
    m.pEdit(hpp,'MRRegionSize',ptagnull,'8192',pcbfalse,{},{});
    m.pEdit(hpp,'DiagnosticLevel',ptagnull,'No debug',pcbfalse,{'Evaluate','off'},{});


    tdpp=m.dcCollapsiblePanel(dsat,'ToDeleteParametersPanel',{'Visible','off'});
    m.pEdit(tdpp,'MRBaseAddress',ptagnull,'hex2dec(''00010000'')',pcbfalse,{},{});
    m.pCheckbox(tdpp,'UseTargetGlobalValues',ptagnull,'off',pcbfalse,{},{});

    tdwpg=m.dcGroup(tdpp,'ToDeleteWriterGroup',{});
    m.pEdit(tdwpg,'InterruptHandlingTime','WriterChIf','10e-6',pcbfalse,{},{});
    m.pEdit(tdwpg,'BufferEventID','WriterChIf','NOT_USED',pcbfalse,{'Evaluate','off'},{});

    tdrpg=m.dcGroup(tdpp,'ToDeleteReaderGroup',{});
    m.pEdit(tdrpg,'BufferLength','ReaderChIf','NOT_USED',pcbfalse,{'Evaluate','off'},{});
    m.pEdit(tdrpg,'InterruptHandlingTime','ReaderChIf','10e-6',pcbfalse,{},{});
    m.pEdit(tdrpg,'BufferEventID','ReaderChIf','NOT_USED',pcbfalse,{'Evaluate','off'},{});

end
function l_createMemoryChannelBlockCallbacks(blkPath,maskcb)
    cblist={'CopyFcn','DeleteFcn','InitFcn','LoadFcn','PreSaveFcn','UndoDeleteFcn'};

    l_setCallbacks(blkPath,maskcb,cblist);
end


function l_createMemoryTrafficGeneratorMask(m)

    m.top.Initialization=...
    ['blkH = gcbh;',newline,...
    'blkDP = ',m.maskcb,'(''MaskInitFcnGetDerivedInfo'',blkH);',newline,...
    m.maskcb,'(''MaskInitFcnSetDerivedInfo'',blkH);',newline];

    m.top.Type='Memory Traffic Generator';

    ptagnull='';
    pcbtrue=true;
    pcbfalse=false;






    gp=m.dcGroup('top','ParametersGroup',{'AlignPrompts','off'});


    m.pPopup(gp,'RequestType','','Writer',pcbfalse,...
    {'Writer','Reader'},{},{});
    m.pEdit(gp,'TotalBurstRequests',ptagnull,'100',pcbfalse,{},{});
    m.pEdit(gp,'BurstSize',ptagnull,'256',pcbtrue,{},{});
    m.dcText(gp,'BurstLengthText',ptagnull,{});
    m.pEdit(gp,'TimeBetweenBursts',ptagnull,'1e-6',pcbfalse,{},{});
    m.pCheckbox(gp,'AllowSimOnlyParameters',ptagnull,'on',pcbtrue,{},{});
    sopg=m.dcGroup(gp,'SimOnlyParamGroup',{'Visible','on','AlignPrompts','off'});
    m.pEdit(sopg,'FirstBurstTime',ptagnull,'10e-6',pcbfalse,{},{});
    m.pEdit(sopg,'MinMaxTimeBetweenBursts',ptagnull,'[1e-6 1e-6]',pcbfalse,{},{});
    m.pCheckbox(sopg,'WaitForDone',ptagnull,'off',pcbfalse,{'Evaluate','on'},{});
    m.pCheckbox(sopg,'EnableAssertion',ptagnull,'on',pcbfalse,{'Evaluate','on'},{});





    hpp=m.dcCollapsiblePanel(gp,'HiddenParametersPanel',{'Visible','off'});

    m.pEdit(hpp,'ControllerDataWidth',ptagnull,'64',pcbfalse,{'Prompt','Data width'},...
    {'Tooltip','codertarget:ui:FPGADesignAXIMemorySubsystemDataWidthToolTip'});
    m.pEdit(hpp,'BurstLength',ptagnull,'32',pcbfalse,{},{});
    m.pEdit(hpp,'BurstInterAccessTimes',ptagnull,'[10e-6 1e-6 1e-6]',pcbfalse,{},{});

end
function l_createMemoryTrafficGeneratorBlockCallbacks(blkPath,maskcb)
    cblist={'CopyFcn','InitFcn','LoadFcn','PreSaveFcn'};
    l_setCallbacks(blkPath,maskcb,cblist);
end




function l_setCallbacks(blkPath,maskcb,cblist)


    allblkcbs={'ClipboardFcn','CloseFcn','ContinueFcn','CopyFcn','DeleteChildFcn','DeleteFcn','DestroyFcn','InitFcn','LoadFcn','ModelCloseFcn','MoveFcn','NameChangeFcn','OpenFcn','ParentCloseFcn','PauseFcn','PostSaveFcn','PreCopyFcn','PreDeleteFcn','PreSaveFcn','StartFcn','StopFcn','UndoDeleteFcn'};
    for func=allblkcbs
        if contains(func{1},cblist)
            set_param(blkPath,func{1},[maskcb,'(''',func{1},''',gcbh);']);
        else
            set_param(blkPath,func{1},'');
        end
    end
end

function l_setBlockIcon(m,blkPath,blkProgName)
    m.top.IconOpaque='opaque-with-ports';
    soc.internal.setBlockIcon(blkPath,['socicons.',blkProgName]);
end