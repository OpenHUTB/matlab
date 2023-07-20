function varargout=MemoryChannelCbV1(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end
function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    hsb.blkcb2.cbutils('MaskParamCb',paramName,blkH,cbH)
end
function MaskLinkCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    cbH(blkH);
end




function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memch');
end

function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    sysH=bdroot(blkH);

    hsb.blkcb2.defineTypes(sysH);

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInitErrorCheck',blkPath);

    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);



    [blkDP,~]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
    'on',blkP,...
    {'MemChDiagLevel'},{'DiagnosticLevel'});


    splitDiag=split(blkP.DiagnosticLevel,'.');
    blkP.DiagnosticLevel=splitDiag{1};
    if(strcmp(blkDP.DiagnosticLevel,'No debug')&&~strcmp(blkP.DiagnosticLevel,'No debug'))||...
        (~strcmp(blkDP.DiagnosticLevel,'No debug')&&strcmp(blkP.DiagnosticLevel,'No debug'))
        msg=message('soc:msgs:DiagLevelMismatch',blkDP.DiagnosticLevel,blkP.DiagnosticLevel);
        error(msg);
    end


    try
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.memcsP);
    catch
    end
    try
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.maskP);
    catch
    end

end

function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function CopyFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memch');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'memch','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'memch','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'memch','No debug','No debug')
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memch');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'memch','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'memch','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'memch','No debug','No debug')
        end
    end
end



function blkDP=MaskInitFcnGetDerivedInfo(blkH)%#ok<*DEFNU>
    blkDP=struct();
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    sysH=bdroot(blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    if strcmp(blkP.Beta2Compatible,'on')
        error('(internal) The block is marked as being in Beta2 mode!')
    end

    try


        pcslist=hsb.blkcb2.cbutils('MemChConfigSetParamNames');
        pblist=hsb.blkcb2.cbutils('MemChBlockParamNames');







        [blkDP.memcsP,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'off',blkP,...
        pcslist,pblist);
        [blkDP.maskP,blkP]=l_getDerivedMaskValues(blkH,sysH,blkP,blkPath);



        l_update_subsystem_ports(blkH,blkPath,sysH,blkDP.maskP);



        masterID=1;
        [blkDP.wciP,blkDP.wsmP,blkDP.wmicP,blkP]=l_getDerivedParameters(MasterKindEnum.Writer,blkP,masterID);

        masterID=2;
        [blkDP.rciP,blkDP.rsmP,blkDP.rmicP,blkP]=l_getDerivedParameters(MasterKindEnum.Reader,blkP,masterID);

        if strcmp(blkP.ChannelType,'AXI4 Random Access')
            blkP.ICDataWidthWriter=blkDP.wciP.ChTDATAWidth;
            blkDP.memcsP.ICDataWidthWriter=blkDP.wciP.ChTDATAWidth;
            blkP.ICDataWidthReader=blkDP.rciP.ChTDATAWidth;
            blkDP.memcsP.ICDataWidthReader=blkDP.rciP.ChTDATAWidth;
        end


        l_errorChecks(blkH,blkP,blkDP);

        hadError=false;

    catch ME
        hadError=true;
        rethrow(ME);
    end

end

function MaskInitFcnSetDerivedInfo(blkH)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    sysH=bdroot(blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    if strcmp(blkP.Beta2Compatible,'on')
        error('(internal) The block is marked as being in Beta2 mode!')
    end

    try

        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.memcsP);
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.maskP);



        subBlks=l_getSubBlocks(blkPath);
        l_setSubBlockVariants(...
        subBlks,...
        blkP.blkDP.maskP.ProtocolWriter,...
        blkP.blkDP.maskP.ProtocolReader,...
''...
        );
        hadError=false;

    catch ME
        hadError=true;
        rethrow(ME);
    end

    soc.internal.setBlockIcon(blkH,'socicons.MemoryChannel');


end

function MaskInitFcnMasterWriter(blkH)%#ok<*DEFNU>
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    subBlk=sprintf('%s/burstReqGate',blkPath);

    switch blkP.MasterSim
    case 'on'
        burstReqVariant='passthrough';
    case 'off'
        burstReqVariant='bypass';
    end

    set_param(subBlk,'LabelModeActiveChoice',burstReqVariant);
end

function MaskInitFcnMasterReader(blkH)%#ok<*DEFNU>
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    subBlk=sprintf('%s/burstReqGate',blkPath);

    switch blkP.MasterSim
    case 'on'
        burstReqVariant='passthrough';
    case 'off'
        burstReqVariant='bypass';
    end

    set_param(subBlk,'LabelModeActiveChoice',burstReqVariant);
end




function HardwareBoardLinkCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        cs=getActiveConfigSet(bdroot(blkH));
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        configset.showParameterGroup(cs,{'Hardware Implementation'});
        badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockGetParam',blkPath);
        if~badTargetWarn
            configset.showParameterGroup(cs,{'Hardware Implementation','Target hardware resources','FPGA design (mem channels)'});
        end
    end
end

function ShowImplementationInfoLinkCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        hdrTextCell={
'The following parameter values are related to the'
'implementation of the writer and reader datapaths.'
'ChTDATAWidth: bitwidth of the data, padded to power of 2.'
'BurstSize: number of bytes in a burst.'
'EntityInflowTime: time between bursts for framed data.'
' '
'See the ''Help'' for more details on the relationship'
'of the mask parameters and these derived parameters'
'to the datapath implementation.'
        };
        hdrTextStr=sprintf('%s\n',hdrTextCell{:});


        ciP={'ChLength','ChTDATAWidth','BurstSize','EntityInflowTime'};
        smP={'BufferLengthInBursts'};
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        wciV=cellfun(@(x)(blkP.blkDP.wciP.(x)),ciP,'UniformOutput',false);
        wsmV=cellfun(@(x)(blkP.blkDP.wsmP.(x)),smP,'UniformOutput',false);
        wInfo=cell2struct([wciV,wsmV],[ciP,smP],2);%#ok<NASGU>
        rciV=cellfun(@(x)(blkP.blkDP.rciP.(x)),ciP,'UniformOutput',false);
        rsmV=cellfun(@(x)(blkP.blkDP.rsmP.(x)),smP,'UniformOutput',false);
        rInfo=cell2struct([rciV,rsmV],[ciP,smP],2);%#ok<NASGU>
        infoText=sprintf('%s\nWriter:\n%s\n\nReader:\n%s\n',...
        hdrTextStr,evalc('disp(wInfo)'),evalc('disp(rInfo)'));
        msgbox(['\fontname{Courier} ',infoText],'Implementation Info',struct('WindowStyle','non-modal','Interpreter','tex'));
    end
