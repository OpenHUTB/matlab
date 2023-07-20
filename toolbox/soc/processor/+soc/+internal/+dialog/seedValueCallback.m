function seedValueCallback(hObj,hDlg,tag,~)




    cs=hObj.getConfigSet();
    ud=hDlg.getUserData(tag);
    fieldName=ud.Storage;
    newVal=hDlg.getWidgetValue(tag);



    if~iscvar(newVal)&&~isequal(newVal,'default')
        rawVal=(str2double(strtrim(newVal)));
        intVal=uint64(rawVal);
        if isempty(intVal)||~isscalar(intVal)||~isreal(intVal)||...
            intVal<0||intVal>4294967295||~isequal(rawVal,intVal)
            str=DAStudio.message('codertarget:ui:SeedValueInvalid');
            errordlg(str,'Error','modal');
            curVal=codertarget.data.getParameterValue(cs,fieldName);
            hDlg.setWidgetValue(tag,curVal);
            return
        end
    end
    codertarget.data.setParameterValue(cs,fieldName,newVal);
end
