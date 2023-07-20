function varargout=MemoryControllerCbV1(func,blkH,varargin)




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
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl');
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



    assert(blkP.NumMasters<=blkP.MAX_NUM_MASTERS,message('soc:msgs:MaxMastersExceeded',blkP.MAX_NUM_MASTERS));
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
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'memctrl','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'memctrl','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'memctrl','No debug','No debug')
        end
    end
end

function DeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    soc.blkcb.cbutils('UnregisterSetupViewerCb',blkH);
end

function UndoDeleteFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    soc.blkcb.cbutils('RegisterSetupViewerCb',blkH,'memctrl');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    if(codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockInstantiation',blkPath))
        soc.blkcb.cbutils('setupViewer',blkH,'memctrl','No debug','No debug')
    else
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH,'slResolve');
        [~,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        'on',blkP,...
        {'MemChDiagLevel'},{'DiagnosticLevel'});
        if~strcmp(blkP.DiagnosticLevel,'No debug')
            soc.blkcb.cbutils('setupViewer',blkH,'memctrl','Basic diagnostic signals','Basic diagnostic signals')
        else
            soc.blkcb.cbutils('setupViewer',blkH,'memctrl','No debug','No debug')
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


        assert(blkP.NumMasters<=blkP.MAX_NUM_MASTERS,message('soc:msgs:MaxMastersExceeded',blkP.MAX_NUM_MASTERS));
        update_subsystem_ports(blkH,blkPath,sysH,...
        blkP.NumMasters,...
        blkP.MAX_NUM_MASTERS);

        pcslist=hsb.blkcb2.cbutils('MemCtrlrConfigSetParamNames');

        switch(blkP.MemorySelection)
        case 'PS memory'
            pcslist=strcat(pcslist,'PS');
        case 'PL memory'
            pcslist=strcat(pcslist,'PL');
        end

        pblist=hsb.blkcb2.cbutils('MemCtrlrBlockParamNames');






        [blkDP.memcsP,blkP]=hsb.blkcb2.cbutils('GetConfigsetValues',blkH,...
        blkP.UseValuesFromTargetHardwareResources,blkP,...
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
        subBlks=l_getSubBlocks(blkPath);

        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.memcsP);
        hsb.blkcb2.cbutils('SetDerivedMaskParams',blkH,blkP.blkDP.maskP);

        l_setSubBlockVariants(subBlks,...
        blkP.ICArbitrationPolicy,'');

    catch ME
        hadError=true;
        rethrow(ME);
    end
    soc.internal.setBlockIcon(blkH,'socicons.MemoryController');

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
function[vis,ens]=NumMastersCb(blkH,val,vis,ens,idxMap)%#ok<*INUSL>
    if soc.blkcb.cbutils('IsLibContext',blkH)||...
        soc.blkcb.cbutils('SimStatusIsRunning',blkH,bdroot(blkH))
        return;
    end












    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);

    numMasters=hsb.blkcb2.cbutils('TryEval',val);
    [upToDate,currDL]=l_compareLoggedMasters(blkP.DiagnosticLevel,numMasters);
    if~upToDate
        soc.blkcb.cbutils('setupViewer',blkH,'memctrlNumMastersCb',numMasters,currDL)
    end
end
function[upToDate,currDL]=l_compareLoggedMasters(DiagnosticLevel,numMasters)
    splitLast=split(DiagnosticLevel,'.');
    currDL=splitLast{1};
    if length(splitLast)==2
        loggedMasters=str2double(splitLast{2});
        if loggedMasters~=numMasters
            upToDate=false;
        else
            upToDate=true;
        end
    else



        upToDate=true;
    end
end


function[vis,ens]=UseValuesFromTargetHardwareResourcesCb(blkH,val,vis,ens,idxMap)

    pblist=hsb.blkcb2.cbutils('MemCtrlrBlockParamNames');
    if strcmp(val,'on')
        enval='off';
    else
        enval='on';
    end
    for p=pblist
        ens{idxMap(p{1})}=enval;
    end

    if strcmp(val,'on')



















    end
end

function[vis,ens]=MemorySelectionCb(blkH,val,vis,ens,idxMap)

    if(strcmp(get_param(blkH,'UseValuesFromTargetHardwareResources'),'on'))





















    end
end
function[vis,ens]=LastTargetBoardCb(blkH,val,vis,ens,idxMap)

    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);

    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    dc.Prompt=currBoard;
    if~strcmp(val,currBoard)
        if~strcmp(blkP.UseValuesFromTargetHardwareResources,'on')
            warning(message('soc:msgs:TargetBoardChanged',blkP.LastTargetBoard,currBoard));
        end
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





function s=l_getSubBlocks(blkPath)
    s.arbBlk=sprintf('%s/Arbitration',blkPath);
    s.ddBlk=sprintf('%s/log',blkPath);
end
function l_setSubBlockVariants(sub,arbPolicy,dLevel)
    switch arbPolicy
    case 'Round robin',variant='RoundRobin_Variant';
    case 'Fixed port priority',variant='FixedPriority_Variant';
    otherwise
        error(message('soc:msgs:InternalBadMemICArbVariant',arbPolicy));
    end
    set_param(sub.arbBlk,'LabelModeActiveChoice',variant);
