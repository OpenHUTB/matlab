function setPropAndDirty(hUI,hObj,prop,valOrIdx,entries)






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
        set(hObj,prop,newVal);
        hUI.IsDirty=true;
    end



