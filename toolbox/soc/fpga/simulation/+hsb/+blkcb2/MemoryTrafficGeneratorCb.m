function varargout=MemoryTrafficGeneratorCb(varargin)




    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end
function MaskParamCb(paramName,blkH)%#ok<*DEFNU>
    cbH=eval(['@',paramName,'Cb']);
    hsb.blkcb2.cbutils('MaskParamCb',paramName,blkH,cbH)
end
function MaskLinkCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    cbH(blkH);
end




function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    if strcmpi(get_param(blkH,'ShowMemoryControllerPorts'),'off')
        soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memTrafficGen');
    end
end

function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    sysH=bdroot(blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemoryController=[blkPath,'/MemCtrlGate/local/Memory Controller'];

    hsb.blkcb2.defineTypes(sysH);

    soc.blkcb.MemoryControllerCb('MasterIDRegFcn',get_param(hMemoryController,'Handle'),get_param(blkH,'MemorySelection'));
end

function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function CopyFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemoryController=[blkPath,'/MemCtrlGate/local/Memory Controller'];
    set_param(hMemoryController,'MasterIDValid','off');

    if strcmpi(get_param(blkH,'ShowMemoryControllerPorts'),'off')
        soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memTrafficGen');
        if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
            soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
        else
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
            'on',blkP,{'MemChDiagLevel'},{'DiagnosticLevel'});
            if~strcmp(blkP.DiagnosticLevel,'No debug')
                soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','Basic diagnostic signals','Basic diagnostic signals')
            else
                soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
            end
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    if strcmpi(get_param(blkH,'ShowMemoryControllerPorts'),'off')

        soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
    end
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    if strcmpi(get_param(blkH,'ShowMemoryControllerPorts'),'off')
        soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memTrafficGen');
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
            soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
        else
            blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
            [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
            'on',blkP,...
            {'MemChDiagLevel'},{'DiagnosticLevel'});
            if~strcmp(blkP.DiagnosticLevel,'No debug')
                soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','Basic diagnostic signals','Basic diagnostic signals')
            else
                soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
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

    sysH=bdroot(blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    hMemCtrlGate=[blkPath,'/MemCtrlGate'];

    try


        if strcmpi(blkP.ShowMemoryControllerPorts,'off')
            set_param(hMemCtrlGate,'LabelModeActiveChoice','local');
        else
            set_param(hMemCtrlGate,'LabelModeActiveChoice','passthrough');
        end
        update_subsystem_ports(blkH,blkPath,sysH,blkP.ShowMemoryControllerPorts);






        [blkDP.maskP,blkP]=l_getDerivedMaskValues(blkH,sysH,blkP,blkPath);%#ok<ASGLU>

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


    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    l_SetMaskHelp(blkH);

    try
        hMemoryController=[blkPath,'/MemCtrlGate/local/Memory Controller'];
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.maskP);


        set_param([blkPath,'/MTG/Request Queue with Drops/Assert'],'Enabled',get_param(blkH,'EnableAssertion'));
        set_param(hMemoryController,'MemorySelection',get_param(blkH,'MemorySelection'),...
        'DiagnosticLevel',get_param(blkH,'DiagnosticLevel'));
        blkP.MasterIDValid=get_param(hMemoryController,'MasterIDValid');
        blkP.MasterID=str2num(get_param(hMemoryController,'MasterID'));

        if~strcmp(blkP.ShowMemoryControllerPorts,blkP.LastShowMemoryControllerPorts)
            set_param(blkH,'LastShowMemoryControllerPorts',blkP.ShowMemoryControllerPorts);
            if strcmpi(blkP.ShowMemoryControllerPorts,'off')
                soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memTrafficGen');
                if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
                    soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
                else
                    [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
                    'on',blkP,{'MemChDiagLevel'},{'DiagnosticLevel'});
                    if~strcmp(blkP.DiagnosticLevel,'No debug')
                        soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','Basic diagnostic signals','Basic diagnostic signals')
                    else
                        soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
                    end
                end
            else
                soc.blkcb.cbutils('setupViewer',blkH,'memTrafficGen','No debug','No debug')
                soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
            end
        end

        l_setMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.TrafficGenerator');
    catch ME
        hadError=true;
        rethrow(ME);
    end

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

function[vis,ens]=ShowMemoryControllerPortsCb(blkH,val,vis,ens,idxMap)%#ok<INUSL,INUSD>
    mobj=Simulink.Mask.get(blkH);
    pg=mobj.getDialogControl('PerformanceGrp');

    switch val
    case 'on',vis{idxMap('MemorySelection')}='off';pg.Visible='off';
    case 'off',vis{idxMap('MemorySelection')}='on';pg.Visible='on';
    end
end

function HardwareBoardLinkCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        cs=getActiveConfigSet(bdroot(blkH));
        configset.showParameterGroup(cs,{'Hardware Implementation'});
        configset.showParameterGroup(cs,{'Hardware Implementation','Target hardware resources','FPGA design (mem channels)'});
    end
end

function ShowImplementationInfoLinkCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        pblist=hsb.blkcb2.cbutils('DummyMasterBlockParamNames');
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        pbvals=cellfun(@(x)(blkP.(x)),pblist,'UniformOutput',false);
        info=cell2struct(pbvals,pblist,2);%#ok<NASGU>

        infoText=sprintf('Implementation info (using target-specific constraints):\n%s\n',...
        evalc('disp(info)'));
        msgbox(['\fontname{Courier} ',infoText],'Implementation Info',struct('WindowStyle','non-modal','Interpreter','tex'));
    end