end
function LaunchPerformanceAppButtonCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        figName=message('soc:ui:PlotWindowTitle',blkPath).getString();
        figH=findobj(groot,'Name',figName);
        if~isempty(figH)
            figure(figH);
            return;
        else
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            ddBlkPaths=l_getDDBlkPaths(blkPath);
            figH=soc.internal.MemChannelPlot(figName,blkPath,blkP.MRNumBuffers,ddBlkPaths);
            sysH=bdroot(blkH);
            cobj=get_param(sysH,'InternalObject');
            cobj.addlistener('SLGraphicalEvent::CLOSE_MODEL_EVENT',@(~,~)(l_deleteIfExists(figH)));
        end
    end
end
function l_deleteIfExists(figH)
    if isa(figH,'soc.internal.MemChannelPlot')
        delete(figH);
    end
end
function ddBlkPaths=l_getDDBlkPaths(blkPath)
    blkH=get_param(blkPath,'Handle');
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    subBlks=l_getSubBlocks(blkPath);
    namesDDMasters={'Writer','Reader'};
    ddLength=length(namesDDMasters);
    ddBlkPaths=cell(1,ddLength);
    for ii=1:ddLength
        ddBlkPaths{ii}=sprintf('%s/%s/Bus Selector',subBlks.ddBlk,namesDDMasters{ii});
    end
end

function[vis,ens]=ChannelTypeCb(blkH,val,vis,ens,idxMap)
    burstvis='on';
    fifovis='on';
    clockvis='on';
    hwbsetvis='on';
    rdwrsamevis='on';
    switch val
    case 'AXI4-Stream to Software via DMA'
        wval='AXI4-Stream';rval='AXI4-Stream Software';rdwrsamevis='off';
    case 'AXI4-Stream FIFO'
        wval='AXI4-Stream';rval='AXI4-Stream';
    case 'AXI4-Stream Video FIFO'
        wval='AXI4-Stream Video';rval='AXI4-Stream Video';
    case 'AXI4-Stream Video Frame Buffer'
        wval='AXI4-Stream Video';rval='AXI4-Stream Video with Frame Sync';
    case 'AXI4 Random Access'
        wval='AXI4';rval='AXI4';
        burstvis='off';fifovis='off';clockvis='off';hwbsetvis='off';rdwrsamevis='off';
    case 'Software to AXI4-Stream via DMA'
        wval='AXI4-Stream Software';rval='AXI4-Stream';rdwrsamevis='off';
    otherwise
        error('(internal) illegal channel type');
    end

    [vis,ens]=UseValuesFromTargetHardwareResourcesCb(blkH,'off',vis,ens,idxMap);

    [vis,ens]=ProtocolWriterCb(blkH,wval,vis,ens,idxMap);
    [vis,ens]=ProtocolReaderCb(blkH,rval,vis,ens,idxMap);

    mobj=Simulink.Mask.get(blkH);
    tabc=mobj.getDialogControl('TabContainer');
    mwt=tabc.getDialogControl('MainTab');
    app=mwt.getDialogControl('AdvancedParametersPanel');
    burst=app.getDialogControl('BurstLengthGroup');
    burst.Visible=burstvis;
    fifo=app.getDialogControl('FIFODepthRowHdr');
    fifo.Visible=fifovis;
    fifoa=app.getDialogControl('FIFOAFullDepthRowHdr');
    fifoa.Visible=fifovis;
    clock=app.getDialogControl('ICClockFrequencyRowHdr');
    clock.Visible=clockvis;
    hwbset=app.getDialogControl('UseHardwareBoardSettingsPanel');
    hwbset.Visible=hwbsetvis;
    rdwrsame=app.getDialogControl('ReaderWriterUseSameValuesPanel');
    rdwrsame.Visible=rdwrsamevis;
end

function[vis,ens]=OutSigSpecMatchesInSigSpecCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>

    if strcmp(val,'on')
        nval='off';
    else
        nval='on';
    end

    vis{idxMap('ChFrameSampleTimeReaderChIf')}='off';
    vis{idxMap('ChDimensionsReaderChIf')}=nval;
    vis{idxMap('ChTypeWithInhReaderChIf')}=nval;
    vis{idxMap('ChBitPackedReaderChIf')}=nval;
    vis{idxMap('ChSampleTimeOffsetReaderChIf')}=nval;

    pr=get_param(blkH,'ChannelType');
    switch pr
    case 'AXI4 Random Access'
        vis{idxMap('ChFrameSampleTimeReaderChIf')}=nval;
        vis{idxMap('ChSampleTimeOffsetReaderChIf')}='off';

    case 'Software to AXI4-Stream via DMA'
        vis{idxMap('ChFrameSampleTimeReaderChIf')}='on';
        vis{idxMap('ChSampleTimeOffsetReaderChIf')}='off';

    case 'AXI4-Stream to Software via DMA'
        vis{idxMap('ChBitPackedReaderChIf')}='off';
        vis{idxMap('ChSampleTimeOffsetReaderChIf')}='off';
    end

end

function[vis,ens]=ReaderWriterUseSameValuesCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>

    if strcmp(val,'on')visval='off';else visval='on';end

    if strcmp(get_param(blkH,'ChannelType'),'AXI4-Stream to Software via DMA')visval='off';end
    if strcmp(get_param(blkH,'ChannelType'),'Software to AXI4-Stream via DMA')visval='on';end
    if strcmp(get_param(blkH,'ChannelType'),'AXI4 Random Access')visval='off';end

    plist={'ICClockFrequencyReader',...
    'ICDataWidthReader',...
    'FIFODepthReader',...
    'FIFOAFullDepthReader'};

    for p=plist
        vis{idxMap(p{1})}=visval;
    end

    if strcmp(get_param(blkH,'ChannelType'),'AXI4 Random Access')
        vis{idxMap('ICDataWidthReader')}='on';
    end

end

function[vis,ens]=ProtocolWriterCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>

    pixvis='off';
    burstvis='on';
    fifovis='on';
    clockvis='on';
    datavis='on';
    wrstimevis='on';
    wrbitpackvis='on';

    switch(val)
    case 'AXI4-Stream'

    case 'AXI4-Stream Video'
        pixvis='on';
    case 'AXI4'
        burstvis='off';fifovis='off';clockvis='off';
    case 'AXI4-Stream Software'
        burstvis='off';fifovis='off';clockvis='off';datavis='off';
        wrstimevis='off';wrbitpackvis='off';
    otherwise

    end
    vis{idxMap('InsertInactivePixelClocksReaderChIf')}=pixvis;
    vis{idxMap('BurstLengthWriterChIf')}=burstvis;
    vis{idxMap('FIFODepthWriter')}=fifovis;
    vis{idxMap('FIFOAFullDepthWriter')}=fifovis;
    vis{idxMap('ICClockFrequencyWriter')}=clockvis;
    vis{idxMap('ICDataWidthWriter')}=datavis;
    vis{idxMap('ChFrameSampleTimeWriterChIf')}=wrstimevis;
    vis{idxMap('ChBitPackedWriterChIf')}=wrbitpackvis;


    [vis,ens]=InsertInactivePixelClocksReaderChIfCb(blkH,get_param(blkH,'InsertInactivePixelClocksReaderChIf'),vis,ens,idxMap);
end

