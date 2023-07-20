function DefnObject=getRefDefnObj(hThis)





    if isempty(hThis.RefDefnObj)
        DAStudio.error('Simulink:dialog:MSRefDefnNoMSFound');
    end

    DefnObject=hThis.RefDefnObj;



