function varargout=Stream2SoftwareCb(func,blkH,varargin)




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
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'stream2sw');
end

function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    sysH=bdroot(blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemoryController=[blkPath,'/SimVariant/Accurate/Memory Controller'];

    hsb.blkcb2.defineTypes(sysH);

    soc.internal.verifyMemorySetting(blkH);

    soc.blkcb.MemoryControllerCb('MasterIDRegFcn',get_param(hMemoryController,'Handle'),get_param(blkH,'MemorySelection'));

end

function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function CopyFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemoryController=[blkPath,'/SimVariant/Accurate/Memory Controller'];
    set_param(hMemoryController,'MasterIDValid','off');

    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'stream2sw');
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'stream2sw','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'stream2sw','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'stream2sw','No debug','No debug')
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'stream2sw');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'stream2sw','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'stream2sw','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'stream2sw','No debug','No debug')
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
        hMemoryController=[blkPath,'/SimVariant/Accurate/Memory Controller'];
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

        if strcmp(blkP.ChTypeReaderChIf,'Inherit: Same as input')
            blkP.ChTypeReaderChIf=blkP.ChTypeWriterChIf;
            ChTypeReaderChIf=get_param(blkH,'ChTypeWriterChIf');
        else
            ChTypeReaderChIf=get_param(blkH,'ChTypeReaderChIf');
        end

        [ChLengthRd,ChCompLengthRd,~]=hsb.blkcb2.cbutils('GetChLength',blkP.ChDimensionsReaderChIf,'off');
        [~,~,~,~,chTDATASizeRd]=hsb.blkcb2.cbutils('GetChWidths',blkP.ChTypeReaderChIf,ChCompLengthRd);

        MRBufferSize=chTDATASizeRd*ChLengthRd;
        MRRegionSize=blkP.MRNumBuffers*MRBufferSize;

        [chOrderWr,~,~]=hsb.blkcb2.cbutils('GetChOrder',blkP.ChDimensionsWriterChIf,blkP.ChBitPackedWriterChIf);

        set_param(blkH,'MRRegionSize',num2str(MRRegionSize),...
        'MRBufferSize',num2str(MRBufferSize));

        set_param(hBehavImpl,'MRNumBuffers',get_param(blkH,'MRNumBuffers'),...
        'ChDimBuffer',get_param(blkH,'ChDimensionsReaderChIf'),...
        'ChTypeBuffer',ChTypeReaderChIf,...
...
        'ChDimOrderWriterChIf',['[',num2str(chOrderWr),']']);

        set_param(hMemoryChannel,'EnableMemSim',EnableMemSim,...
        'MRBufferSize',get_param(blkH,'MRBufferSize'),...
        'MRNumBuffers',get_param(blkH,'MRNumBuffers'),...
...
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
        'ChDimensionsReaderChIf',get_param(blkH,'ChDimensionsReaderChIf'),...
        'ChTypeWithInhReaderChIf',get_param(blkH,'ChTypeReaderChIf'),...
        'DiagnosticLevel',get_param(blkH,'DiagnosticLevel'));

        set_param(hMemoryController,'MemorySelection',get_param(blkH,'MemorySelection'),...
        'DiagnosticLevel',get_param(blkH,'DiagnosticLevel'));

        blkP.MasterIDValid=get_param(hMemoryController,'MasterIDValid');
        blkP.MasterID=str2num(get_param(hMemoryController,'MasterID'));

        mobj=Simulink.Mask.get(blkH);
        dc=mobj.getDialogControl('MRRegionSizeText');
        dc.Prompt=['Region size (bytes):  ',num2str(MRRegionSize)];

        l_setMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.Stream2SW');
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

    soc.blkcb.cbutils('AddBadge',blkH,fullfile(badgeDir,image),tooltip,@(a,b,c)soc.internal.helpview('soc_axi4_stream_sw'));

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
        soc.blkcb.MemoryControllerCb('MaskLinkCb','LaunchPerformanceAppButton',get_param([blkPath,'/SimVariant/Accurate/Memory Controller'],"Handle"));
    end
end




function l_setMaskDisplay(blkH,blkP)
    MemoryIDStr=blkP.MemorySelection;

    if strcmpi(blkP.MasterIDValid,'on')
        MasterIDStr=sprintf('Master %d',blkP.MasterID);
    else
        MasterIDStr='';
    end

    MemoryIDlabel=sprintf('text(0.02,0.95,''{\\bf%s}'',''horizontalAlignment'',''left'', ''texmode'',''on'');',MemoryIDStr);
    MasterIDlabel=sprintf('text(0.98,0.95,''{\\bf%s}'',''horizontalAlignment'',''right'',''texmode'',''on'');',MasterIDStr);
    fullIcon=sprintf('%s\n%s\n',MemoryIDlabel,MasterIDlabel);
    set_param(blkH,'MaskDisplay',fullIcon);
end

function l_SetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_axi4_stream_sw'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end

function l_deleteIfExists(figH)
    if isa(figH,'soc.internal.MemChannelPlot')
        delete(figH);
    end
end