function[vis,ens]=ProtocolReaderCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>

    pixvis='off';
    burstvis='on';

    switch(val)
    case 'AXI4-Stream'

    case{'AXI4-Stream Video','AXI4-Stream Video with Frame Sync'}
        pixvis='on';
    case 'AXI4'
        burstvis='off';
    case 'AXI4-Stream Software'
        burstvis='off';
    otherwise

    end
    vis{idxMap('InsertInactivePixelClocksReaderChIf')}=pixvis;
    vis{idxMap('BurstLengthReaderChIf')}=burstvis;

    [vis,ens]=ReaderWriterUseSameValuesCb(blkH,get_param(blkH,'ReaderWriterUseSameValues'),vis,ens,idxMap);
    [vis,ens]=OutSigSpecMatchesInSigSpecCb(blkH,get_param(blkH,'OutSigSpecMatchesInSigSpec'),vis,ens,idxMap);
    [vis,ens]=InsertInactivePixelClocksReaderChIfCb(blkH,get_param(blkH,'InsertInactivePixelClocksReaderChIf'),vis,ens,idxMap);
end
function[vis,ens]=InsertInactivePixelClocksReaderChIfCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>
    pixelClockVis=vis{idxMap('InsertInactivePixelClocksReaderChIf')};
    switch pixelClockVis
    case 'on',fsizeVis=val;
    case 'off',fsizeVis='off';
    end
    vis{idxMap('FrameSizeReaderChIf')}=fsizeVis;
end

function[vis,ens]=UseValuesFromTargetHardwareResourcesCb(blkH,val,vis,ens,idxMap)




    if strcmp(get_param(blkH,'ChannelType'),'AXI4 Random Access')
        enval='off';
    else
        enval='on';
    end

    pblist=hsb.blkcb2.cbutils('MemChBlockParamNames');
    ens{idxMap('ReaderWriterUseSameValues')}=enval;
    for p=pblist
        ens{idxMap(p{1})}=enval;
    end

end

function[vis,ens]=EnableMemSimCb(blkH,val,vis,ens,idxMap)

    mobj=Simulink.Mask.get(blkH);
    tabc=mobj.getDialogControl('TabContainer');
    mwt=tabc.getDialogControl('MainTab');
    adv=mwt.getDialogControl('AdvancedParametersPanel');
    adv.Visible=val;

    perft=tabc.getDialogControl('PerformanceTab');
    perft.Visible=val;

end




function[wval,rval]=l_ChannelTypeToProtocol(val)
    switch val
    case 'AXI4-Stream to Software via DMA'
        wval='AXI4-Stream';rval='AXI4-Stream Software';
    case 'AXI4-Stream FIFO'
        wval='AXI4-Stream';rval='AXI4-Stream';
    case 'AXI4-Stream Video FIFO'
        wval='AXI4-Stream Video';rval='AXI4-Stream Video';
    case 'AXI4-Stream Video Frame Buffer'
        wval='AXI4-Stream Video';rval='AXI4-Stream Video with Frame Sync';
    case 'AXI4 Random Access'
        wval='AXI4';rval='AXI4';
    case 'Software to AXI4-Stream via DMA'
        wval='AXI4-Stream Software';rval='AXI4-Stream';
    otherwise
        error('(internal) illegal channel type');
    end
end

function s=l_getSubBlocks(blkPath)
    s.wctrlInPort=sprintf('%s/wrCtrlIn',blkPath);
    s.wctrlOutPort=sprintf('%s/wrCtrlOut',blkPath);
    s.wdonePort=sprintf('%s/wrDone',blkPath);
    s.weventPort=sprintf('%s/wrEvent',blkPath);
    s.wciBlk=sprintf('%s/Writer 1/To Memory Channel',blkPath);
    s.wbdBlk=sprintf('%s/Writer 1/bufDoneGate',blkPath);
    s.wbrBlk=sprintf('%s/Writer 1/bufReqGate',blkPath);
    s.wmicBlk=sprintf('%s/Writer 1/Master Writer',blkPath);
    s.rctrlInPort=sprintf('%s/rdCtrlIn',blkPath);
    s.rctrlOutPort=sprintf('%s/rdCtrlOut',blkPath);
    s.rdonePort=sprintf('%s/rdDone',blkPath);
    s.reventPort=sprintf('%s/rdEvent',blkPath);
    s.rciBlk=sprintf('%s/Reader 1/From Memory Channel',blkPath);
    s.rbdBlk=sprintf('%s/Reader 1/bufDoneGate',blkPath);
    s.rmicBlk=sprintf('%s/Reader 1/Master Reader',blkPath);
    s.mrcBlk=sprintf('%s/Memory Region Controller',blkPath);
    s.mrsBlk=sprintf('%s/Memory Region Storage',blkPath);
    s.ddBlk=sprintf('%s/log',blkPath);

end


function l_setSubBlockVariants(sub,protoWr,protoRd,dlevel)
    l_setProtocolWriterInterface(protoWr,sub.wciBlk,sub.wbdBlk,sub.wbrBlk,sub.wctrlInPort,sub.wctrlOutPort,sub.wdonePort,sub.weventPort);
    l_setProtocolReaderInterface(protoRd,sub.rciBlk,sub.rbdBlk,sub.rctrlInPort,sub.rctrlOutPort,sub.rdonePort,sub.reventPort);

end
function l_setProtocolWriterInterface(protocol,block,bufdone,bufreq,ctrlInPort,ctrlOutPort,donePort,eventPort)
    switch protocol
    case 'AXI4-Stream'
        blockVariant='StreamingToMemory_Variant';
        ctrlInType='Bus: StreamM2SBusObj';
        ctrlOutType='Bus: StreamS2MBusObj';
    case 'AXI4-Stream Video'
        blockVariant='StreamingVideoToMemory_Variant';
        ctrlInType='Bus: pixelcontrol';
        ctrlOutType='Bus: StreamVideoS2MBusObj';
    case 'AXI4'
        blockVariant='AddressableToMemory_Variant';
        ctrlInType='Bus: WriteControlM2SBusObj';
        ctrlOutType='Bus: WriteControlS2MBusObj';
    case 'AXI4-Stream Software'
        blockVariant='SoftwareStreamingToMemory_Variant';
        donePortType='boolean';
        eventPortType='Bus: rteEvent';
    end

    switch protocol
    case 'AXI4-Stream Software'
        set_param(donePort,'OutDataTypeStr',donePortType);
        set_param(eventPort,'OutDataTypeStr',eventPortType);
        bufDoneVariant='async';
        bufReqVariant='async';
    otherwise
        set_param(ctrlInPort,'OutDataTypeStr',ctrlInType);
        set_param(ctrlOutPort,'OutDataTypeStr',ctrlOutType);
        bufDoneVariant='passthrough';
        bufReqVariant='passthrough';
    end

    set_param(block,'LabelModeActiveChoice',blockVariant);
    set_param(bufdone,'LabelModeActiveChoice',bufDoneVariant);
    set_param(bufreq,'LabelModeActiveChoice',bufReqVariant);
