function varargout=VideoFrameBufferCb(func,blkH,varargin)




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
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'videoFrameBuffer');
end

function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    sysH=bdroot(blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemoryControllerWr=[blkPath,'/SimVariant/Accurate/Memory Controller Wr'];
    hMemoryControllerRd=[blkPath,'/SimVariant/Accurate/Memory Controller Rd'];

    hsb.blkcb2.defineTypes(sysH);

    soc.internal.verifyMemorySetting(blkH);

    soc.blkcb.MemoryControllerCb('MasterIDRegFcn',get_param(hMemoryControllerWr,'Handle'),get_param(blkH,'MemorySelection'));
    soc.blkcb.MemoryControllerCb('MasterIDRegFcn',get_param(hMemoryControllerRd,'Handle'),get_param(blkH,'MemorySelection'));
end


function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function CopyFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemoryControllerWr=[blkPath,'/SimVariant/Accurate/Memory Controller Wr'];
    hMemoryControllerRd=[blkPath,'/SimVariant/Accurate/Memory Controller Rd'];
    set_param(hMemoryControllerWr,'MasterIDValid','off');
    set_param(hMemoryControllerRd,'MasterIDValid','off');

    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'videoFrameBuffer');
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'videoFrameBuffer','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'videoFrameBuffer','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'videoFrameBuffer','No debug','No debug')
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'videoFrameBuffer');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'videoFrameBuffer','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'videoFrameBuffer','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'videoFrameBuffer','No debug','No debug')
        end
    end
end




function MaskInitFcn(blkH)%#ok<*DEFNU>

    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');

    l_SetMaskHelp(blkH);

    try
        hMemoryChannel=[blkPath,'/SimVariant/Accurate/Memory Channel'];
        hMemoryControllerWr=[blkPath,'/SimVariant/Accurate/Memory Controller Wr'];
        hMemoryControllerRd=[blkPath,'/SimVariant/Accurate/Memory Controller Rd'];
        hBehavImpl=[blkPath,'/SimVariant/Behavioral/Behavioral Impl'];
        hSimVariant=[blkPath,'/SimVariant'];

        switch blkP.MemorySimulation
        case 'Burst accurate'
            EnableMemSim='on';
            SimVariant='Accurate';
        case 'Protocol accurate'
            EnableMemSim='off';
            SimVariant='Accurate';
        case 'Behavioral'
            EnableMemSim='off';
            SimVariant='Behavioral';
        otherwise
            EnableMemSim='on';
            SimVariant='Accurate';
        end

        set_param(hSimVariant,'LabelModeActiveChoice',SimVariant);

        [FrameDim,StdDim]=l_VideoFrameSize2Dim(blkP.FrameSize);
        ChType=blkP.ChTypeWriterChIf;

        [ChLength,ChCompLength,~]=hsb.blkcb2.cbutils('GetChLength',blkP.ChDimensionsWriterChIf,blkP.ChBitPackedWriterChIf);
        [~,~,~,~,chTDATASize]=hsb.blkcb2.cbutils('GetChWidths',ChType,ChCompLength);

        if ChLength>FrameDim
            error(message('soc:msgs:SignalDimGreaterThanFrameSize',blkP.FrameSize,FrameDim,['[',num2str(blkP.ChDimensionsWriterChIf),']'],ChLength,ChCompLength));
        end

        if strcmp(blkP.InsertInactivePixelClocksReaderChIf,'on')&&~StdDim
            error(message('soc:msgs:PixelClockBadFrameBufferSize'));
        end

        MRBufferSize=chTDATASize*FrameDim;
        MRRegionSize=blkP.MRNumBuffers*MRBufferSize;

        [chOrderWr,chOrderRd,chDimensionsRd]=hsb.blkcb2.cbutils('GetChOrder',blkP.ChDimensionsWriterChIf,blkP.ChBitPackedWriterChIf);


        set_param(blkH,'MRRegionSize',num2str(MRRegionSize),...
        'MRBufferSize',num2str(MRBufferSize));

        set_param(hBehavImpl,'MRNumBuffers',get_param(blkH,'MRNumBuffers'),...
        'ChDimBuffer',num2str(FrameDim*ChCompLength),...
        'ChTypeBufferSend',get_param(blkH,'ChTypeWriterChIf'),...
        'ChTypeBufferRecv',get_param(blkH,'ChTypeWriterChIf'),...
...
        'chDimOrderWriterChIf',['[',num2str(chOrderWr),']'],...
...
        'ChDimensionsReaderChIf',['[',num2str(chDimensionsRd),']'],...
        'ChDimOrderReaderIf',['[',num2str(chOrderRd),']'],...
        'ChDimCombinedReaderChIf',num2str(prod(chDimensionsRd(1:end))),...
        'ChTypeReaderChIf',get_param(blkH,'ChTypeWriterChIf'),...
        'ChSampleTimeReaderIf',get_param(blkH,'ChFrameSampleTimeWriterChIf'));

        set_param(hMemoryChannel,'EnableMemSim',EnableMemSim,...
        'MRBufferSize',get_param(blkH,'MRBufferSize'),...
        'MRNumBuffers',get_param(blkH,'MRNumBuffers'),...
...
        'ReaderWriterUseSameValues','on',...
        'BurstLengthWriterChIf',get_param(blkH,'BurstLengthWriterChIf'),...
        'FIFODepthWriter',get_param(blkH,'FIFODepthWriter'),...
        'FIFOAFullDepthWriter',get_param(blkH,'FIFOAFullDepthWriter'),...
        'ICClockFrequencyWriter',get_param(blkH,'ICClockFrequencyWriter'),...
        'ICDataWidthWriter',get_param(blkH,'ICDataWidthWriter'),...
...
        'ChDimensionsWriterChIf',get_param(blkH,'ChDimensionsWriterChIf'),...
        'ChTypeWriterChIf',get_param(blkH,'ChTypeWriterChIf'),...
        'ChFrameSampleTimeWriterChIf',get_param(blkH,'ChFrameSampleTimeWriterChIf'),...
        'ChBitPackedWriterChIf',get_param(blkH,'ChBitPackedWriterChIf'),...
...
        'OutSigSpecMatchesInSigSpec','off',...
        'ChDimensionsReaderChIf',get_param(blkH,'ChDimensionsWriterChIf'),...
        'ChTypeWithInhReaderChIf',get_param(blkH,'ChTypeWriterChIf'),...
        'ChBitPackedReaderChIf',get_param(blkH,'ChBitPackedWriterChIf'),...
...
        'ChSampleTimeOffsetReaderChIf',get_param(blkH,'ChSampleTimeOffsetReaderChIf'),...
        'InsertInactivePixelClocksReaderChIf',get_param(blkH,'InsertInactivePixelClocksReaderChIf'),...
        'DiagnosticLevel',get_param(blkH,'DiagnosticLevel'));

        set_param(hMemoryControllerWr,'MemorySelection',get_param(blkH,'MemorySelection'),...
        'DiagnosticLevel',get_param(blkH,'DiagnosticLevel'));
        set_param(hMemoryControllerRd,'MemorySelection',get_param(blkH,'MemorySelection'),...
        'DiagnosticLevel',get_param(blkH,'DiagnosticLevel'));

        blkP.MasterIDValidWr=get_param(hMemoryControllerWr,'MasterIDValid');
        blkP.MasterIDWr=str2num(get_param(hMemoryControllerWr,'MasterID'));
        blkP.MasterIDValidRd=get_param(hMemoryControllerRd,'MasterIDValid');
        blkP.MasterIDRd=str2num(get_param(hMemoryControllerRd,'MasterID'));

        mobj=Simulink.Mask.get(blkH);
        dc=mobj.getDialogControl('MRRegionSizeText');
        dc.Prompt=['Region size (bytes):  ',num2str(MRRegionSize)];

        l_setMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.MemoryController');
    catch ME
        hadError=true;
        rethrow(ME);
    end