end

function[vis,ens]=BurstSizeCb(blkH,val,vis,ens,idxMap)%#ok<INUSL,INUSD>
    maxBurstSize=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_SIZE');
    numVal=hsb.blkcb2.cbutils('TryEval',val);
    if numVal>maxBurstSize
        error(message('soc:msgs:TrafficGeneratorBurstSizeTooLarge',...
        num2str(numVal),num2str(maxBurstSize)));
    end
end

function[vis,ens]=AllowSimOnlyParametersCb(blkH,val,vis,ens,idxMap)%#ok<INUSL,INUSD>
    mobj=Simulink.Mask.get(blkH);
    sopg=mobj.getDialogControl('SimOnlyParamGroup');
    sopg.Visible=val;

    switch val
    case 'on',vis{idxMap('TimeBetweenBursts')}='off';
    case 'off',vis{idxMap('TimeBetweenBursts')}='on';
    end
end

function LaunchPerformanceCtrlAppButtonCb(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH)
        error(message('soc:msgs:NotAvailInLibContext'));
    else
        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        soc.blkcb.MemoryControllerCb('MaskLinkCb','LaunchPerformanceAppButton',get_param([blkPath,'/MemCtrlGate/local/Memory Controller'],"Handle"));
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
    if strcmpi(blkP.ShowMemoryControllerPorts,'off')
        set_param(blkH,'MaskDisplay',fullIcon);
    else
        set_param(blkH,'MaskDisplay','');
    end
end

function l_SetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_memorytrafficgenerator'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function[blkDP,blkP]=l_getDerivedMaskValues(blkH,sysH,blkP,blkPath)%#ok<INUSL,INUSD>

    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    dc.Prompt=currBoard;


    dc=mobj.getDialogControl('BurstLengthText');

    if any(blkP.TotalBurstRequests==inf)
        validateattributes(blkP.TotalBurstRequests,{'numeric'},{'positive','scalar'},'','TotalBurstRequests');
    else
        validateattributes(blkP.TotalBurstRequests,{'numeric'},{'positive','integer','scalar'},'','TotalBurstRequests');
    end
    validateattributes(blkP.BurstSize,{'numeric'},{'positive','integer','scalar'},'','BurstSize');
    validateattributes(blkP.ICDataWidth,{'numeric'},{'positive','integer','scalar'},'','ICDataWidth');
    burstLength=ceil(blkP.BurstSize/(blkP.ICDataWidth/8));
    maxBurstLength=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_BEATS');




    if burstLength>maxBurstLength
        error(message('soc:msgs:TrafficGeneratorBurstLengthTooLarge',...
        num2str(blkP.BurstSize),num2str(blkP.ICDataWidth),...
        num2str(burstLength),num2str(maxBurstLength)));
    end
    blkDP.BurstLength=burstLength;
    dc.Prompt=sprintf('Burst length (beats):\t%d',burstLength);

    switch blkP.AllowSimOnlyParameters
    case 'on'
        minmax=blkP.MinMaxTimeBetweenBursts;
        blkDP.BurstInteraccessTimes=[blkP.FirstBurstTime,minmax(1),minmax(2)];
    case 'off'
        blkDP.FirstBurstTime=0;
        blkDP.BurstInteraccessTimes=[0,blkP.TimeBetweenBursts,blkP.TimeBetweenBursts];
        blkDP.WaitForDone='off';
        blkDP.EnableAssertion='off';
    end

    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',blkDP,blkP);
end


function update_subsystem_ports(blkH,blkPath,sysH,ShowMemoryControllerPorts)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    interfaceChange=false;

    burstReqStr='burstReq';
    burstDoneStr='burstDone';


    commonfindargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};



    if strcmpi(ShowMemoryControllerPorts,'on')

        burstReqH=replace_block(blkPath,commonfindargs{:},'BlockType','Terminator','Name',burstReqStr,'Outport','noprompt');
        if~isempty(burstReqH)
            interfaceChange=true;
            set_param(burstReqH{1},'Name',burstReqStr);
        end

        burstDoneH=replace_block(blkPath,commonfindargs{:},'BlockType','Ground','Name',burstDoneStr,'Inport','noprompt');
        if~isempty(burstDoneH)
            interfaceChange=true;
            set_param(burstDoneH{1},'Name',burstDoneStr);
        end
    else

        burstReqH=replace_block(blkPath,commonfindargs{:},'BlockType','Outport','Name',burstReqStr,'Terminator','noprompt');
        if~isempty(burstReqH)
            interfaceChange=true;
            set_param(burstReqH{1},'Name',burstReqStr);
        end

        burstDoneH=replace_block(blkPath,commonfindargs{:},'BlockType','Inport','Name',burstDoneStr,'Ground','noprompt');
        if~isempty(burstDoneH)
            interfaceChange=true;
            set_param(burstDoneH{1},'Name',burstDoneStr);
        end
    end

    if interfaceChange

        s=soc.blkcb.GenPortSchema('Memory Traffic Generator',strcmp(ShowMemoryControllerPorts,'on'));
        set_param(blkH,'PortSchema',s);



        pos=get_param(blkPath,'Position');
        offset=[10,10,20,20];
        set_param(blkPath,'Position',pos-offset);
        set_param(blkPath,'Position',pos);
    end
end