end

function l_setProtocolReaderInterface(protocol,block,bufdone,ctrlInPort,ctrlOutPort,donePort,eventPort)
    switch protocol
    case 'AXI4-Stream'
        blockVariant='StreamingFromMemory_Variant';
        ctrlInType='Bus: StreamS2MBusObj';
        ctrlOutType='Bus: StreamM2SBusObj';
    case 'AXI4-Stream Video'
        blockVariant='StreamingVideoFromMemory_Variant';
        ctrlInType='Bus: StreamVideoS2MBusObj';
        ctrlOutType='Bus: pixelcontrol';
    case 'AXI4-Stream Video with Frame Sync'
        blockVariant='StreamingVideoFromMemoryWithFsync_Variant';
        ctrlInType='Bus: StreamVideoFsyncS2MBusObj';
        ctrlOutType='Bus: pixelcontrol';
    case 'AXI4'
        blockVariant='AddressableFromMemory_Variant';
        ctrlInType='Bus: ReadControlM2SBusObj';
        ctrlOutType='Bus: ReadControlS2MBusObj';
    case 'AXI4-Stream Software'
        blockVariant='SoftwareStreamingFromMemory_Variant';
        donePortType='boolean';
        eventPortType='Bus: rteEvent';
    end

    switch protocol
    case 'AXI4-Stream Software'
        set_param(donePort,'OutDataTypeStr',donePortType);
        set_param(eventPort,'OutDataTypeStr',eventPortType);
        bufDoneVariant='async';
    otherwise
        set_param(ctrlInPort,'OutDataTypeStr',ctrlInType);
        set_param(ctrlOutPort,'OutDataTypeStr',ctrlOutType);
        bufDoneVariant='passthrough';
    end

    set_param(block,'LabelModeActiveChoice',blockVariant);
    set_param(bufdone,'LabelModeActiveChoice',bufDoneVariant);
end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