end





function[vis,ens]=MemorySimulationCb(blkH,val,vis,ens,idxMap)
    mobj=Simulink.Mask.get(blkH);
    tabc=mobj.getDialogControl('TabContainer');
    mwt=tabc.getDialogControl('MainTab');
    adv=mwt.getDialogControl('AdvancedParametersPanel');
    perft=tabc.getDialogControl('PerformanceTab');

    switch val
    case 'Burst accurate'
        adv.Visible='on';
        perft.Visible='on';
        image='GaugeHigh.svg';
        tooltip='Burst accurate, high resolution';
    case 'Protocol accurate'
        adv.Visible='off';
        perft.Visible='off';
        image='GaugeMedium.svg';
        tooltip='Protocol accurate, medium resolution';
    case 'Behavioral'
        adv.Visible='off';
        perft.Visible='off';
        image='GaugeLow.svg';
        tooltip='Behavioral, low resolution';
    otherwise
        adv.Visible='on';
        perft.Visible='on';
        image='GaugeHigh.svg';
        tooltip='Burst accurate, high resolution';
    end

    badgeDir=fullfile(matlabroot,'toolbox','soc','blocks','badges');

    soc.blkcb.cbutils('AddBadge',blkH,fullfile(badgeDir,image),tooltip,@(a,b,c)soc.internal.helpview('soc_axi4_video_frame'));

end

