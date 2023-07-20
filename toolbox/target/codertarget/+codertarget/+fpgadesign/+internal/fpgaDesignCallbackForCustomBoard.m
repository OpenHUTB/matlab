function varargout=fpgaDesignCallbackForCustomBoard(varargin)






    persistent dpCheckerMap

    callerObj=varargin{1};
    mdlName=l_getModelName(callerObj);
    if isempty(mdlName)
        varargout={''};
        return;
    end
    hwName=l_getHWBoard(callerObj);

    if l_isProcessorOnlyBoard(callerObj)
        if isequal(l_getCallerType(callerObj),'BlockDialog')
            [blkH,~,caller,blkPath]=varargin{1:4};
            varargout{1}=l_checkFPGACompatibility(blkH,caller,blkPath);
        end
    end

    checkerKey=[mdlName,'.',hwName];

    if isempty(dpCheckerMap)
        dpCheckerMap=containers.Map();
    end
    if dpCheckerMap.isKey(checkerKey)
        dpChecker=dpCheckerMap(checkerKey);
    else
        dpChecker=soc.customboard.internal.DesignParameterChecker(hwName);
        dpCheckerMap(checkerKey)=dpChecker;
    end



    switch l_getCallerType(varargin{1})
    case 'ConfigSetDialog'
        if l_isValueChangeCallback(varargin{2})

            [hObj,hDlg,tag,dlgType]=varargin{1:4};%#ok<ASGLU>
            userData=hDlg.getUserData(tag);
            sName=userData.Storage;
            pName=strrep(sName,'FPGADesign.','');
            widgetVal=hDlg.getWidgetValue(tag);
            widgetVal=hsb.blkcb2.cbutils('TryEval',widgetVal);
            if~isempty(userData.Entries)
                widgetVal=userData.Entries{widgetVal+1};
            end
            [errMsg,valToSet]=feval(['l_check',pName],dpChecker,pName,hObj,widgetVal,'');
            if isempty(errMsg)
                codertarget.data.setParameterValue(hObj.getConfigSet(),sName,valToSet);
            else
                errordlg(errMsg.getString(),'Coder Target Error Dialog','modal');
            end
        elseif strcmp('default',varargin{2})
            [hObj,~,tag,defaultVal]=varargin{1:4};
            sName=tag;
            pName=strrep(sName,'FPGADesign.','');
            if~codertarget.data.isParameterInitialized(hObj,sName)
                tmpstk=dbstack;
                if~any(strcmp({tmpstk.name},'apply'))
                    codertarget.data.setParameterValue(hObj.getConfigSet(),sName,defaultVal);
                    feval(['l_check',pName],dpChecker,pName,hObj,defaultVal,'');
                end
                varargout{1}=defaultVal;
            else
                varargout{1}=codertarget.data.getParameterValue(hObj.getConfigSet(),sName);
            end
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
            errMsg=feval(['l_check',pCSName],dpChecker,pNameOnBlock,blkH,pNewVal,rdOrWr,restOfArgs{:});
            if~isempty(errMsg)
                error(errMsg);
            end
        case 'checkFPGACompatibility'
            [blkH,~,caller,blkPath]=varargin{1:4};
            varargout{1}=l_checkFPGACompatibility(blkH,caller,blkPath);
        case 'getAllFPGABoards'
            varargout{1}=[codertarget.internal.getTargetHardwareNamesForSoC...
            ,'Custom Hardware Board'...
            ,codertarget.internal.getCustomHardwareBoardNamesForSoC];
        otherwise
            error('(internal) bad action for fpgaDesignCallback');
        end

    case 'ConfigSetObj'
        action=varargin{2};
        pName=varargin{3};
        switch action
        case 'manualValueChangeCb'

            [cs,~,~,val]=varargin{1:4};
            fname=['l_check',pName];
            if exist(fname,'file')
                [errMsg,valToSet]=feval(['l_check',pName],dpChecker,pName,cs,val,'');
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
























function[errMsg,pNewVal]=l_checkIncludeProcessingSystem(dpChecker,errPName,objH,pNewVal,~)



    errMsg=dpChecker.checkValue('IncludeProcessingSystem',errPName,pNewVal);
end

