function varargout=MemoryControllerCb(func,blkH,varargin)




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
    if strcmpi(get_param(blkH,'AutoSetupViewer'),'on')
        soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl_single');
    end
end
function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    sysH=bdroot(blkH);

    hsb.blkcb2.defineTypes(sysH);

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInitErrorCheck',blkPath);

    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');

    MasterIDRegFcn(blkH,blkP.MemorySelection);




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

function MasterIDRegFcn(blkH,MemorySelection)
    MasterID=soc.blkcb.cbutils('RegisterIndexCb',blkH,MemorySelection);
    set_param(blkH,'MasterID',num2str(MasterID),...
    'MasterIDValid','on');
end

function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function CopyFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    set_param(blkH,'MasterIDValid','off');
    if strcmpi(get_param(blkH,'AutoSetupViewer'),'on')
        soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl_single');
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
            soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
        else
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
            'on',blkP,...
            {'MemChDiagLevel'},{'DiagnosticLevel'});
            if~strcmp(blkP.DiagnosticLevel,'No debug')
                soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','Basic diagnostic signals','Basic diagnostic signals')
            else
                soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
            end
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('UnregisterIndexCb',blkH,get_param(blkH,'MemorySelection'));
    if strcmpi(get_param(blkH,'AutoSetupViewer'),'on')

        soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
    end
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    if strcmpi(get_param(blkH,'AutoSetupViewer'),'on')
        soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl_single');
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
            soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
        else
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
            'on',blkP,...
            {'MemChDiagLevel'},{'DiagnosticLevel'});
            if~strcmp(blkP.DiagnosticLevel,'No debug')
                soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','Basic diagnostic signals','Basic diagnostic signals')
            else
                soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
            end
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

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);

    try




        pcslist=hsb.blkcb2.cbutils('MemCtrlrConfigSetParamNames');

        switch(blkP.MemorySelection)
        case 'PS memory'
            pcslist=strcat(pcslist,'PS');
        case 'PL memory'
            pcslist=strcat(pcslist,'PL');
        end

        pblist=hsb.blkcb2.cbutils('MemCtrlrBlockParamNames');






        [blkDP.memcsP,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        pcslist,pblist);
        [blkDP.maskP,blkP]=l_getDerivedMaskValues(blkH,sysH,blkP,blkPath);

        l_checkConfigSetParams(blkH,blkP,blkPath);

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

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);

    try
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.memcsP);
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.maskP);

        if~strcmp(blkP.MemorySelection,blkP.LastMemorySelection)
            soc.blkcb.cbutils('UnregisterIndexCb',blkH,blkP.LastMemorySelection);
            set_param(blkH,'LastMemorySelection',blkP.MemorySelection,...
            'MasterIDValid','off');
            blkP.MasterIDValid='off';
        end

        if~strcmp(blkP.AutoSetupViewer,blkP.LastAutoSetupViewer)
            set_param(blkH,'LastAutoSetupViewer',blkP.AutoSetupViewer);
            if strcmpi(blkP.AutoSetupViewer,'on')
                soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl_single');
                if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
                    soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
                else
                    [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
                    'on',blkP,{'MemChDiagLevel'},{'DiagnosticLevel'});
                    if~strcmp(blkP.DiagnosticLevel,'No debug')
                        soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','Basic diagnostic signals','Basic diagnostic signals')
                    else
                        soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
                    end
                end
            else
                soc.blkcb.cbutils('setupViewer',blkH,'memctrl_single','No debug','No debug')
                soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
            end
        end

    catch ME
        hadError=true;
        rethrow(ME);
    end
    l_setMaskDisplay(blkH,blkP);
    soc.internal.setBlockIcon(blkH,'socicons.MemoryController');

end




function LaunchPerformanceAppButtonCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

        MemorySelectionName=[get_param(blkH,'MemorySelection'),' Controller'];
        MemorySelectionName=regexprep(MemorySelectionName,'(\<[a-z])','${upper($1)}');

        figName=message('soc:ui:PlotWindowTitle',MemorySelectionName).getString();
        figH=findobj(groot,'Name',figName);
        if~isempty(figH)
            figure(figH);
            return;
        else
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            ddBlkPaths=l_getDDBlkPaths(blkH);
            figH=soc.internal.MemControllerPlot(figName,blkPath,numel(ddBlkPaths),ddBlkPaths);
            sysH=bdroot(blkH);
            cobj=get_param(sysH,'InternalObject');
            cobj.addlistener('SLGraphicalEvent::CLOSE_MODEL_EVENT',@(~,~)(l_deleteIfExists(figH)));
        end
    end
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
            switch(get_param(blkH,'MemorySelection'))
            case 'PS memory'
                cspage='FPGA design (PS mem controllers)';
            case 'PL memory'
                cspage='FPGA design (PL mem controllers)';
            end
            configset.showParameterGroup(cs,{'Hardware Implementation','Target hardware resources',cspage});
        end
    end
end



function[vis,ens]=MemorySelectionCb(blkH,val,vis,ens,idxMap)

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    switch(val)
    case 'PS memory'
        set_param([blkPath,'/MemCtrlMulticastSend'],'MulticastTag','socMemCtrlArbTriggerPS');
        set_param([blkPath,'/MemCtrlMulticastRecv'],'MulticastTag','socMemCtrlArbTriggerPS');
    case 'PL memory'
        set_param([blkPath,'/MemCtrlMulticastSend'],'MulticastTag','socMemCtrlArbTriggerPL');
        set_param([blkPath,'/MemCtrlMulticastRecv'],'MulticastTag','socMemCtrlArbTriggerPL');
    end