function[blkDP,blkP]=l_getDerivedMaskValues(blkH,sysH,blkP,blkPath)%#ok<INUSL,INUSD>

    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    dc.Prompt=currBoard;

    if~strcmp(blkP.LastTargetBoard,currBoard)



        blkDP.LastTargetBoard=currBoard;
    end



    [wval,rval]=l_ChannelTypeToProtocol(blkP.ChannelType);
    blkDP.ProtocolWriter=wval;
    blkDP.ProtocolReader=rval;









    dc=mobj.getDialogControl('MRRegionSizeText');
    validateattributes(blkP.MRNumBuffers,{'numeric'},{'positive','integer','scalar'},'','NumBuffers');
    validateattributes(blkP.MRBufferSize,{'numeric'},{'positive','integer','scalar'},'','BufferSize');
    regionSize=blkP.MRNumBuffers*blkP.MRBufferSize;
    blkDP.MRRegionSize=regionSize;
    dc.Prompt=['Region size:  ',num2str(regionSize)];




    validateattributes(blkP.ChDimensionsReaderChIf,{'numeric'},{'positive','integer'},'','ChDimensionsReaderChIf');
    validateattributes(blkP.ChDimensionsWriterChIf,{'numeric'},{'positive','integer'},'','ChDimensionsWriterChIf');
    if isempty(blkP.ChFrameSampleTimeWriterChIf)
        blkP.ChFrameSampleTimeWriterChIf=NaN;
    end
    if isempty(blkP.ChFrameSampleTimeReaderChIf)
        blkP.ChFrameSampleTimeReaderChIf=NaN;
    end

    try
        validateattributes(blkP.ChFrameSampleTimeWriterChIf,{'numeric'},{'row'});
        if numel(blkP.ChFrameSampleTimeWriterChIf)>2,throw();end
        validateattributes(blkP.ChFrameSampleTimeWriterChIf(1),{'numeric'},{'positive'});
        if numel(blkP.ChFrameSampleTimeWriterChIf)>1
            validateattributes(blkP.ChFrameSampleTimeWriterChIf(2),{'numeric'},{'nonnegative','<',blkP.ChFrameSampleTimeWriterChIf(1)});
        end
    catch
        error(message('Simulink:SampleTime:InvTsParamSetting_Vector',blkPath,'Writer Sample Time'));
    end

    try
        validateattributes(blkP.ChFrameSampleTimeReaderChIf,{'numeric'},{'row'});
        if numel(blkP.ChFrameSampleTimeReaderChIf)>2,throw();end
        validateattributes(blkP.ChFrameSampleTimeReaderChIf(1),{'numeric'},{'positive'});
        if numel(blkP.ChFrameSampleTimeReaderChIf)>1
            validateattributes(blkP.ChFrameSampleTimeReaderChIf(2),{'numeric'},{'nonnegative','<',blkP.ChFrameSampleTimeReaderChIf(1)});
        end
    catch
        error(message('Simulink:SampleTime:InvTsParamSetting_Vector',blkPath,'Reader Sample Time'));
    end



    if strcmp(blkP.OutSigSpecMatchesInSigSpec,'on')
        blkDP.ChTypeReaderChIf=blkP.ChTypeWriterChIf;
    else
        if strcmp(blkP.ChTypeWithInhReaderChIf,'Inherit: Same as input')
            blkDP.ChTypeReaderChIf=blkP.ChTypeWriterChIf;
        else
            blkDP.ChTypeReaderChIf=blkP.ChTypeWithInhReaderChIf;
        end
    end



    if strcmp(blkP.OutSigSpecMatchesInSigSpec,'on')
        blkDP.ChDimensionsReaderChIf=blkP.ChDimensionsWriterChIf;
        locChDimRd=blkDP.ChDimensionsReaderChIf;
    else
        locChDimRd=blkP.ChDimensionsReaderChIf;




    end



    switch blkP.ChannelType
    case 'Software to AXI4-Stream via DMA'
        blkDP.ChBitPackedWriterChIf='off';
        if strcmp(blkP.OutSigSpecMatchesInSigSpec,'on')
            blkDP.ChBitPackedReaderChIf=blkDP.ChBitPackedWriterChIf;
        else
            blkDP.ChBitPackedReaderChIf=blkP.ChBitPackedReaderChIf;
        end

    case 'AXI4-Stream to Software via DMA'
        blkDP.ChBitPackedWriterChIf=blkP.ChBitPackedWriterChIf;
        if strcmp(blkP.OutSigSpecMatchesInSigSpec,'on')
            blkDP.ChBitPackedReaderChIf=blkDP.ChBitPackedWriterChIf;
        else
            blkDP.ChBitPackedReaderChIf='off';
        end

    otherwise
        blkDP.ChBitPackedWriterChIf=blkP.ChBitPackedWriterChIf;
        if strcmp(blkP.OutSigSpecMatchesInSigSpec,'on')
            blkDP.ChBitPackedReaderChIf=blkDP.ChBitPackedWriterChIf;
        else
            blkDP.ChBitPackedReaderChIf=blkP.ChBitPackedReaderChIf;
        end
    end



    [rdChLength,rdChCompLength,~]=hsb.blkcb2.cbutils('GetChLength',locChDimRd,blkDP.ChBitPackedReaderChIf);
    [wrChLength,wrChCompLength,~]=hsb.blkcb2.cbutils('GetChLength',blkP.ChDimensionsWriterChIf,blkDP.ChBitPackedWriterChIf);
    [~,~,~,~,rdChTDATASize]=hsb.blkcb2.cbutils('GetChWidths',blkDP.ChTypeReaderChIf,rdChCompLength);
    [~,~,~,~,wrChTDATASize]=hsb.blkcb2.cbutils('GetChWidths',blkP.ChTypeWriterChIf,wrChCompLength);



    if strcmp(blkP.OutSigSpecMatchesInSigSpec,'on')&&~strcmp(blkP.ChannelType,'Software to AXI4-Stream via DMA')
        blkDP.ChFrameSampleTimeReaderChIf=blkP.ChFrameSampleTimeWriterChIf;
        blkDP.ChSampleTimeOffsetReaderChIf='on';
    else
        frameForPixelTiming='';
        calcSt=NaN;
        offsetRd=0;
        offsetWr=0;
        if numel(blkP.ChFrameSampleTimeReaderChIf)>1
            offsetRd=blkP.ChFrameSampleTimeReaderChIf(2);
        end
        if numel(blkP.ChFrameSampleTimeWriterChIf)>1
            offsetWr=blkP.ChFrameSampleTimeWriterChIf(2);
        end

        switch blkP.ChannelType
        case{'Software to AXI4-Stream via DMA'}
            calcSt=blkP.ChFrameSampleTimeReaderChIf(1)*((wrChLength*wrChTDATASize)/(rdChLength*rdChTDATASize));
            if~isnan(calcSt)
                blkDP.ChFrameSampleTimeWriterChIf=[calcSt,offsetRd];
            end
        case{'AXI4-Stream to Software via DMA'}
            calcSt=blkP.ChFrameSampleTimeWriterChIf(1)*((rdChLength*rdChTDATASize)/(wrChLength*wrChTDATASize));
            if~isnan(calcSt)
                blkDP.ChFrameSampleTimeReaderChIf=[calcSt,offsetWr];
            end
        case{'AXI4-Stream FIFO'}
            calcSt=blkP.ChFrameSampleTimeWriterChIf(1)*((rdChLength*rdChTDATASize)/(wrChLength*wrChTDATASize));
            if~isnan(calcSt)
                if strcmp(blkP.ChSampleTimeOffsetReaderChIf,'on')
                    blkDP.ChFrameSampleTimeReaderChIf=[calcSt,offsetWr];
                else
                    blkDP.ChFrameSampleTimeReaderChIf=[calcSt,0];
                end
            end
        case{'AXI4 Random Access'}
            calcSt=NaN;
        case{'AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer'}
            fspEn='off';
            if strcmp(blkP.InsertInactivePixelClocksReaderChIf,'on')
                if(wrChLength>rdChLength)&&rdChLength==1
                    [pcc,fname]=hsb.blkcb2.cbutils('GetPixelClockCount',wrChLength);
                    if(pcc==0)
                        error(message('soc:msgs:PixelClockUnknownFrameDimension'));
                    else
                        calcSt=blkP.ChFrameSampleTimeWriterChIf(1)/pcc;
                        frameForPixelTiming=fname;
                    end
                elseif(rdChLength>wrChLength)&&wrChLength==1
                    [pcc,fname]=hsb.blkcb2.cbutils('GetPixelClockCount',rdChLength);
                    if(pcc==0)
                        error(message('soc:msgs:PixelClockUnknownFrameDimension'));
                    else
                        calcSt=blkP.ChFrameSampleTimeWriterChIf(1)*pcc;
                        frameForPixelTiming=fname;
                    end
                elseif rdChLength==1&&wrChLength==1
                    calcSt=blkP.ChFrameSampleTimeWriterChIf(1);
                    switch blkP.ChannelType
                    case 'AXI4-Stream Video FIFO'

                        fspEn='on';
                    case 'AXI4-Stream Video Frame Buffer'
                        activePixels=round(blkP.MRBufferSize/rdChTDATASize);
                        [pcc,fname]=hsb.blkcb2.cbutils('GetPixelClockCount',activePixels);
                        if(pcc==0)
                            error(message('soc:msgs:PixelClockBadFrameBufferSize'));
                        else
                            frameForPixelTiming=fname;
                        end
                    end
                else
                    error(message('soc:msgs:PixelClockNoScalarDimension'));
                end
            else


                fspEn='off';
                calcSt=blkP.ChFrameSampleTimeWriterChIf(1)*(rdChLength/wrChLength);
            end
            if~isnan(calcSt)
                if strcmp(blkP.ChSampleTimeOffsetReaderChIf,'on')
                    blkDP.ChFrameSampleTimeReaderChIf=[calcSt,offsetWr];
                else
                    blkDP.ChFrameSampleTimeReaderChIf=[calcSt,0];
                end
            end

            if~isempty(frameForPixelTiming)
                blkDP.FrameSizeReaderChIf=frameForPixelTiming;
            end
            mobj=Simulink.Mask.get(blkH);
            fsp=mobj.getParameter('FrameSizeReaderChIf');
            fsp.Enabled=fspEn;
        otherwise
            error('(internal) bad reader protocol');
        end
    end



    if strcmp(blkP.EnableMemSim,'off')
        switch blkP.ChannelType
        case{'Software to AXI4-Stream via DMA'}
            blkP.BurstLengthWriterChIf=blkP.MRBufferSize/wrChTDATASize;
            blkP.BurstLengthReaderChIf=blkP.MRBufferSize/rdChTDATASize;
        case{'AXI4-Stream to Software via DMA'}
            blkP.BurstLengthReaderChIf=blkP.MRBufferSize/rdChTDATASize;
            blkP.BurstLengthWriterChIf=blkP.MRBufferSize/wrChTDATASize;
        case{'AXI4-Stream FIFO'}
            blkP.BurstLengthReaderChIf=blkP.MRBufferSize/rdChTDATASize;
            blkP.BurstLengthWriterChIf=blkP.MRBufferSize/wrChTDATASize;
        case{'AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer'}
            blkP.BurstLengthReaderChIf=blkP.MRBufferSize/rdChTDATASize;
            blkP.BurstLengthWriterChIf=blkP.MRBufferSize/wrChTDATASize;
        case{'AXI4 Random Access'}
            ;
        otherwise
            error('(internal) bad reader protocol');
        end
    end


    if strcmp(get_param(blkH,'ChannelType'),'AXI4-Stream to Software via DMA')blkP.ReaderWriterUseSameValues='on';end
    if strcmp(get_param(blkH,'ChannelType'),'Software to AXI4-Stream via DMA')blkP.ReaderWriterUseSameValues='off';end
    if strcmp(get_param(blkH,'ChannelType'),'AXI4 Random Access')blkP.ReaderWriterUseSameValues='off';end

    if strcmp(blkP.ReaderWriterUseSameValues,'on')
        pblkNames={'ICClockFrequency',...
        'ICDataWidth',...
        'FIFODepth',...
        'FIFOAFullDepth'};
        for ii=1:length(pblkNames)
            blkDP.([pblkNames{ii},'Reader'])=blkP.([pblkNames{ii},'Writer']);
        end
    end


    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',blkDP,blkP);
