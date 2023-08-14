function listeners_manager(fcn,modelHandle)

    persistent listeners;
    if isempty(listeners)
        listeners=Simulink.sdi.Map(0.0,?handle);
    end
    switch fcn
    case 'add'
        if~listeners.isKey(modelHandle)
            try
                mObj=get_param(modelHandle,'Object');
                L=Simulink.listener(mObj,...
                'EngineUpdatedDuringSim',...
                @(bd,lo)simulink.hmi.listeners_manager(...
                'var_update',bd.Handle));
                listeners.insert(modelHandle,L);
            catch me %#ok<NASGU>
            end
        end
    case 'remove'
        if listeners.isKey(modelHandle)
            L=listeners.getDataByKey(modelHandle);
            delete(L);
            listeners.deleteDataByKey(modelHandle);
        end
    case 'clear'
        listeners.clear();
    case 'var_update'
        webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
        webhmi.updateVariableControls();
    otherwise
        disp(['Invalid function: ',fcn]);
    end
end