end

function[vis,ens]=LastTargetBoardCb(blkH,val,vis,ens,idxMap)

    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);

    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    dc.Prompt=currBoard;
    if~strcmp(val,currBoard)
        set_param(blkH,'LastTargetBoard',currBoard);
    end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockGetParam',blkPath);
    if~badTargetWarn
        sysH=bdroot(blkH);
        cs=getActiveConfigSet(sysH);
        FPGADesign=codertarget.data.getParameterValue(cs,'FPGADesign');
        vis{idxMap('MemorySelection')}='on';
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
            vis{idxMap('MemorySelection')}='off';
        end
    else
        vis{idxMap('MemorySelection')}='off';
    end

end




function l_setMaskDisplay(blkH,blkP)
    MasterID='';
    if strcmpi(blkP.MasterIDValid,'on')
        MasterID=blkP.MasterID;
    end
    switch(blkP.MemorySelection)
    case 'PS memory'
        MasterStr=sprintf('PS Master %d',MasterID);
    case 'PL memory'
        MasterStr=sprintf('PL Master %d',MasterID);
    end

    Masterlabel=sprintf('text(0.98,0.95,''{\\bf%s}'',''horizontalAlignment'',''right'',''texmode'',''on'');',MasterStr);
    fullIcon=sprintf('%s\n',Masterlabel);
    set_param(blkH,'MaskDisplay',fullIcon);
end

function l_checkConfigSetParams(blkH,blkP,blkPath)

    badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockGetParam',blkPath);

    if badTargetWarn,return;end
    for csp=hsb.blkcb2.cbutils('MemCtrlrBlockParamNames')
        val=blkP.(csp{1});
        depVal=blkP.MemorySelection;
        codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'check',csp{1},val,depVal);
    end
end

function[blkDP,blkP]=l_getDerivedMaskValues(blkH,sysH,blkP,blkPath)%#ok<INUSD>
    blkDP=struct();


    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    dc.Prompt=currBoard;

    if~strcmp(blkP.LastTargetBoard,currBoard)
        blkDP.LastTargetBoard=currBoard;
    end


    dc=mobj.getDialogControl('BandwidthRowHdr');
    cBW=num2str(blkP.ControllerFrequency*(blkP.ControllerDataWidth/8));
    dc.Prompt=['Bandwidth:  ',num2str(cBW),' MB/s'];


    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',blkDP,blkP);
end



function l_deleteIfExists(figH)
    if isa(figH,'soc.internal.MemControllerPlot')
        delete(figH);
    end
end

function ddBlkPaths=l_getDDBlkPaths(blkH)
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);
    ddBlkPaths=cell(1,0);
    CtrlblkList={};
    blkHList=[find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib_internal/Memory Controller');...
    find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4-Stream to Software');...
    find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Software to AXI4-Stream');...
    find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4 Random Access Memory');...
    find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/AXI4 Video Frame Buffer')];
    ATGBlks=find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock','socmemlib/Memory Traffic Generator');
    blkHList=[blkHList;ATGBlks(strcmpi(get_param(ATGBlks,'ShowMemoryControllerPorts'),'off'))];

    blkHList=blkHList(strcmpi(get_param(blkHList,'MemorySelection'),blkP.MemorySelection));
    refBlockList=[{},get_param(blkHList,'referenceblock')];
    for ii=1:numel(refBlockList)
        switch refBlockList{ii}
        case 'socmemlib_internal/Memory Controller'
            CtrlblkPath=soc.blkcb.cbutils('GetBlkPath',blkHList(ii));
            CtrlblkList=[CtrlblkList,{CtrlblkPath}];
            ddBlkPaths=[ddBlkPaths,sprintf('%s/log/Master/Bus Selector',CtrlblkPath)];
        case 'socmemlib/Memory Traffic Generator'
            CtrlblkPath=[soc.blkcb.cbutils('GetBlkPath',blkHList(ii)),'/MemCtrlGate/local/Memory Controller'];
            CtrlblkList=[CtrlblkList,{CtrlblkPath}];
            ddBlkPaths=[ddBlkPaths,sprintf('%s/log/Master/Bus Selector',CtrlblkPath)];
        case{'socmemlib/AXI4-Stream to Software','socmemlib/Software to AXI4-Stream'}
            CtrlblkPath=[soc.blkcb.cbutils('GetBlkPath',blkHList(ii)),'/SimVariant/Accurate/Memory Controller'];
            CtrlblkList=[CtrlblkList,{CtrlblkPath}];
            ddBlkPaths=[ddBlkPaths,sprintf('%s/log/Master/Bus Selector',CtrlblkPath)];
        case{'socmemlib/AXI4 Random Access Memory','socmemlib/AXI4 Video Frame Buffer'}
            CtrlWrblkPath=[soc.blkcb.cbutils('GetBlkPath',blkHList(ii)),'/SimVariant/Accurate/Memory Controller Wr'];
            CtrlRdblkPath=[soc.blkcb.cbutils('GetBlkPath',blkHList(ii)),'/SimVariant/Accurate/Memory Controller Rd'];
            CtrlblkList=[CtrlblkList,{CtrlWrblkPath},{CtrlRdblkPath}];
            ddBlkPaths=[ddBlkPaths,sprintf('%s/log/Master/Bus Selector',CtrlWrblkPath),sprintf('%s/log/Master/Bus Selector',CtrlRdblkPath)];
        end
    end
    [~,SortIdx]=sort(cellfun(@str2num,get_param(CtrlblkList,'MasterID')));
    ddBlkPaths=ddBlkPaths(SortIdx);
end