end

function[ciP,smP,micP,blkP]=l_getDerivedParameters(masterKind,blkP,masterID)



    switch masterKind
    case MasterKindEnum.Writer
        blkP.BufferLengthWriterChIf=0;
        errtag='writer';
    case MasterKindEnum.Reader
        errtag='reader';
    end
    [ciP,smP,micP]=hsb.blkcb2.cbutils('DeriveMemChParams',blkP,masterKind,masterID);


    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',ciP,blkP);
    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',smP,blkP);
    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',micP,blkP);
end


function l_checkConfigSetParams(blkH,blkPath,blkP,wrTDATA,rdTDATA)


    badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockParamCheck',blkPath);




    if badTargetWarn,return;end

    for csp=hsb.blkcb2.cbutils('MemChBlockParamNames')


        depVal=[];
        switch csp{1}
        case 'ICDataWidthWriter',depVal{1}=blkP.ChannelType;depVal{2}=wrTDATA;
        case 'ICDataWidthReader',depVal{1}=blkP.ChannelType;depVal{2}=rdTDATA;
        case 'FIFOAFullDepthWriter',depVal=blkP.FIFODepthWriter;
        case 'FIFOAFullDepthReader',depVal=blkP.FIFODepthReader;
        case 'FIFODepthWriter',depVal{1}=blkP.ChannelType;depVal{2}=blkP.BurstLengthWriterChIf;depVal{3}=wrTDATA;depVal{4}=blkP.FIFOAFullDepthWriter;
        case 'FIFODepthReader',depVal{1}=blkP.ChannelType;depVal{2}=blkP.BurstLengthReaderChIf;depVal{3}=rdTDATA;depVal{4}=blkP.FIFOAFullDepthReader;
        otherwise,depVal=[];
        end
        val=blkP.(csp{1});
        if~isempty(depVal)
            codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'check',csp{1},val,depVal);
        else
            codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'check',csp{1},val);
        end
    end
end

