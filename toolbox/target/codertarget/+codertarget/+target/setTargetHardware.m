function setTargetHardware(hCS,hardwareName)




    tmpstk=dbstack;
    if any(strcmp({tmpstk.name},'updateExtension'))||...
        any(strcmp({tmpstk.name},'configDlgAction'))
        return
    end

    if isa(hCS,'Simulink.ConfigSet')

    elseif isa(hCS,'CoderTarget.SettingsController')
        hCS=hCS.getConfigSet();
    elseif ischar(hCS)
        hCS=getActiveConfigSet(hCS);
    else
        error(message('codertarget:api:settargethardwarewrongargument1'));
    end

    if~ischar(hardwareName)||~isvector(hardwareName)
        error(message('codertarget:api:settargethardwarewrongargument2'));
    end

    targetFrameworkBoard=target.internal.Board.empty();
    if~ismember(hardwareName,codertarget.targethardware.getRegisteredTargetHardwareNames)&&...
        ~isequal(hardwareName,DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone'))


        [isTFTarget,targetFrameworkBoard]=codertarget.utils.isTargetFrameworkTarget(hardwareName);
        if~isTFTarget
            error(message('codertarget:api:settargethardwareunknownhardware'));
        end
    end









    if codertarget.target.isCoderTarget(hCS)&&...
        ~isequal(hardwareName,codertarget.data.getParameterValue(hCS,'TargetHardware'))
        targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
        if~isempty(targetInfo)&&~isempty(targetInfo.getOnHardwareDeselectHook)
            feval(targetInfo.getOnHardwareDeselectHook,hCS);
        end
    end

    if isempty(targetFrameworkBoard)
        switch hardwareName
        case DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone')
            enable=true;
            if codertarget.target.isCoderTarget(hCS)
                lockguard=configset.internal.util.getConfigSetAdapterLockGuard(hCS.getConfigSetCache);%#ok<NASGU>
                codertarget.target.useCoderTarget(hCS,false);
            end
        otherwise
            lockguard=configset.internal.util.getConfigSetAdapterLockGuard(hCS.getConfigSetCache);%#ok<NASGU>
            codertarget.target.setModelForCoderTarget(hCS,hardwareName);
            loc_clearWidgetDirtyFlags(hCS);
            hw=codertarget.targethardware.getTargetHardware(hCS);
            enable=hw.EnableProdHWDeviceType;
        end

    else
        enable=false;
        loc_setModelForTargetFrameworkTarget(hCS,targetFrameworkBoard);
    end

    hCS.setPropEnabled('ProdHWDeviceType',enable);

end



function loc_setModelForTargetFrameworkTarget(hCS,board)

    if codertarget.target.isCoderTarget(hCS)






        codertarget.target.useCoderTarget(hCS,false);
    end
    codertarget.data.setData(hCS,[]);





    p=board.Processors(1);
    hCS.setPropEnabled('ProdHWDeviceType',true)
    set_param(hCS,'ProdHWDeviceType',p.getQualifiedParameterString());
    hCS.setPropEnabled('ProdHWDeviceType',false);
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

