function setCSCTypeAttributesPropAndDirty(hUI,hCSCDefn,prop,valOrIdx,entries)




    hObj=hCSCDefn.CSCTypeAttributes;




    if isempty(entries)

        newVal=valOrIdx;
    else

        if isnumeric(valOrIdx)
            newVal=entries{valOrIdx+1};
        else
            DAStudio.error('Simulink:dialog:CSCUIInstComboUnexpectedArgType',class(valOrIdx));
        end
    end

    if ischar(newVal)

        oldVal=DAStudio.Protocol.getPropValue(hObj,prop);


        newVal=strtrim(newVal);


        if~isequal(newVal,oldVal)
            DAStudio.Protocol.setPropValue(hObj,prop,newVal);
            hUI.IsDirty=true;
        end
    else

        oldVal=get(hObj,prop);


        if~isequal(newVal,oldVal)
            set(hObj,prop,newVal);
            hUI.IsDirty=true;
        end
    end


