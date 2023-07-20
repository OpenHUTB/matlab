function schema=PostRunDataDisplayMenu(fncname,cbinfo,eventData)


    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function schema=RemoveAllValuePlotsDisabled(cbinfo)
    schema=sl_action_schema;
    schema.tag=['Simulink:RemoveAllValuePlots'];
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('physmod:simscape:simscape:menus:RemoveAllValuePlots');
    else
        schema.icon='valueLabelSparklineRemoveAll';
    end
    schema.state='Disabled';
    schema.autoDisableWhen='Never';
end

function schema=RemoveAllValuePlots(cbinfo)
    schema=RemoveAllValuePlotsDisabled(cbinfo);
    schema.state='Enabled';
    schema.callback=@RemoveAllValuePlotsCB;
end

function RemoveAllValuePlotsCB(cbinfo)
    SLM3I.SLCommonDomain.removeAllValuePlots(cbinfo.editorModel.handle);
end

function schema=ToggleValuePlotsDisabled(cbinfo)
    schema=sl_toggle_schema;
    schema.tag=['Simulink:ToggleValuePlots'];
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('physmod:simscape:simscape:menus:TogglePlotTool');
    else
        schema.icon='valueLabelSparkline';
    end

    schema.checked='Checked';
    schema.state='Disabled';
    schema.autoDisableWhen='Never';
end

function schema=ToggleValuePlots(cbinfo)
    schema=ToggleValuePlotsDisabled(cbinfo);
    schema.state='Enabled';
    currentMode=SLM3I.SLCommonDomain.getValuePlotDisplayMode(cbinfo.editorModel.handle);
    if(currentMode==1)
        newMode=0;
        schema.checked='Checked';
    else
        newMode=1;
        schema.checked='Unchecked';
    end
    schema.userdata=newMode;
    schema.callback=@ValuePlotDisplayModeCB;
end

function ValuePlotDisplayModeCB(cbinfo,~)
    newMode=cbinfo.userdata;
    SLM3I.SLCommonDomain.setValuePlotDisplayMode(cbinfo.editorModel.handle,newMode);
end


