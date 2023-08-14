function schema=displayMenu(fcnName,cbInfo)




    fcn=str2func(['l',fcnName]);
    schema=fcn(cbInfo);

end

function schema=lMainEntry(cbInfo)
    schema=sl_container_schema;
    schema.tag='Simulink:SimscapeDisplayMenu';
    schema.label='&Simscape';
    schema.state='Enabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    schema.autoDisableWhen='Never';

    im=DAStudio.InterfaceManagerHelper(cbInfo.studio,'Simulink');
    children={im.getAction('Simulink:SimscapeStylingEnableDisable'),...
    im.getAction('Simulink:SimscapeStylingLegend'),...
    'separator',...
    im.getAction('Simulink:ToggleValuePlots'),...
    im.getAction('Simulink:RemoveAllValuePlots')};

    schema.childrenFcns=children;
end

function schema=lSimscapeStylingEnable(cbInfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimscapeStylingEnableDisable';
    schema.label=DAStudio.message('physmod:simscape:simscape:menus:DomainStyles');
    schema.callback=@lUpdateStyles;
    modelName=getfullname(cbInfo.editorModel.handle);
    schema.autoDisableWhen='Never';
    if(simscape.internal.styleModel(modelName))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end

function schema=lSimscapeStylingLegend(cbInfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SimscapeStylingLegend';
    schema.label=DAStudio.message('physmod:simscape:simscape:menus:Legend');
    schema.callback=@lShowLegend;
    schema.autoDisableWhen='Never';
end

function lUpdateStyles(cbInfo)
    modelName=getfullname(cbInfo.editorModel.handle);
    if simscape.internal.styleModel(modelName)
        simscape.internal.styleModel(modelName,false);
    else
        simscape.internal.styleModel(modelName,true);
    end

end

function lShowLegend(~)
    persistent d;
    if isempty(d)
        d=simscape.internal.DomainStyleLegend;
    end
    d.show();
end
