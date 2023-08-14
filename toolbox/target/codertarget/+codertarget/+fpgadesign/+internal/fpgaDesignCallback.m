function varargout=fpgaDesignCallback(varargin)


    callerObj=varargin{1};
    hwBoard=l_getHWBoard(callerObj);
    switch hwBoard
    case codertarget.internal.getCustomHardwareBoardNamesForSoC

        if nargout==0
            codertarget.fpgadesign.internal.fpgaDesignCallbackForCustomBoard(varargin{:});
        else
            [varargout{1:nargout}]=codertarget.fpgadesign.internal.fpgaDesignCallbackForCustomBoard(varargin{:});
        end
        return;
    case[codertarget.internal.getTargetHardwareNamesForSoC,'Custom Hardware Board']

    otherwise

        callerType=l_getCallerType(varargin{1});
        if strcmp(callerType,'BlockDialog')


        else
            error(message('soc:msgs:BoardNotSupported',hwBoard));
        end
    end


    switch l_getCallerType(varargin{1})
    case 'ConfigSetDialog'
        if l_isValueChangeCallback(varargin{2})

            [hObj,hDlg,tag,dlgType]=varargin{1:4};%#ok<ASGLU>
            widgetVal=hDlg.getWidgetValue(tag);
            widgetVal=hsb.blkcb2.cbutils('TryEval',widgetVal);
            userData=hDlg.getUserData(tag);
            sName=userData.Storage;
            pName=strrep(sName,'FPGADesign.','');
            [errMsg,valToSet]=feval(['l_check',pName],pName,hObj,widgetVal,'');
            if isempty(errMsg)
                codertarget.data.setParameterValue(hObj.getConfigSet(),sName,valToSet);
            else
                errordlg(errMsg.getString(),'Coder Target Error Dialog','modal');
            end
        elseif strcmp('default',varargin{2})
            [hObj,~,tag,defaultVal]=varargin{1:4};
            sName=tag;
            pName=strrep(sName,'FPGADesign.','');
            tmpstk=dbstack;
            if~any(strcmp({tmpstk.name},'apply'))
                codertarget.data.setParameterValue(hObj.getConfigSet(),sName,defaultVal);
                feval(['l_check',pName],pName,hObj,defaultVal,'');
            end
            varargout{1}=defaultVal;
        else
            error('(internal) invalid call to fpgaDesignCallback for ConfigSetDialog caller');
        end
    case 'BlockDialog'
        action=varargin{2};
        switch action
        case 'check'
            [blkH,~,pNameOnBlock,pNewVal]=varargin{1:4};
            l_checkFPGACompatibility(blkH,'blockParamCheck',pNameOnBlock);
            if length(varargin)>=5,restOfArgs=varargin(5:end);
            else,restOfArgs={};
            end
            [pCSName,rdOrWr]=l_blkToCSName(pNameOnBlock);
            errMsg=feval(['l_check',pCSName],pNameOnBlock,blkH,pNewVal,rdOrWr,restOfArgs{:});
            varargout{1}=errMsg;
            if~isempty(errMsg)
                error(errMsg);
            end
        case 'checkFPGACompatibility'
            [blkH,~,caller,blkPath]=varargin{1:4};
            varargout{1}=l_checkFPGACompatibility(blkH,caller,blkPath);
        case 'getAllFPGABoards'
            varargout{1}=l_getAllFPGACompatibleBoards();
        otherwise
            error('(internal) bad action for fpgaDesignCallback');
        end

    case 'ConfigSetObj'
        action=varargin{2};
        pName=varargin{3};
        switch action
        case 'getConstraints'
            if length(varargin)>=4,restOfArgs=varargin(4:end);
            else,restOfArgs={};
            end
            constr=feval(['l_getConstraints',pName],restOfArgs{:});
            varargout{1}=constr;
        case 'manualValueChangeCb'

            [cs,~,~,val]=varargin{1:4};
            fname=['l_check',pName];
            if exist(fname,'file')
                [errMsg,valToSet]=feval(['l_check',pName],pName,cs,val,'');
                if isempty(errMsg)
                    codertarget.data.setParameterValue(cs,['FPGADesign.',pName],valToSet);
                else
                    error(errMsg);
                end
            else



                codertarget.data.setParameterValue(cs,['FPGADesign.',pName],val);
            end
        otherwise
            error('(internal) bad action for fpgaDesignCallback');
        end
    end
