function targetHardwareChanged(hSrc,varargin)





    narginchk(2,3);
    hCS=hSrc.getConfigSet();
    if loc_isShowWaitBar(hCS)
        waitbarHandle=waitbar(0,DAStudio.message('codertarget:build:InitializingParamWaitMsg'));
        callbackObj=onCleanup(@()progressBarCleanup(waitbarHandle));
    end
    defaultBoardChoice=codertarget.utils.getDefaultHardwareBoardSelection(hCS);
    getHSPChoice=DAStudio.message('codertarget:build:GetHSP');
    if nargin==2
        targetHWNames=codertarget.targethardware.getRegisteredTargetHardwareNames();
        targetHWComboEntries=[defaultBoardChoice,targetHWNames,getHSPChoice];
        lNos=0:numel(targetHWComboEntries);
        assert(isa(varargin{1},'char'),'The second input argument to codertarget.target.targetHardwareChanged must be a string containing the name of the Target Hardware');
        selectionIdx=lNos(ismember(targetHWComboEntries,varargin{1}));
        tfTarget=false;
        if isempty(selectionIdx)

            tfTarget=true;
            hardwareName=varargin{1};
        else
            hardwareName=targetHWComboEntries{selectionIdx+1};
        end
    elseif nargin==3
        hDlg=varargin{1};
        tag=varargin{2};
        assert(isa(hDlg,'DAStudio.Dialog'),'When 3 input arguments are specified to codertarget.target.targetHardwareChanged, the second input argument must be a handle to the Simulink Configuration Parameters Dialog');
        assert(isa(tag,'char'),'When 3 input arguments are specified to codertarget.target.targetHardwareChanged, the third input argument must be string');
        hardwareName=hDlg.getComboBoxText(tag);
    end
    if loc_isShowWaitBar(hCS)
        waitbar(0.2,waitbarHandle);
    end
    switch(hardwareName)
    case defaultBoardChoice
        wasTFTarget=~isempty(target.get('Board',get_param(hCS,'HardwareBoard')));
        if codertarget.target.isCoderTarget(hCS)||wasTFTarget
            set_param(hCS,'HardwareBoard',DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone'));
        elseif isequal(get_param(hCS,'SystemTargetFile'),'realtime.tlc')&&...
            ~isequal(hardwareName,get_param(hCS,'TargetExtensionPlatform'))
            set_param(hCS,'TargetExtensionPlatform','None');
            set_param(hCS,'TargetExtensionData','');
        end
        hCS.setPropEnabled('ProdHWDeviceType',1);
    case getHSPChoice
        set_param(hCS,'HardwareBoard',DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone'));
        if license('test','RTW_Embedded_Coder')&&license('test','Real-Time_Workshop')
            product={'EC','SL','RT'};
        elseif license('test','Real-Time_Workshop')
            product={'SL','RT'};
        else
            product='SL';
        end
        matlab.addons.supportpackage.internal.explorer.showSupportPackagesForBaseProducts(product,'tripwire');
    otherwise
        if loc_isShowWaitBar(hCS)
            waitbar(0.8,waitbarHandle);
        end
        if tfTarget
            if codertarget.target.isCoderTarget(hCS)
                codertarget.target.useCoderTarget(hCS,false);
                codertarget.data.setData(hCS,[]);
            end
            set_param(hCS,'HardwareBoard',hardwareName);
            enabled=false;
        elseif loc_isSelectedHWUsingRealtimeTarget(hardwareName)

            if codertarget.target.isCoderTarget(hCS)&&~loc_areCoderLicensed
                hCS.detachComponent('Coder Target');
                codertarget.target.updateCSOptionsForCoderTarget(hCS,'exit');
                set_param(hCS,'HardwareBoard',DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone'));
            end
            loc_setModelForRealtimeTarget(hCS,hardwareName);
            enabled=false;
        else
            set_param(hCS,'HardwareBoard',hardwareName);
            hw=codertarget.targethardware.getTargetHardware(hCS);
            enabled=hw.EnableProdHWDeviceType;
            loc_clearWidgetDirtyFlags(hCS);
        end
        hCS.setPropEnabled('ProdHWDeviceType',enabled);
    end

    if loc_isShowWaitBar(hCS)
        waitbarHandle.delete;
    end
end



function coderLicensePresent=loc_areCoderLicensed
    coderLicensePresent=license('test','Real-Time_Workshop')&&...
    license('test','RTW_Embedded_Coder');
end



function loc_setModelForRealtimeTarget(hCS,hardwareName)
    if~isequal(get_param(hCS,'SystemTargetFile'),'realtime.tlc')
        hDlg=hCS.getDialogHandle;
        hCS.switchTarget('realtime.tlc','');
        hDlg.setWidgetValue('Tag_ConfigSet_RTW_SystemTargetFile','realtime.tlc');
        hCS.Name='Run on Hardware Configuration';
    elseif isequal(hardwareName,get_param(hCS,'TargetExtensionPlatform'))
        return
    end
    set_param(hCS,'TargetExtensionPlatform',hardwareName);
    fname=realtime.getDataFileName('targetInfo',hardwareName);
    info=realtime.getParameterTemplate(hCS);
    realtime.initializeData(hCS,info);
    targetInfo=realtime.TargetInfo(fname,hardwareName,hCS.getModel);
    loc_setProdHWDeviceType(hCS,targetInfo.ProdHWDeviceType);
    set_param(hCS.getModel,'ExtModeTrigDuration',targetInfo.ExtModeTrigDuration);
    set_param(hCS,'ExtModeTransport',targetInfo.ExtModeTransport);
    if~isempty(targetInfo.ExtModeMexArgsInit)
        set_param(hCS,'ExtModeMexArgs',targetInfo.ExtModeMexArgsInit);
    end
    realtime.setModelForRTT(hCS,true);
end


function ret=loc_isSelectedHWUsingRealtimeTarget(hardwareName)
    hardwareUsingRealtimeSTF=realtime.getRegisteredTargets;
    ret=ismember(hardwareName,hardwareUsingRealtimeSTF);
end



function loc_setProdHWDeviceType(hCS,deviceType)



    prop='ProdHWDeviceType';
    oldEnable=getPropEnabled(hCS,prop);
    setPropEnabled(hCS,prop,true);
    set_param(hCS,prop,deviceType);
    setPropEnabled(hCS,prop,oldEnable);
end



function ret=loc_isShowWaitBar(hCS)
    try
        ret=~isequal(get_param(hCS.getModel,'BuildInProgress'),'on');
    catch

        ret=true;
    end
end



function loc_clearWidgetDirtyFlags(hCS)



    hDlg=hCS.getDialogHandle;
    if~isempty(hDlg)&&hDlg.isWidgetValid('Tag_ConfigSet_CoderTarget_Target_RTOS')
        hDlg.clearWidgetDirtyFlag('Tag_ConfigSet_CoderTarget_Target_RTOS');
    end
    if~isempty(hDlg)&&hDlg.isWidgetValid('Tag_ConfigSet_CoderTarget_Scheduler_interrupt_source')
        hDlg.clearWidgetDirtyFlag('Tag_ConfigSet_CoderTarget_Scheduler_interrupt_source');
    end
end



function progressBarCleanup(waitbarHandle)
    if~isempty(waitbarHandle)&&waitbarHandle.isvalid
        waitbarHandle.delete;
    end
end
