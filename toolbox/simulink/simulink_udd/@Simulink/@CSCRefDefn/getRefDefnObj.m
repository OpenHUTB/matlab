function DefnObject=getRefDefnObj(hThis)





    if isempty(hThis.RefDefnObj)
        DAStudio.error('Simulink:dialog:CSCRefDefnNoCSCFound');
    end

    DefnObject=hThis.RefDefnObj;