function l_errorChecks(blkH,blkP,blkDP)
    wsmP=blkDP.wsmP;
    rsmP=blkDP.rsmP;


    if~hsb.blkcb2.cbutils('IsIntegerValue',blkP.MRBufferSize)
        marg=sprintf('%g',blkP.MRBufferSize);
        error(message('soc:msgs:BufferSizeNotInt',marg));
    end

    if strcmp(blkP.ChannelType,'AXI4-Stream to Software via DMA')
        rdChTDATASize=blkDP.rciP.ChTDATAWidth/8;
        rdChLength=blkDP.rciP.ChLength;
        rdChDimensions=blkDP.rciP.ChDimensions;
        rdType=blkDP.rciP.ChType;
        rdBitPacked=blkDP.rciP.ChBitPacked;

        switch class(rdType)
        case 'char'
            if~any(strcmp(rdType,{'uint16','uint32','uint64'}))
                error(message('soc:msgs:HWSWDTypeMustBeUint3264',rdType));
            end
        case 'Simulink.NumericType'
            if~((rdType.Signed==0)&&(rdType.FractionLength==0)&&(rdType.WordLength==16||rdType.WordLength==32||rdType.WordLength==64||rdType.WordLength==128))
                error(message('soc:msgs:HWSWDTypeMustBeUint3264',rdType.tostring));
            end
        otherwise
            error(message('soc:msgs:HWSWDTypeMustBeUint3264','unknown'));
        end

        if~isscalar(rdChDimensions)
            error(message('soc:msgs:HWSWDimensionsMustBeScalar',mat2str(rdChDimensions)));
        end

        if rdBitPacked
            error(message('soc:msgs:HWSWBitPackedMustBeOff'));
        end

        expBufSize=rdChTDATASize*rdChLength;
        if expBufSize~=blkP.MRBufferSize
            if~strcmp(class(rdType),'char')
                rdTypeStr=rdType.tostring;
            else
                rdTypeStr=rdType;
            end
            error(message('soc:msgs:HWSWFrameNotEqualBuffer',...
            mat2str(blkP.MRBufferSize),...
            mat2str(blkP.ChDimensionsReaderChIf),...
            rdTypeStr,...
            mat2str(rdChTDATASize),...
            mat2str(expBufSize)...
            ));
        end

        if blkP.MRNumBuffers<3
            error(message('soc:msgs:NumBuffersGTE3',blkP.ChannelType));
        end

        if blkP.MRNumBuffers>64
            error(message('soc:msgs:NumBuffersLSE64',blkP.ChannelType));
        end

        if~isscalar(blkP.FIFODepthWriter)||~isreal(blkP.FIFODepthWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFODepthWriter)||...
            blkP.FIFODepthWriter<2||blkP.FIFODepthWriter>32||...
            ~isequal(2^(nextpow2(blkP.FIFODepthWriter)),blkP.FIFODepthWriter)
            error(message('soc:msgs:ICFIFODepth','Writer',num2str(blkP.FIFODepthWriter)));
        end

        if~isscalar(blkP.FIFOAFullDepthWriter)||~isreal(blkP.FIFOAFullDepthWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFOAFullDepthWriter)||...
            blkP.FIFOAFullDepthWriter<1||blkP.FIFOAFullDepthWriter>blkP.FIFODepthWriter
            error(message('soc:msgs:ICFIFOAFullDepth','Writer',num2str(blkP.FIFOAFullDepthWriter),num2str(blkP.FIFODepthWriter)));
        end

        if~isscalar(blkP.ICDataWidthWriter)||~isreal(blkP.ICDataWidthWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.ICDataWidthWriter)||...
            blkP.ICDataWidthWriter<32||blkP.ICDataWidthWriter>1024||...
            ~isequal(2^(nextpow2(blkP.ICDataWidthWriter)),blkP.ICDataWidthWriter)
            error(message('soc:msgs:ICDataWidth','Writer',num2str(blkP.ICDataWidthWriter)));
        end

        if~isscalar(blkP.ICClockFrequencyWriter)||~isreal(blkP.ICClockFrequencyWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.ICClockFrequencyWriter)||...
            blkP.ICClockFrequencyWriter<10||blkP.ICClockFrequencyWriter>1000
            error(message('soc:msgs:ICClockFrequency','Writer',num2str(blkP.ICClockFrequencyWriter)));
        end
    end

    if strcmp(blkP.ChannelType,'Software to AXI4-Stream via DMA')
        wrChTDATASize=blkDP.wciP.ChTDATAWidth/8;
        wrChLength=blkDP.wciP.ChLength;
        wrChDimensions=blkDP.wciP.ChDimensions;
        wrType=blkDP.wciP.ChType;
        wrBitPacked=blkDP.wciP.ChBitPacked;

        switch class(wrType)
        case 'char'
            if~any(strcmp(wrType,{'uint16','uint32','uint64'}))
                error(message('soc:msgs:SWHWDTypeMustBeUint3264',wrType));
            end
        case 'Simulink.NumericType'
            if~((wrType.Signed==0)&&(wrType.FractionLength==0)&&(wrType.WordLength==16||wrType.WordLength==32||wrType.WordLength==64||wrType.WordLength==64||wrType.WordLength==128))
                error(message('soc:msgs:SWHWDTypeMustBeUint3264',wrType.tostring));
            end
        otherwise
            error(message('soc:msgs:SWHWDTypeMustBeUint3264','unknown'));
        end

        if~isscalar(wrChDimensions)
            error(message('soc:msgs:SWHWDimensionsMustBeScalar',mat2str(wrChDimensions)));
        end

        if wrBitPacked
            error(message('soc:msgs:SWHWBitPackedMustBeOff'));
        end

        expBufSize=wrChTDATASize*wrChLength;
        if expBufSize~=blkP.MRBufferSize
            if~strcmp(class(wrType),'char')
                wrTypeStr=wrType.tostring;
            else
                wrTypeStr=wrType;
            end
            error(message('soc:msgs:SWHWFrameNotEqualBuffer',...
            mat2str(blkP.MRBufferSize),...
            mat2str(blkP.ChDimensionsWriterChIf),...
            wrTypeStr,...
            mat2str(wrChTDATASize),...
            mat2str(expBufSize)...
            ));
        end

        if blkP.MRNumBuffers<3
            error(message('soc:msgs:NumBuffersGTE3',blkP.ChannelType));
        end

        if blkP.MRNumBuffers>64
            error(message('soc:msgs:NumBuffersLSE64',blkP.ChannelType));
        end

        if~isscalar(blkP.FIFODepthReader)||~isreal(blkP.FIFODepthReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFODepthReader)||...
            blkP.FIFODepthReader<2||blkP.FIFODepthReader>32||...
            ~isequal(2^(nextpow2(blkP.FIFODepthReader)),blkP.FIFODepthReader)
            error(message('soc:msgs:ICFIFODepth','Reader',num2str(blkP.FIFODepthReader)));
        end

        if~isscalar(blkP.FIFOAFullDepthReader)||~isreal(blkP.FIFOAFullDepthReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFOAFullDepthReader)||...
            blkP.FIFOAFullDepthReader<1||blkP.FIFOAFullDepthReader>blkP.FIFODepthReader
            error(message('soc:msgs:ICFIFOAFullDepth','Reader',num2str(blkP.FIFOAFullDepthReader),num2str(blkP.FIFODepthReader)));
        end

        if~isscalar(blkP.ICDataWidthReader)||~isreal(blkP.ICDataWidthReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.ICDataWidthReader)||...
            blkP.ICDataWidthReader<32||blkP.ICDataWidthReader>1024||...
            ~isequal(2^(nextpow2(blkP.ICDataWidthReader)),blkP.ICDataWidthReader)
            error(message('soc:msgs:ICDataWidth','Reader',num2str(blkP.ICDataWidthReader)));
        end

        if~isscalar(blkP.ICClockFrequencyReader)||~isreal(blkP.ICClockFrequencyReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.ICClockFrequencyReader)||...
            blkP.ICClockFrequencyReader<10||blkP.ICClockFrequencyReader>1000
            error(message('soc:msgs:ICClockFrequency','Reader',num2str(blkP.ICClockFrequencyReader)));
        end
    end

    if strcmp(blkP.ChannelType,'AXI4-Stream FIFO')||...
        strcmp(blkP.ChannelType,'AXI4-Stream Video FIFO')||...
        strcmp(blkP.ChannelType,'AXI4-Stream Video Frame Buffer')

        if blkP.MRNumBuffers<3
            error(message('soc:msgs:NumBuffersGTE3',blkP.ChannelType));
        end

        if blkP.MRNumBuffers>64
            error(message('soc:msgs:NumBuffersLSE64',blkP.ChannelType));
        end

        if~isscalar(blkP.FIFODepthWriter)||~isreal(blkP.FIFODepthWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFODepthWriter)||...
            blkP.FIFODepthWriter<2||blkP.FIFODepthWriter>32||...
            ~isequal(2^(nextpow2(blkP.FIFODepthWriter)),blkP.FIFODepthWriter)
            error(message('soc:msgs:ICFIFODepth','Writer',num2str(blkP.FIFODepthWriter)));
        end

        if~isscalar(blkP.FIFOAFullDepthWriter)||~isreal(blkP.FIFOAFullDepthWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFOAFullDepthWriter)||...
            blkP.FIFOAFullDepthWriter<1||blkP.FIFOAFullDepthWriter>blkP.FIFODepthWriter
            error(message('soc:msgs:ICFIFOAFullDepth','Writer',num2str(blkP.FIFOAFullDepthWriter),num2str(blkP.FIFODepthWriter)));
        end

        if~isscalar(blkP.FIFODepthReader)||~isreal(blkP.FIFODepthReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFODepthReader)||...
            blkP.FIFODepthReader<2||blkP.FIFODepthReader>32||...
            ~isequal(2^(nextpow2(blkP.FIFODepthReader)),blkP.FIFODepthReader)
            error(message('soc:msgs:ICFIFODepth','Reader',num2str(blkP.FIFODepthReader)));
        end

        if~isscalar(blkP.FIFOAFullDepthReader)||~isreal(blkP.FIFOAFullDepthReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.FIFOAFullDepthReader)||...
            blkP.FIFOAFullDepthReader<1||blkP.FIFOAFullDepthReader>blkP.FIFODepthReader
            error(message('soc:msgs:ICFIFOAFullDepth','Reader',num2str(blkP.FIFOAFullDepthReader),num2str(blkP.FIFODepthReader)));
        end

        if~isscalar(blkP.ICDataWidthWriter)||~isreal(blkP.ICDataWidthWriter)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.ICDataWidthWriter)||...
            blkP.ICDataWidthWriter<32||blkP.ICDataWidthWriter>1024||...
            ~isequal(2^(nextpow2(blkP.ICDataWidthWriter)),blkP.ICDataWidthWriter)
            error(message('soc:msgs:ICDataWidth','Writer',num2str(blkP.ICDataWidthWriter)));
        end

        if~isscalar(blkP.ICDataWidthReader)||~isreal(blkP.ICDataWidthReader)||...
            ~hsb.blkcb2.cbutils('IsIntegerValue',blkP.ICDataWidthReader)||...
            blkP.ICDataWidthReader<32||blkP.ICDataWidthReader>1024||...
            ~isequal(2^(nextpow2(blkP.ICDataWidthReader)),blkP.ICDataWidthReader)
            error(message('soc:msgs:ICDataWidth','Reader',num2str(blkP.ICDataWidthReader)));
        end

        if~isscalar(blkP.ICClockFrequencyWriter)||~isreal(blkP.ICClockFrequencyWriter)||...
            blkP.ICClockFrequencyWriter<1||blkP.ICClockFrequencyWriter>100000
            error(message('soc:msgs:ICClockFrequency','Writer',num2str(blkP.ICClockFrequencyWriter)));
        end

        if~isscalar(blkP.ICClockFrequencyReader)||~isreal(blkP.ICClockFrequencyReader)||...
            blkP.ICClockFrequencyReader<1||blkP.ICClockFrequencyReader>100000
            error(message('soc:msgs:ICClockFrequency','Reader',num2str(blkP.ICClockFrequencyReader)));
        end

    end
    if strcmp(blkP.ChannelType,'AXI4 Random Access')
        wrChTDATAWidth=blkDP.wciP.ChTDATAWidth;
        wrChCompLength=blkDP.wciP.ChCompLength;
        wrChWidth=blkDP.wciP.ChWidth;

        if wrChTDATAWidth<32
            error(message('soc:msgs:ChBitPackedWidthLW32','writer',wrChWidth,wrChCompLength,wrChTDATAWidth));
        end

        rdChTDATAWidth=blkDP.rciP.ChTDATAWidth;
        rdChCompLength=blkDP.rciP.ChCompLength;
        rdChWidth=blkDP.rciP.ChWidth;

        if wrChTDATAWidth<32
            error(message('soc:msgs:ChBitPackedWidthLW32','reader',rdChWidth,rdChCompLength,rdChTDATAWidth));
        end
    end

    if~hsb.blkcb2.cbutils('IsIntegerValue',wsmP.BufferLengthInBursts)
        error(message('soc:msgs:BurstAndBufferLength',...
        'writer',num2str(blkDP.wciP.BurstSize),num2str(blkP.MRBufferSize),num2str(wsmP.BufferLengthInBursts)));
    end
    if~hsb.blkcb2.cbutils('IsIntegerValue',rsmP.BufferLengthInBursts)
        error(message('soc:msgs:BurstAndBufferLength',...
        'reader',num2str(blkDP.rciP.BurstSize),num2str(blkP.MRBufferSize),num2str(rsmP.BufferLengthInBursts)));
    end