function[errMsg,pNewVal]=l_checkAXIHDLUserLogicClock(dpChecker,errPName,objH,pNewVal,~)%#ok<*DEFNU>
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('AXIHDLUserLogicClock',errname,pNewVal);
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('AXIHDLUserLogicClock',errPName,pNewVal);
    end
end











function[errMsg,pNewVal]=l_checkAXIMemorySubsystemClock(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkAXIMemorySubsystemClockPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkAXIMemorySubsystemClockPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemClockPS(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('AXIMemorySubsystemClockPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('AXIMemorySubsystemClockPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemClockPL(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('AXIMemorySubsystemClockPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('AXIMemorySubsystemClockPL',errPName,pNewVal,'PL');
    end
end

function[errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidth(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidthPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidthPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidthPS(dpChecker,errPName,objH,pNewVal,~)
    pNewVal=num2str(pNewVal);
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('AXIMemorySubsystemDataWidthPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('AXIMemorySubsystemDataWidthPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkAXIMemorySubsystemDataWidthPL(dpChecker,errPName,objH,pNewVal,~)
    pNewVal=num2str(pNewVal);
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('AXIMemorySubsystemDataWidthPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('AXIMemorySubsystemDataWidthPL',errPName,pNewVal,'PL');
    end
end

function[errMsg,pNewVal]=l_checkRefreshOverhead(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkRefreshOverheadPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkRefreshOverheadPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkRefreshOverheadPS(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('RefreshOverheadPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('RefreshOverheadPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkRefreshOverheadPL(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('RefreshOverheadPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('RefreshOverheadPL',errPName,pNewVal,'PL');
    end
end

function[errMsg,pNewVal]=l_checkWriteFirstTransferLatency(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkWriteFirstTransferLatencyPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkWriteFirstTransferLatencyPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkWriteFirstTransferLatencyPS(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('WriteFirstTransferLatencyPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('WriteFirstTransferLatencyPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkWriteFirstTransferLatencyPL(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('WriteFirstTransferLatencyPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('WriteFirstTransferLatencyPL',errPName,pNewVal,'PL');
    end
end

function[errMsg,pNewVal]=l_checkReadFirstTransferLatency(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkReadFirstTransferLatencyPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkReadFirstTransferLatencyPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkReadFirstTransferLatencyPS(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('ReadFirstTransferLatencyPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('ReadFirstTransferLatencyPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkReadFirstTransferLatencyPL(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('ReadFirstTransferLatencyPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('ReadFirstTransferLatencyPL',errPName,pNewVal,'PL');
    end
end

function[errMsg,pNewVal]=l_checkWriteLastTransferLatency(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkWriteLastTransferLatencyPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkWriteLastTransferLatencyPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkWriteLastTransferLatencyPS(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('WriteLastTransferLatencyPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('WriteLastTransferLatencyPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkWriteLastTransferLatencyPL(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('WriteLastTransferLatencyPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('WriteLastTransferLatencyPL',errPName,pNewVal,'PL');
    end
end

function[errMsg,pNewVal]=l_checkReadLastTransferLatency(dpChecker,errPName,objH,pNewVal,rdOrWr,PSorPL)
    switch(PSorPL)
    case 'PL memory'
        [errMsg,pNewVal]=l_checkReadLastTransferLatencyPL(dpChecker,errPName,objH,pNewVal,rdOrWr);
    case 'PS memory'
        [errMsg,pNewVal]=l_checkReadLastTransferLatencyPS(dpChecker,errPName,objH,pNewVal,rdOrWr);
    end
end
function[errMsg,pNewVal]=l_checkReadLastTransferLatencyPS(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('ReadLastTransferLatencyPS',errname,pNewVal,'PS');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('ReadLastTransferLatencyPS',errPName,pNewVal,'PS');
    end
end
function[errMsg,pNewVal]=l_checkReadLastTransferLatencyPL(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('ReadLastTransferLatencyPL',errname,pNewVal,'PL');
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('ReadLastTransferLatencyPL',errPName,pNewVal,'PL');
    end
end











function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectInputClock(dpChecker,errPName,objH,pNewVal,rdOrWr)










    errLabel=l_getFriendlyError(objH,errPName,'Interconnect clock frequency');

    isSimTgt=l_isSimOnlyTarget(objH);
    if isSimTgt
        errMsg=dpChecker.checkValue('AXIMemoryInterconnectInputClock',errLabel,pNewVal);
    else

        depVal=l_getDepCSValue(objH,'AXIMemorySubsystemClock',rdOrWr);
        cObj=soc.customboard.internal.ValueConstraints(depVal,depVal,depVal,{});
        errMsg=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectInputClock',errLabel,pNewVal,cObj);
    end

end
function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectInputDataWidth(dpChecker,errPName,objH,pNewVal,~,varargin)















    pNewVal=num2str(pNewVal);
    errMsg='';


    errLabel=l_getFriendlyError(objH,errPName,'Interconnect data width');

    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errMsg=dpChecker.checkValue('AXIMemoryInterconnectInputDataWidth',errLabel,pNewVal);

    case 'BlockDialog'
        isSimTgt=l_isSimOnlyTarget(objH);
        if isSimTgt||isempty(varargin)
            errMsg=dpChecker.checkValue('AXIMemoryInterconnectInputDataWidth',errLabel,pNewVal);
        else
            memchType=varargin{1}{1};
            switch memchType
            case{'AXI4-Stream to Software via DMA','AXI4-Stream FIFO','Software to AXI4-Stream via DMA','AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer'}
                cObj=dpChecker.getValueConstraints('AXIMemoryInterconnectInputDataWidth');
                cObj=soc.customboard.internal.ValueConstraints(0,0,0,cObj.PossibleValues);
                errMsg=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectInputDataWidth',errLabel,pNewVal,cObj);
            case 'AXI4 Random Access'
                okVals{:}=num2str(varargin{1}{2});
                cObj=soc.customboard.internal.ValueConstraints(0,0,0,okVals);
                errMsg=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectInputDataWidth',errLabel,pNewVal,cObj);
                if soc.blkcb.cbutils('SimStatusIsStopped',objH,bdroot(objH))
                    warning(errMsg)
                    errMsg='';
                end
            end
        end
    end
end
function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectFIFODepth(dpChecker,errPName,objH,pNewVal,rdOrWr,varargin)
















    errLabel=l_getFriendlyError(objH,errPName,'Interconnect FIFO depth');

    isSimTgt=l_isSimOnlyTarget(objH);
    if isSimTgt
        errMsg=dpChecker.checkValue('AXIMemoryInterconnectFIFODepth',errLabel,pNewVal);
        if isempty(errMsg)
            min=l_getDepCSValue(objH,'AXIMemoryInterconnectFIFOAFullDepth',rdOrWr);
            cObj=soc.customboard.internal.ValueConstraints(0,min,inf,{});
            err=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectFIFODepth',errLabel,pNewVal,cObj);
            if~isempty(err)
                errMsg=message('soc:msgs:ICFIFOdepthLessThanAFull',errPName(10:end),num2str(pNewVal),num2str(min));
            end
        end
    else
        if~isempty(varargin)
            val=varargin{:};
            switch val{1}
            case{'AXI4-Stream to Software via DMA','AXI4-Stream FIFO','Software to AXI4-Stream via DMA','AXI4-Stream Video FIFO','AXI4-Stream Video Frame Buffer'}
                min=2;
                max=32;
                cObj=soc.customboard.internal.ValueConstraints(0,min,max,{});
                err=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectFIFODepth',errLabel,pNewVal,cObj);
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
                    cObj=soc.customboard.internal.ValueConstraints(0,min,inf,{});
                    err=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectFIFODepth',errLabel,pNewVal,cObj);
                    if~isempty(err)
                        errMsg=message('soc:msgs:ICFIFOdepthLessThanAFull',errPName(10:end),num2str(pNewVal),num2str(min));
                    end
                end
            otherwise
                errMsg='';
            end
        else


            errMsg=dpChecker.checkValue('AXIMemoryInterconnectFIFODepth',errLabel,pNewVal);
            if isempty(errMsg)
                min=l_getDepCSValue(objH,'AXIMemoryInterconnectFIFOAFullDepth',rdOrWr);
                cObj=soc.customboard.internal.ValueConstraints(0,min,inf,{});
                err=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectFIFODepth',errLabel,pNewVal,cObj);
                if~isempty(err)
                    errMsg=message('soc:msgs:ICFIFOdepthLessThanAFull',errPName(10:end),num2str(pNewVal),num2str(min));
                end
            end
        end
    end
end
function[errMsg,pNewVal]=l_checkAXIMemoryInterconnectFIFOAFullDepth(dpChecker,errPName,objH,pNewVal,rdOrWr,varargin)













    errLabel=l_getFriendlyError(objH,errPName,'Interconnect almost-full depth');

    if length(varargin)==1
        depVal=varargin{1};
    else
        depVal=l_getDepCSValue(objH,'AXIMemoryInterconnectFIFODepth',rdOrWr);
    end
    cObj=soc.customboard.internal.ValueConstraints(1,1,depVal,{});

    errMsg=dpChecker.checkValueSpecifiedConstraints('AXIMemoryInterconnectFIFOAFullDepth',errLabel,pNewVal,cObj);
end




function[errMsg,pNewVal]=l_checkMemChDiagLevel(dpChecker,errPName,objH,pNewVal,rdOrWr,varargin)
    try
        csH=l_getCS(objH);
        dlgH=csH.getDialogHandle();

        pb=l_progressBar_on(dlgH,'Updating memory diagnostic level. Please wait...');%#ok<NASGU>

        pNewVal=num2str(pNewVal);
        errMsg=dpChecker.checkValue('MemChDiagLevel',errPName,pNewVal);

        mdlLogging=get_param(csH,'SignalLogging');
        if strcmp(mdlLogging,'off')&&~strcmp(pNewVal,'No debug')
            error(message('soc:msgs:ModelLoggingDisabled'));
        end
        storedVal=l_getDepCSValue(objH,'MemChDiagLevel',rdOrWr);

        soc.blkcb.cbutils('CallAllRegisteredSetupViewerCbs',objH.getModel,storedVal,pNewVal);

    catch ME
        errMsg=message('soc:msgs:MemChDiagLevelCheck',errPName,pNewVal,ME.message());
    end
end
function[errMsg,pNewVal]=l_checkNumberOfTraceEvents(dpChecker,errPName,objH,pNewVal,~)
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}
        errname=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errMsg=dpChecker.checkValue('NumberOfTraceEvents',errname,pNewVal);
    case 'BlockDialog'
        errMsg=dpChecker.checkValue('NumberOfTraceEvents',errPName,pNewVal);
    end
end




function isSimTgt=l_isSimOnlyTarget(objH)
    cs=l_getCS(objH);
    ti=codertarget.targethardware.getTargetHardware(cs);
    isSimTgt=ti.SupportsOnlySimulation;
end
function errLabel=l_getFriendlyError(objH,errPName,errFriendlyName)
    csLink='<a href="matlab: hsb.blkcb2.MemoryChannelCbV1(''MaskLinkCb'',''HardwareBoardLink'',gcbh)">Configset</a>';
    switch l_getCallerType(objH)
    case{'ConfigSetDialog','ConfigSetObj'}



        efn=DAStudio.message(['codertarget:ui:FPGADesign',errPName]);
        errLabel=[efn,' in Configset'];
    case 'BlockDialog'
        efn=errFriendlyName;
        fromConfigSet=get_param(objH,'UseValuesFromTargetHardwareResources');
        if strcmp(fromConfigSet,'on')


            errLabel=[efn,' in ',csLink];
        elseif contains(errPName,'Writer','IgnoreCase',true)
            errLabel=[efn,' for writer'];
        elseif contains(errPName,'Reader','IgnoreCase',true)
            errLabel=[efn,' for reader'];
        else
            errLabel=errPName;
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
function mdl=l_getModelName(objH)
    cs=l_getCS(objH);
    mdl=getfullname(cs.getModel());
end
function hw=l_getHWBoard(objH)
    cs=l_getCS(objH);
    try
        hw=codertarget.data.getParameterValue(cs,'TargetHardware');
    catch ME %#ok<NASGU>
        hw='None';
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
function v=l_getDepCSValue(objH,pName,~)
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
function errMsg=l_checkValList(errPName,val,valList)
    errMsg='';
    if~any(strcmp(val,valList))
        errMsg=message('soc:msgs:ValueListCheck',errPName,val,strjoin(valList,', '));
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
function res=l_isProcessorOnlyBoard(objH)
    cs=l_getCS(objH);
    hasFPGA=codertarget.targethardware.isESBCompatible(cs,2);
    res=~hasFPGA;
end