end





function constr=l_getConstraintsIncludeProcessingSystem(objH,hwBoard)%#ok<INUSL>


    switch hwBoard
    case{'Artix-7 35T Arty FPGA evaluation kit',...
        'Xilinx Kintex-7 KC705 development board'}
        min=0;max=0;def=0;
    case 'ZedBoard'
        min=1;max=1;def=1;
    otherwise
        min=0;max=1;def=1;
    end
    constr=l_constrObj(min,max,def,{});
end
function[errMsg,pNewVal]=l_checkIncludeProcessingSystem(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,*DEFNU> 


    hwBoard=l_getHWBoard(objH);
    constr=l_getConstraintsIncludeProcessingSystem(objH,hwBoard);
    errMsg=l_checkVal(errPName,pNewVal,constr.min,constr.max);
end
function[errMsg,pNewVal]=l_checkAXIHDLUserLogicClock(errPName,objH,pNewVal,rdOrWr)%#ok<,INUSD,*DEFNU> 
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,1,500);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,1,500);
    end


end

function constr=l_getConstraintsAXIMemorySubsystemClock(objH,depProcSys,hwBoard)%#ok<INUSL>
    switch hwBoard
    case 'Artix-7 35T Arty FPGA evaluation kit'
        min=83.33;max=83.33;def=83.33;
    case 'Xilinx Kintex-7 KC705 development board'
        min=200;max=200;def=200;
    case 'ZedBoard'
        min=1;max=150;def=100;
    case 'Xilinx Zynq ZC706 evaluation kit'
        if depProcSys,min=1;max=250;def=200;
        else,min=200;max=200;def=200;
        end
    case 'Altera Arria 10 SoC development kit'
        if depProcSys,min=1;max=1000;def=200;
        else,min=266;max=266;def=266;
        end
    case 'Altera Cyclone V SoC development kit'
        if depProcSys,min=1;max=500;def=150;
        else,min=150;max=150;def=150;
        end
    case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
        if depProcSys,min=1;max=600;def=300;
        else,min=300;max=300;def=300;
        end
    otherwise
        min=1;max=1e12;def=200;
    end
    constr=l_constrObj(min,max,def,{});
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemClock(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<*DEFNU>

    hwBoard=l_getHWBoard(objH);
    switch(PSorPL)
    case 'PL memory'
        constr=l_getConstraintsAXIMemorySubsystemClock(objH,0,hwBoard);
    case 'PS memory'
        constr=l_getConstraintsAXIMemorySubsystemClock(objH,1,hwBoard);
    end
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,constr.min,constr.max);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,constr.min,constr.max);
    end
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemClockPS(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>
    [errMsg,pNewVal]=l_checkAXIMemorySubsystemClock(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemClockPL(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>
    [errMsg,pNewVal]=l_checkAXIMemorySubsystemClock(errPName,objH,pNewVal,rdOrWr,'PL memory');
end
function constr=l_getConstraintsAXIMemorySubsystemDataWidth(objH,depProcSys,hwBoard)%#ok<INUSL>
    switch hwBoard
    case 'Artix-7 35T Arty FPGA evaluation kit'
        vals={'32','64','128'};
        def='64';
    case 'Xilinx Kintex-7 KC705 development board'
        vals={'32','64','128','256','512'};
        def='64';
    case 'ZedBoard'
        vals={'64'};def='64';
    case 'Xilinx Zynq ZC706 evaluation kit'
        if depProcSys,vals={'64'};def='64';
        else,vals={'32','64','128','256','512'};def='64';
        end
    case 'Altera Arria 10 SoC development kit'
        if depProcSys,vals={'64'};def='64';
        else,vals={'512'};def='512';
        end
    case 'Altera Cyclone V SoC development kit'
        vals={'64'};
        def='64';
    case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
        vals={'128'};
        def='128';
    otherwise
        vals={'8','16','32','64','128','256','512','1024'};
        def='64';
    end
    constr=l_constrObj(0,0,def,vals);
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidth(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<*DEFNU>
    hwBoard=l_getHWBoard(objH);
    switch(PSorPL)
    case 'PL memory'
        constr=l_getConstraintsAXIMemorySubsystemDataWidth(objH,0,hwBoard);
        depValList=l_getDepCSValueList(objH,'AXIMemorySubsystemDataWidthPL','MemControllersPL',rdOrWr);
    case 'PS memory'
        constr=l_getConstraintsAXIMemorySubsystemDataWidth(objH,1,hwBoard);
        depValList=l_getDepCSValueList(objH,'AXIMemorySubsystemDataWidthPS','MemControllersPS',rdOrWr);
    end
    pNewVal=l_convertEvaledListItem(objH,depValList,pNewVal);
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkValList(errname,pNewVal,constr.vals);
    case 'BlockDialog'
        errMsg=l_checkValList(errPName,pNewVal,constr.vals);
    end
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidthPS(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>
    [errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidth(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidthPL(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>
    [errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidth(errPName,objH,pNewVal,rdOrWr,'PL memory');
end
function[errMsg,pNewVal]=l_checkRefreshOverhead(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<INUSD,*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,0,100);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,0,100);
    end
end
function[errMsg,pNewVal]=l_checkRefreshOverheadPS(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>
    [errMsg,pNewVal]=l_checkRefreshOverhead(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkRefreshOverheadPL(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>
    [errMsg,pNewVal]=l_checkRefreshOverhead(errPName,objH,pNewVal,rdOrWr,'PL memory');
end
function[errMsg,pNewVal]=l_checkWriteFirstTransferLatency(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<INUSD,INUSL,*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,0,1e3);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,0,1e3);
    end
end
function[errMsg,pNewVal]=l_checkWriteFirstTransferLatencyPS(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,INUSL,*DEFNU>
    [errMsg,pNewVal]=l_checkWriteFirstTransferLatency(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkWriteFirstTransferLatencyPL(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,INUSL,*DEFNU>
    [errMsg,pNewVal]=l_checkWriteFirstTransferLatency(errPName,objH,pNewVal,rdOrWr,'PL memory');
end
function[errMsg,pNewVal]=l_checkReadFirstTransferLatency(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<INUSD,,*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,0,1e3);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,0,1e3);
    end
end
function[errMsg,pNewVal]=l_checkReadFirstTransferLatencyPS(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,,*DEFNU>
    [errMsg,pNewVal]=l_checkReadFirstTransferLatency(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkReadFirstTransferLatencyPL(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,,*DEFNU>
    [errMsg,pNewVal]=l_checkReadFirstTransferLatency(errPName,objH,pNewVal,rdOrWr,'PL memory');
end
function[errMsg,pNewVal]=l_checkWriteLastTransferLatency(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<INUSD,,*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,0,1e3);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,0,1e3);
    end
end
function[errMsg,pNewVal]=l_checkWriteLastTransferLatencyPS(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,,*DEFNU>
    [errMsg,pNewVal]=l_checkWriteLastTransferLatency(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkWriteLastTransferLatencyPL(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,,*DEFNU>
    [errMsg,pNewVal]=l_checkWriteLastTransferLatency(errPName,objH,pNewVal,rdOrWr,'PL memory');
end
function[errMsg,pNewVal]=l_checkReadLastTransferLatency(errPName,objH,pNewVal,rdOrWr,PSorPL)%#ok<INUSD,,*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,0,1e3);
    case 'BlockDialog'
        errMsg=l_checkVal(errPName,pNewVal,0,1e3);
    end
end
function[errMsg,pNewVal]=l_checkReadLastTransferLatencyPS(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,,*DEFNU>
    [errMsg,pNewVal]=l_checkReadLastTransferLatency(errPName,objH,pNewVal,rdOrWr,'PS memory');
end
function[errMsg,pNewVal]=l_checkReadLastTransferLatencyPL(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,,*DEFNU>
    [errMsg,pNewVal]=l_checkReadLastTransferLatency(errPName,objH,pNewVal,rdOrWr,'PL memory');
end

function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectFIFODepth(errPName,objH,pNewVal,rdOrWr,varargin)%#ok<INUSL,*DEFNU>
    if~isempty(varargin)
        val=varargin{:};
        switch val{1}
        case{'AXI4-Stream to Software via DMA','AXI4-Stream FIFO','Software to AXI4-Stream via DMA','AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer'}
            min=2;
            max=32;
            err=l_checkFIFOdepth(errPName,pNewVal,min,max);
            if~isempty(err)
                if pNewVal<min
                    value=num2str(min);
                elseif pNewVal>max
                    value=num2str(max);
                else
                    value=num2str(2^nextpow2(pNewVal));
                end
                errMsg=message('soc:msgs:ICFIFOdepthADIDMAC',errPName(10:end),num2str(pNewVal),value);
                warning(errMsg);
                errMsg='';
            else
                errMsg='';
            end
            if isempty(errMsg)
                min=val{4};
                err=l_checkVal(errPName,pNewVal,min,inf);
                if~isempty(err)
                    errMsg=message('soc:msgs:ICFIFOdepthLessThanAFull',errPName(10:end),num2str(pNewVal),num2str(min));
                end
            end
        otherwise
            errMsg='';
        end
    else
        min=1;
        max=1e6;
        switch l_getCallerType(objH)
        case{'ConfigSetDialog','ConfigSetObj'}
            errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
            errMsg=l_checkVal(errname,pNewVal,min,max);
        case 'BlockDialog'
            errMsg=l_checkVal(errPName,pNewVal,min,max);
        end
        if isempty(errMsg)
            min=l_getDepParamValue(objH,'AXIMemoryInterconnectFIFOAFullDepth',rdOrWr);
            err=l_checkVal(errPName,pNewVal,min,inf);
            if~isempty(err)
                errMsg=message('soc:msgs:ICFIFOdepthLessThanAFull',errPName(10:end),num2str(pNewVal),num2str(min));
            end
        end
    end
end
function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectFIFOAFullDepth(errPName,objH,pNewVal,rdOrWr,varargin)%#ok<*DEFNU>
    min=1;
    if length(varargin)==1
        max=varargin{1};
    else
        max=l_getDepParamValue(objH,'AXIMemoryInterconnectFIFODepth',rdOrWr);
    end

    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errLabel='Interconnect almost-full depth in <a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
    case 'BlockDialog'
        fromConfigSet=get_param(objH,'UseValuesFromTargetHardwareResources');
        if strcmp(fromConfigSet,'on')
            errLabel='Interconnect almost-full depth in <a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
        elseif contains(errPName,'Writer','IgnoreCase',true)
            errLabel='Interconnect writer almost-full depth';
        elseif contains(errPName,'Reader','IgnoreCase',true)
            errLabel='Interconnect reader almost-full depth';
        else
            errLabel=errPName;
        end
    end
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkVal(errname,pNewVal,min,max);
    case 'BlockDialog'
        errMsg=l_checkVal(errLabel,pNewVal,min,max);
    end



end

function[errMsg,pNewVal]=l_checkNumberOfTraceEvents(errPName,objH,pNewVal,rdOrWr)%#ok<INUSD,*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=l_checkFIFOdepth(errname,pNewVal,512,8192);
    case 'BlockDialog'
        errMsg=l_checkFIFOdepth(errPName,pNewVal,512,8192);
    end

end
function[errMsg,pNewVal]=l_checkMemChDiagLevel(errPName,objH,pNewVal,rdOrWr,varargin)




    csH=l_getCS(objH);
    dlgH=csH.getDialogHandle();

    pb=l_progressBar_on(dlgH,message('soc:msgs:MemChDiagLevelProgressBar').getString);%#ok<NASGU>

    storedVal=l_getDepCSValue(objH,errPName,rdOrWr);
    errMsg='';
    try
        valStrings=l_getDepCSValueList(objH,errPName,'Debug',rdOrWr);
        pNewVal=l_convertEvaledListItem(objH,valStrings,pNewVal);
        mdlLogging=get_param(csH,'SignalLogging');
        if strcmp(mdlLogging,'off')&&~strcmp(pNewVal,'No debug')
            error(message('soc:msgs:ModelLoggingDisabled'));
        end
        errMsg=l_checkValList(errPName,pNewVal,valStrings);
        if~isempty(errMsg)
            switch pNewVal
            case{'Detailed debug signals','Detailed debug signals and memory image dump'}


                pNewVal='Basic diagnostic signals';
                errMsg='';
            otherwise

                throw(MException(errMsg));
            end
        end






        soc.blkcb.cbutils('CallAllRegisteredSetupViewerCbs',objH.getModel,storedVal,pNewVal);

    catch ME
        errMsg=message('soc:msgs:MemChDiagLevelCheck',errPName,pNewVal,ME.message());
    end
end
function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectInputClock(errPName,objH,pNewVal,rdOrWr)%#ok<*DEFNU>





    if 0
        depVal=l_getDepCSValue(objH,'AXIMemorySubsystemClock',rdOrWr);
        min=depVal;max=depVal;
    else
        min=1;max=1e12;
    end

    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errLabel='Interconnect clock frequency in <a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
    case 'BlockDialog'
        fromConfigSet=get_param(objH,'UseValuesFromTargetHardwareResources');
        if strcmp(fromConfigSet,'on')
            errLabel='Interconnect clock frequency in <a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
        elseif contains(errPName,'Writer','IgnoreCase',true)
            errLabel='Interconnect writer clock frequency';
        elseif contains(errPName,'Reader','IgnoreCase',true)
            errLabel='Interconnect reader clock frequency';
        else
            errLabel=errPName;
        end
    end
    errMsg=l_checkVal(errLabel,pNewVal,min,max);
end
function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectInputDataWidth(errPName,objH,pNewVal,rdOrWr,varargin)
    depValList=l_getDepCSValueList(objH,'AXIMemoryInterconnectInputDataWidth','MemChannels',rdOrWr);
    pNewVal=l_convertEvaledListItem(objH,depValList,pNewVal);
    errMsg='';

    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errLabel='Interconnect data width in <a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
        errMsg=l_checkValList(errLabel,pNewVal,depValList);

    case 'BlockDialog'
        fromConfigSet=get_param(objH,'UseValuesFromTargetHardwareResources');
        if strcmp(fromConfigSet,'on')
            errLabel='Interconnect data width in <a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
        elseif contains(errPName,'Writer','IgnoreCase',true)
            errLabel='Interconnect writer data width';
        elseif contains(errPName,'Reader','IgnoreCase',true)
            errLabel='Interconnect reader data width';
        else
            errLabel=errPName;
        end
        ICInfo=varargin{:};
        switch ICInfo{1}
        case{'AXI4-Stream to Software via DMA','AXI4-Stream FIFO','Software to AXI4-Stream via DMA','AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer'}
            errMsg=l_checkValList(errLabel,pNewVal,depValList);
        case 'AXI4 Random Access'
            okVals{:}=num2str(ICInfo{2});
            errMsg=l_checkValList(errLabel,pNewVal,okVals);
            if soc.blkcb.cbutils('SimStatusIsStopped',objH,bdroot(objH))
                warning(errMsg)
                errMsg='';
            end
        end

    end

end








function ct=l_getCallerType(obj)
    isErr=false;
    if isa(obj,'CoderTarget.SettingsController')
        ct='ConfigSetDialog';
    elseif isa(obj,'Simulink.ConfigSet')
        ct='ConfigSetObj';
    elseif ishandle(obj)
        try
            fname=getfullname(obj);%#ok<NASGU>
            ct='BlockDialog';
        catch ME %#ok<NASGU>
            isErr=true;
        end
    else
        isErr=true;
    end
    if isErr
        error('(internal) unknown caller type to fpgaDesignCallback');
    end
end
function tf=l_isConfigSetCaller(obj)
    tf=isa(obj,'CoderTarget.SettingsController')||isa(obj,'Simulink.ConfigSet');
end
function tf=l_isValueChangeCallback(obj)
    tf=isa(obj,'ConfigSet.DDGWrapper');
end
function cs=l_getCS(objH)
    switch l_getCallerType(objH)
    case 'ConfigSetDialog'
        cs=objH.getConfigSet();
    case 'ConfigSetObj'
        cs=objH;
    case 'BlockDialog'
        cs=getActiveConfigSet(bdroot(objH));
    end
end
function hw=l_getHWBoard(objH)
    cs=l_getCS(objH);
    try
        hw=codertarget.data.getParameterValue(cs,'TargetHardware');
    catch ME
        hw='None';
    end
end
function constr=l_constrObj(min,max,def,vals)
    constr=struct(...
    'min',min,'max',max,'def',def,'vals',{vals});
end
function tf=l_isMWTargetBoard(objH)

    hw=l_getHWBoard(objH);
    if any(strcmp(hw,{...
        'Artix-7 35T Arty FPGA evaluation kit',...
        'Xilinx Kintex-7 KC705 development board',...
        'ZedBoard',...
        'Xilinx Zynq ZC706 evaluation kit',...
        'Altera Arria 10 SoC development kit',...
        'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit',...
        'Altera Cyclone V SoC development kit'}))
        tf=true;
    else
        tf=false;
    end
end
function warn=l_checkFPGACompatibility(objH,caller,blkPath)
    cs=l_getCS(objH);
    isFPGACompat=codertarget.utils.isSoCInstalledAndModelConfiguredForSoC(cs,2);

    warn=false;
    if~isFPGACompat

        hw=l_getHWBoard(objH);

        showMsg=true;
        switch caller
        case 'blockInstantiation',warn=true;showMsg=true;
        case 'blockInitErrorCheck',warn=false;showMsg=true;
        case 'blockParamCheck',warn=true;showMsg=true;
        case 'blockGetParam',warn=true;showMsg=false;
        otherwise,warn=true;
        end

        msg=message('soc:msgs:CouldNotGetTargetGlobals',hw,blkPath);
        if warn
            if showMsg
                warning(msg);
            end
        else
            error(msg);
        end
    end
end
function boardList=l_getAllFPGACompatibleBoards()

    boardList=[codertarget.internal.getTargetHardwareNamesForSoC...
    ,'Custom Hardware Board'];
end
function[pNameOut,rdOrWr]=l_blkToCSName(pNameIn)
    if contains(pNameIn,'Reader')
        rdOrWr='Reader';
    elseif contains(pNameIn,'Writer')
        rdOrWr='Writer';
    else
        rdOrWr='';
    end
    nameMap=containers.Map(...
    [hsb.blkcb2.cbutils('MemChBlockParamNames'),hsb.blkcb2.cbutils('MemCtrlrBlockParamNames')],...
    [hsb.blkcb2.cbutils('MemChConfigSetParamNames'),hsb.blkcb2.cbutils('MemCtrlrConfigSetParamNames')]);
    pNameOut=nameMap(pNameIn);
end
function pNameOut=l_csToBlkName(pNameIn,rdOrWr)

    nameMap=containers.Map(...
    [hsb.blkcb2.cbutils('MemChConfigSetParamNames'),hsb.blkcb2.cbutils('MemCtrlrConfigSetParamNames')],...
    [hsb.blkcb2.cbutils('MemChBlockParamNames'),hsb.blkcb2.cbutils('MemCtrlrBlockParamNames')]);
    pNameOut=nameMap(pNameIn);
    pNameOut=strrep(pNameOut,'Reader',rdOrWr);
end
function v=l_getDepCSValue(objH,pName,rdOrWr)%#ok<INUSD>
    cs=l_getCS(objH);
    pName=['FPGADesign.',pName];
    v=codertarget.data.getParameterValue(cs,pName);
    if ischar(v)
        vNum=str2num(v);%#ok<ST2NM>
        if~isempty(vNum)
            v=vNum;
        else

        end
    end
end
function l_setDepCSValue(objH,pName,pVal)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        cs=l_getCS(objH);
        pName=['FPGADesign.',pName];
        codertarget.data.setParameterValue(cs,pName,pVal);
    case 'BlockDialog'




    end
end
function v=l_getDepCSValueList(objH,pName,groupName,rdOrWr)%#ok<INUSD>
    cs=l_getCS(objH);
    pName=['FPGADesign.',pName];
    group=codertarget.utils.getFPGADesignWidgets(cs,groupName);
    groupP=group.Parameters{1};
    param=groupP{cellfun(@(x)(isequal(x.Storage,pName)),groupP)};
    v=param.Entries;
end
function l_setDepParamValue(objH,pName,pVal)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        sName=['FPGADesign.',pName];
        codertarget.data.setParameterValue(l_getCS(objH),sName,pVal);
    case 'BlockDialog'




    end
end
function v=l_getDepParamValue(objH,pName,rdOrWr)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        sName=['FPGADesign.',pName];
        v=codertarget.data.getParameterValue(l_getCS(objH),sName);
    case 'BlockDialog'
        pName=l_csToBlkName(pName,rdOrWr);
        vstr=get_param(objH,pName);
        try
            v=slResolve(vstr,objH);
        catch ME %#ok<NASGU>
            v=vstr;
        end
    end
    if ischar(v)
        v=str2num(v);%#ok<ST2NM>
    end
end


function errMsg=l_checkVal(errPName,val,min,max)
    errMsg='';
    if ischar(val)
        val=str2num(val);%#ok<ST2NM>
    end
    if isempty(val)||~isscalar(val)||~isreal(val)||...
        val<min||val>max||~isequal(val,val)
        errMsg=message('soc:msgs:ValueRangeCheck',errPName,num2str(val),num2str(min),num2str(max));
    end
end
function errMsg=l_checkFIFOdepth(errPName,val,min,max)
    errMsg='';
    if ischar(val)
        val=str2num(val);%#ok<ST2NM>
    end
    if isempty(val)||~isscalar(val)||~isreal(val)||...
        val<min||val>max||~isequal(val,val)||~isequal(2^(nextpow2(val)),val)
        errMsg=message('soc:msgs:FIFOdepthCheck',errPName,num2str(val),num2str(min),num2str(max));
    end
end
function errMsg=l_checkValList(errPName,val,valList)
    errMsg='';
    if~any(strcmp(val,valList))
        errMsg=message('soc:msgs:ValueListCheck',errPName,val,strjoin(valList,', '));
    end
end
function newVal=l_convertEvaledListItem(objH,valList,newVal)
    switch l_getCallerType(objH)
    case 'ConfigSetDialog'


        if isnumeric(newVal)
            newVal=valList{newVal+1};
        end
    case{'BlockDialog','ConfigSetObj'}
        if isnumeric(newVal)
            newVal=num2str(newVal);
        end
    end
end

function pb=l_progressBar_on(dlgH,msg)
    pb=[];
    if desktop('-inuse')
        pb=DAStudio.WaitBar;
        pb.setCircularProgressBar(true);
        pb.setLabelText(msg);
        if~isempty(dlgH)
            pos=dlgH.position();
            pb.centreOnLocation(pos(1)+pos(3)/2,pos(2)+pos(4)/2);
        end
        pb.show();
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
...
...
...
...
...
...