end


function l_update_subsystem_ports(blkH,blkPath,sysH,blkP)



    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    interfaceChange=false;


    rdDataPortStr='rdData';
    rdCtrlOutPortStr='rdCtrlOut';
    rdCtrlInPortStr='rdCtrlIn';
    rdDonePortStr='rdDone';
    rdEventPortStr='rdEvent';
    rdH2S=false;

    rdDataportH=[blkPath,'/rdData'];
    rdDataportNum=get_param(rdDataportH,'Port');

    if strcmp(blkP.ProtocolReader,'AXI4-Stream Software')
        rdH2S=true;
        rdCtrlOutPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Outport','Name',rdCtrlOutPortStr);
        if rdCtrlOutPortH
            interfaceChange=true;
            set_param(rdCtrlOutPortH,'Name',rdEventPortStr);
            set_param(rdCtrlOutPortH,'Port',rdDataportNum);
        end
        rdCtrlInPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Inport','Name',rdCtrlInPortStr);
        if rdCtrlInPortH
            interfaceChange=true;
            set_param(rdCtrlInPortH,'Name',rdDonePortStr);
        end
    else
        rdH2S=false;
        rdEventPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Outport','Name',rdEventPortStr);
        if rdEventPortH
            interfaceChange=true;
            set_param(rdEventPortH,'Name',rdCtrlOutPortStr);
            set_param(rdEventPortH,'Port',rdDataportNum);
        end
        rdDonePortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Inport','Name',rdDonePortStr);
        if rdDonePortH
            interfaceChange=true;
            set_param(rdDonePortH,'Name',rdCtrlInPortStr);
        end

    end


    wrDataPortStr='wrData';
    wrCtrlOutPortStr='wrCtrlOut';
    wrCtrlInPortStr='wrCtrlIn';
    wrDonePortStr='wrDone';
    wrEventPortStr='wrEvent';
    wrS2H=false;

    wrDataportH=[blkPath,'/wrData'];
    wrDataportNum=get_param(wrDataportH,'Port');

    if strcmp(blkP.ProtocolWriter,'AXI4-Stream Software')
        wrS2H=true;

        wrEventPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Outport','Name',wrCtrlOutPortStr);
        if wrEventPortH
            interfaceChange=true;
            set_param(wrEventPortH,'Name',wrEventPortStr);
            set_param(wrEventPortH,'Port','1');
        end


        wrDonePortH=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Terminator','Name',wrDonePortStr,'Outport','noprompt');
        if~isempty(wrDonePortH)
            interfaceChange=true;
            set_param(wrDonePortH{1},'Name',wrDonePortStr);
            set_param(wrDonePortH{1},'Port','2');
        end


        wrCtrlInPortH=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Inport','Name',wrCtrlInPortStr,'Ground','noprompt');
        if~isempty(wrCtrlInPortH)
            interfaceChange=true;
            set_param(wrCtrlInPortH{1},'Name',wrCtrlInPortStr);
        end

    else
        wrS2H=false;

        wrEventPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Outport','Name',wrEventPortStr);
        if wrEventPortH
            interfaceChange=true;
            set_param(wrEventPortH,'Name',wrCtrlOutPortStr);
            set_param(wrEventPortH,'Port','1');
        end


        wrDonePortH=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Outport','Name',wrDonePortStr,'Terminator','noprompt');
        if~isempty(wrDonePortH)
            interfaceChange=true;
            set_param(wrDonePortH{1},'Name',wrDonePortStr);
        end


        wrCtrlInPortH=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','BlockType','Ground','Name',wrCtrlInPortStr,'Inport','noprompt');
        if~isempty(wrCtrlInPortH)
            interfaceChange=true;
            set_param(wrCtrlInPortH{1},'Name',wrCtrlInPortStr);
            set_param(wrCtrlInPortH{1},'Port',num2str(str2num(wrDataportNum)+1));
        end
    end


    if interfaceChange

        numWriters=1;numReaders=1;
        s=soc.blkcb.GenPortSchema('Memory Channel',numWriters,numReaders,wrS2H,rdH2S);
        set_param(blkH,'PortSchema',s);



        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end

function[rdDoneportH,rdEventportH]=l_findPorts(blkH,blkPath,rdEventPortStr)

    blkportH=get_param(blkH,'PortHandles');

    if strcmp(get_param([blkPath,'/',rdDonePortStr],'BlockType'),'Inport')
        rdDoneportH=blkportH.Inport(end);
    else
        rdDoneportH=[];
    end

    if strcmp(get_param([blkPath,'/',rdEventPortStr],'BlockType'),'Outport')
        rdEventportH=blkportH.Outport(end);
    else
        rdEventportH=[];
    end
end



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


...
...
...
...
...
...
...
...
...
...
...
...
