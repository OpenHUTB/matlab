function varargout=RandomAccessMemCb(func,blkH,varargin)




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
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'randomAccessMem');
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

    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'randomAccessMem');
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'randomAccessMem','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'randomAccessMem','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'randomAccessMem','No debug','No debug')
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'randomAccessMem');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'randomAccessMem','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'randomAccessMem','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'randomAccessMem','No debug','No debug')
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

        MRNumBuffers=1;
        MRRegionSize=MRNumBuffers*blkP.MRBufferSize;

        set_param(blkH,'MRRegionSize',num2str(MRRegionSize),...
        'MRNumBuffers',num2str(MRNumBuffers));

        set_param(hMemoryChannel,'EnableMemSim',EnableMemSim,...
        'MRBufferSize',get_param(blkH,'MRBufferSize'),...
        'MRNumBuffers',get_param(blkH,'MRNumBuffers'),...
...
        'ChDimensionsWriterChIf',get_param(blkH,'ChDimensionsWriterChIf'),...
        'ChTypeWriterChIf',get_param(blkH,'ChTypeWriterChIf'),...
        'ChFrameSampleTimeWriterChIf',get_param(blkH,'ChFrameSampleTimeWriterChIf'),...
        'ChBitPackedWriterChIf',get_param(blkH,'ChBitPackedWriterChIf'),...
...
        'OutSigSpecMatchesInSigSpec',get_param(blkH,'OutSigSpecMatchesInSigSpec'),...
        'ChDimensionsReaderChIf',get_param(blkH,'ChDimensionsReaderChIf'),...
        'ChTypeWithInhReaderChIf',get_param(blkH,'ChTypeReaderChIf'),...
        'ChFrameSampleTimeReaderChIf',get_param(blkH,'ChFrameSampleTimeReaderChIf'),...
        'ChBitPackedReaderChIf',get_param(blkH,'ChBitPackedReaderChIf'),...
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
    perft=tabc.getDialogControl('PerformanceTab');

    switch val
    case 'Burst accurate'
        perft.Visible='on';
        image='GaugeHigh.svg';
        tooltip='Burst accurate, high resolution';
    case 'Protocol accurate'
        perft.Visible='off';
        image='GaugeMedium.svg';
        tooltip='Protocol accurate, medium resolution';
    case 'Behavioral'
        perft.Visible='off';
        image='GaugeLow.svg';
        tooltip='Behavioral, low resolution';
    otherwise
        perft.Visible='on';
        image='GaugeHigh.svg';
        tooltip='Burst accurate, high resolution';
    end

    badgeDir=fullfile(matlabroot,'toolbox','soc','blocks','badges');

    soc.blkcb.cbutils('AddBadge',blkH,fullfile(badgeDir,image),tooltip,@(a,b,c)soc.internal.helpview('soc_axi4_rand_access'));

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

function[vis,ens]=OutSigSpecMatchesInSigSpecCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>

    if strcmp(val,'on')
        nval='off';
    else
        nval='on';
    end

    vis{idxMap('ChFrameSampleTimeReaderChIf')}=nval;
    vis{idxMap('ChDimensionsReaderChIf')}=nval;
    vis{idxMap('ChTypeReaderChIf')}=nval;
    vis{idxMap('ChBitPackedReaderChIf')}=nval;

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
    helpcmd='eval(''soc.internal.helpview(''''soc_axi4_rand_access'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end