end
function l_checkConfigSetParams(blkH,blkP,blkPath)

    if~strcmp(blkP.UseValuesFromTargetHardwareResources,'on')
        badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockParamCheck',blkPath);
    else
        badTargetWarn=codertarget.fpgadesign.internal.fpgaDesignCallback(blkH,'checkFPGACompatibility','blockGetParam',blkPath);
    end

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
        if~strcmp(blkP.UseValuesFromTargetHardwareResources,'on')
            warning(message('soc:msgs:TargetBoardChanged',blkP.LastTargetBoard,currBoard));
        end
        blkDP.LastTargetBoard=currBoard;
    end


    dc=mobj.getDialogControl('BandwidthRowHdr');
    cBW=num2str(blkP.ControllerFrequency*(blkP.ControllerDataWidth/8));
    dc.Prompt=['Bandwidth:  ',num2str(cBW),' MB/s'];


    blkP=hsb.blkcb2.cbutils('CopyDerivedMaskParams',blkDP,blkP);
end


function update_subsystem_ports(blkH,blkPath,sysH,NumMasters,MAX_NUM_MASTERS)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    interfaceChange=false;

    commonfindargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};



    allInPorts=find_system(blkPath,commonfindargs{:},'BlockType','Inport');
    allInGrounds=find_system(blkPath,commonfindargs{:},'ReferenceBlock','socmemlib_internal/Bus Ground');
    needInGrounds=NumMasters<length(allInPorts);
    needInPorts=NumMasters>length(allInPorts);
    if needInGrounds
        interfaceChange=true;
        if~bdIsLoaded('socmemlib_internal')

            loadlibCleanup=onCleanup(@()close_system('socmemlib_internal'));
            load_system('socmemlib_internal');
        end
        for pidx=NumMasters+1:MAX_NUM_MASTERS-length(allInGrounds)
            reqname=['burstReq',num2str(pidx)];
            newreqblk=replace_block(blkPath,'FollowLinks','On','Name',reqname,'socmemlib_internal/Bus Ground','noprompt');
            assert(~isempty(newreqblk),message('soc:msgs:InternalNoNewBlkFor','ground'));
            set_param(newreqblk{1},...
            'Name',reqname,...
            'OutDataTypeStr','Bus: BurstRequest2BusObj');
        end
    elseif needInPorts
        interfaceChange=true;
        for pidx=length(allInPorts)+1:NumMasters
            reqname=['burstReq',num2str(pidx)];
            newreqblk=replace_block(blkPath,'FollowLinks','On','Name',reqname,'Inport','noprompt');
            assert(~isempty(newreqblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
            set_param(newreqblk{1},...
            'Name',reqname,...
            'Port',num2str(pidx),...
            'OutDataTypeStr','Bus: BurstRequest2BusObj');
        end
    else

    end


    allOutPorts=find_system(blkPath,commonfindargs{:},'BlockType','Outport');
    allOutTerms=find_system(blkPath,commonfindargs{:},'BlockType','Terminator');
    numBurstDonePorts=length(allOutPorts);
    numBurstDoneTerms=length(allOutTerms);
    needOutTerms=NumMasters<numBurstDonePorts;
    needOutPorts=NumMasters>numBurstDonePorts;
    if needOutTerms
        interfaceChange=true;
        for pidx=NumMasters+1:MAX_NUM_MASTERS-numBurstDoneTerms
            donename=['burstDone',num2str(pidx)];
            newdoneblk=replace_block(blkPath,'FollowLinks','On','Name',donename,'Terminator','noprompt');
            assert(~isempty(newdoneblk),message('soc:msgs:InternalNoNewBlkFor','terminator'));
            set_param(newdoneblk{1},'Name',donename);
        end
    elseif needOutPorts
        interfaceChange=true;
        for pidx=numBurstDonePorts+1:NumMasters
            donename=['burstDone',num2str(pidx)];
            newdoneblk=replace_block(blkPath,'FollowLinks','On','Name',donename,'Outport','noprompt');
            assert(~isempty(newdoneblk),message('soc:msgs:InternalNoNewBlkFor','outport'));
            set_param(newdoneblk{1},...
            'Name',donename,...
            'Port',num2str(pidx),...
            'OutDataTypeStr','Bus: BurstRequest2BusObj');
        end
    else

    end

    if interfaceChange

        s=soc.blkcb.GenPortSchema('Memory Controller',NumMasters,0);
        set_param(blkH,'PortSchema',s);



        pos=get_param(blkPath,'Position');
        offset=[10,10,20,20];
        set_param(blkPath,'Position',pos-offset);
        set_param(blkPath,'Position',pos);
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
            figH=soc.internal.MemControllerPlot(figName,blkPath,blkP.NumMasters,ddBlkPaths);
            sysH=bdroot(blkH);
            cobj=get_param(sysH,'InternalObject');
            cobj.addlistener('SLGraphicalEvent::CLOSE_MODEL_EVENT',@(~,~)(l_deleteIfExists(figH)));
        end
    end
end
function l_deleteIfExists(figH)
    if isa(figH,'soc.internal.MemControllerPlot')
        delete(figH);
    end
end
function ddBlkPaths=l_getDDBlkPaths(blkPath)
    blkH=get_param(blkPath,'Handle');
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);

    subBlks=l_getSubBlocks(blkPath);
    if strcmp(blkP.DiagnosticLevel,'No debug')
        numDDMasters=0;
    else
        numDDMasters=blkP.NumMasters;
    end
    ddLength=numDDMasters;
    ddBlkPaths=cell(1,ddLength);
    for ii=1:numDDMasters
        ddBlkPaths{ii}=sprintf('%s/Master%02d/Bus Selector',subBlks.ddBlk,ii);
    end

end


