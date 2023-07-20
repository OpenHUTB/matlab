function setPropAndDirty(hObj,prop,valOrIdx,hUI,entries)




    if isempty(entries)
        newVal=valOrIdx;


        if(ischar(newVal))
            newVal=strtrim(newVal);
        end

    else
        if~isnumeric(valOrIdx)
            DAStudio.error('Simulink:dialog:CSCUIInstComboUnexpectedArgType',class(valOrIdx));
        end
        newVal=entries{valOrIdx+1};
    end




    oldVal=get(hObj,prop);




    if~isequal(newVal,oldVal)
        try
            tmpstr='set(hObj, prop, newVal)';
            errs=evalc(tmpstr);
            if~isempty(errs)
                warndlg(errs,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
            end
            hUI.IsDirty=true;
        catch err
            errordlg(err.message,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        end
    end


