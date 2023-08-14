function dialogExtensionCallback(hObj,hDlg,value,tag)











    wValTbExe=hDlg.getWidgetValue(hObj.genTag('tlmgTbExeDir'));

    if(~strcmp(wValTbExe,''))
        hWarnDlg=warndlg(...
        ['Any changes to the TLM generator parameters will invalidate ',...
        'the generated testbench.',char(10),char(10),...
        'Click ''Cancel'' if you want to execute the testbench using the ''Verify TLM Component'' button.',char(10),char(10),...
        'Click ''Apply'' if you want to generate a new component and testbench.'],...
        'TLM Testbench Will Be Invalidated','modal');

        set(hWarnDlg,'tag','tlmg warning dialog');
        setappdata(hWarnDlg,'warnId','TLMGenerator:TLMTargetCC:AboutToInvalidateTb');

        hDlg.setWidgetValue(hObj.genTag('tlmgTbExeDir'),'');
        chg=hObj.getDependentChanges('tlmgTbExeDir','');
        hObj.executeChanges(chg,hDlg);
    end

    propName=hObj.getPropFromTag(tag);

    wVal.(propName)=value;
    oVal=l_convertWidgetValsToObjVals(hObj,hDlg,wVal);

    chg=hObj.getDependentChanges(propName,oVal.(propName));

    if(isfield(chg,'val'))
        chg.val=l_convertObjValsToWidgetVals(hObj,hDlg,chg.val);
    end

    if(~isempty(chg))
        hObj.executeChanges(chg,hDlg);
    end

end


function oVals=l_convertWidgetValsToObjVals(hObj,hDlg,wVals)

    for fnames=fieldnames(wVals)'
        propName=fnames{:};
        widgetVal=wVals.(propName);
        widgetTag=hObj.genTag(propName);

        switch(hObj.getPropType(propName))
        case 'enum'
            oVals.(propName)=l_getEnumStrVal(hDlg,widgetVal,widgetTag);
        case 'slbool'
            oVals.(propName)=l_getOnOffVal(hDlg,widgetVal,widgetTag);
        case 'slint'
            oVals.(propName)=l_getIntVal(hDlg,widgetVal,widgetTag);
        case 'double'
            oVals.(propName)=l_getDblVal(hDlg,widgetVal,widgetTag);
        otherwise
            oVals.(propName)=widgetVal;
        end
    end

end

function wVals=l_convertObjValsToWidgetVals(hObj,hDlg,oVals)

    for fnames=fieldnames(oVals)'
        propName=fnames{:};
        objVal=oVals.(propName);
        widgetTag=hObj.genTag(propName);

        switch(hObj.getPropType(propName))
        case 'enum'
            wVals.(propName)=l_getEnumIntVal(hDlg,objVal,widgetTag);
        case 'slbool'
            wVals.(propName)=l_getBoolVal(hDlg,objVal,widgetTag);
        case 'slint'
            wVals.(propName)=l_getIntStrVal(hDlg,objVal,widgetTag);
        case 'double'
            wVals.(propName)=l_getDblStrVal(hDlg,objVal,widgetTag);
        otherwise
            wVals.(propName)=objVal;
        end
    end

end


function strVal=l_getEnumStrVal(hDlg,value,tag)
    propDt=hDlg.getUserData(tag);
    strVal=propDt.Strings{value==propDt.Values};
end


function onoffVal=l_getOnOffVal(~,value,~)
    switch(logical(value))
    case(false),onoffVal='off';
    case(true),onoffVal='on';
    end
end




function intVal=l_getDblVal(~,value,~)
    [intVal,count,errmsg,nextindex]=sscanf(value,'%g');
    if(count~=1||nextindex-1<length(value)||~isempty(errmsg)),intVal=-1;
    end
end




function intVal=l_getIntVal(~,value,~)
    [intVal,count,errmsg,nextindex]=sscanf(value,'%d');
    if(count~=1||nextindex-1<length(value)||~isempty(errmsg)),intVal=-1;
    end
end


function intVal=l_getEnumIntVal(hDlg,value,tag)
    propDt=hDlg.getUserData(tag);
    intVal=propDt.Values(strmatch(value,propDt.Strings));
end


function boolVal=l_getBoolVal(~,value,~)
    switch(value)
    case 'off',boolVal=false;
    case 'on',boolVal=true;
    end
end


function strVal=l_getDblStrVal(~,value,~)
    strVal=sprintf('%g',value);
end


function strVal=l_getIntStrVal(~,value,~)
    strVal=sprintf('%d',value);
end