function[vis,ens]=LastTargetBoardCb(blkH,val,vis,ens,idxMap)

    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    if~strcmp(val,currBoard)
        set_param(blkH,'LastTargetBoard',currBoard);
    end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockGetParam',blkPath);
    if~badTargetWarn
        sysH=bdroot(blkH);
        cs=getActiveConfigSet(sysH);
        FPGADesign=codertarget.data.getParameterValue(cs,'FPGADesign');

        if FPGADesign.HasPSMemory&&FPGADesign.HasPLMemory
            if FPGADesign.IncludeProcessingSystem
                ens{idxMap('MemorySelection')}='on';
            else
                ens{idxMap('MemorySelection')}='off';
                set_param(blkH,'MemorySelection','PL memory');
            end
        elseif FPGADesign.HasPSMemory
            ens{idxMap('MemorySelection')}='off';
            set_param(blkH,'MemorySelection','PS memory');
        elseif FPGADesign.HasPLMemory
            ens{idxMap('MemorySelection')}='off';
            set_param(blkH,'MemorySelection','PL memory');
        else
            ens{idxMap('MemorySelection')}='off';
        end
    else
        ens{idxMap('MemorySelection')}='off';
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
            MemChblkPath=[blkPath,'/SimVariant/Accurate/Memory Channel'];
            ddBlkPaths={sprintf('%s/log/Writer/Bus Selector',MemChblkPath),...
            sprintf('%s/log/Reader/Bus Selector',MemChblkPath)};
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            figH=soc.internal.MemChannelPlot(figName,blkPath,blkP.MRNumBuffers,ddBlkPaths);
            sysH=bdroot(blkH);
            cobj=get_param(sysH,'InternalObject');
            cobj.addlistener('SLGraphicalEvent::CLOSE_MODEL_EVENT',@(~,~)(l_deleteIfExists(figH)));
        end
    end
end

function LaunchPerformanceCtrlAppButtonCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        soc.blkcb.MemoryControllerCb('MaskLinkCb','LaunchPerformanceAppButton',get_param([blkPath,'/SimVariant/Accurate/Memory Controller Wr'],"Handle"));
    end
end




function l_setMaskDisplay(blkH,blkP)

    MemoryIDStr=blkP.MemorySelection;

    if strcmpi(blkP.MasterIDValidWr,'on')&&...
        strcmpi(blkP.MasterIDValidRd,'on')
        MasterIDStr=sprintf('Master %d:%d',blkP.MasterIDWr,blkP.MasterIDRd);
    else
        MasterIDStr='';
    end

    MemoryIDlabel=sprintf('text(0.02,0.95,''{\\bf%s}'',''horizontalAlignment'',''left'', ''texmode'',''on'');',MemoryIDStr);
    MasterIDlabel=sprintf('text(0.98,0.95,''{\\bf%s}'',''horizontalAlignment'',''right'',''texmode'',''on'');',MasterIDStr);
    fullIcon=sprintf('%s\n%s\n',MemoryIDlabel,MasterIDlabel);
    set_param(blkH,'MaskDisplay',fullIcon);
end

function l_SetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_axi4_video_frame'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end

function l_deleteIfExists(figH)
    if isa(figH,'soc.internal.MemChannelPlot')
        delete(figH);
    end
end

function[FrameDim,StdDim]=l_VideoFrameSize2Dim(FrameSize)

    FrameDim=0;
    StdDim=false;
    if ischar(FrameSize)
        switch FrameSize
        case '480p SDTV (720x480p)',FrameDim=720*480;StdDim=true;
        case '576p SDTV (720x576p)',FrameDim=720*576;StdDim=true;
        case '720p HDTV (1280x720p)',FrameDim=1280*720;StdDim=true;
        case '1080p HDTV (1920x1080p)',FrameDim=1920*1080;StdDim=true;
        case '160x120p',FrameDim=160*120;StdDim=true;
        case '320x240p',FrameDim=320*240;StdDim=true;
        case '640x480p',FrameDim=640*480;StdDim=true;
        case '800x600p',FrameDim=800*600;StdDim=true;
        case '1024x768p',FrameDim=1024*768;StdDim=true;
        case '1280x768p',FrameDim=1280*768;StdDim=true;
        case '1280x1024p',FrameDim=1280*1024;StdDim=true;
        case '1360x768p',FrameDim=1360*768;StdDim=true;
        case '1366x768p',FrameDim=1366*768;StdDim=true;
        case '1400x1050p',FrameDim=1400*1050;StdDim=true;
        case '1600x1200p',FrameDim=1600*1200;StdDim=true;
        case '1680x1050p',FrameDim=1680*1050;StdDim=true;
        case '1920x1200p',FrameDim=1920*1200;StdDim=true;
        otherwise
            error(message('soc:msgs:UnsupportedVideoFrameSize',FrameSize))
        end
    else
        validateattributes(FrameSize,{'numeric'},{'row','integer','positive'});
        if numel(FrameSize)>2
            error(message('soc:msgs:UnsupportedVideoFrameSize',['[',num2str(FrameSize),']']));
        end
        FrameDim=prod(FrameSize);
        switch FrameDim
        case 720*480,StdDim=true;
        case 720*576,StdDim=true;
        case 1280*720,StdDim=true;
        case 1920*1080,StdDim=true;
        case 160*120,StdDim=true;
        case 320*240,StdDim=true;
        case 640*480,StdDim=true;
        case 800*600,StdDim=true;
        case 1024*768,StdDim=true;
        case 1280*768,StdDim=true;
        case 1280*1024,StdDim=true;
        case 1360*768,StdDim=true;
        case 1366*768,StdDim=true;
        case 1400*1050,StdDim=true;
        case 1600*1200,StdDim=true;
        case 1680*1050,StdDim=true;
        case 1920*1200,StdDim=true;
        otherwise,StdDim=false;
        end
    end
end

