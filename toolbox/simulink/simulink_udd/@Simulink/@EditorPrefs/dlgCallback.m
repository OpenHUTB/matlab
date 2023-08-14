function[success,msg]=dlgCallback(obj,dlg,action)











    switch action
    case{'Ok','Apply'}
        i_ok(obj,dlg)
    otherwise

    end
    success=true;
    msg='';
end

function i_ok(obj,dlg)


    set_param(obj.SimulinkHandle,'FastRestartButtonVisible',i_onoff(dlg.getWidgetValue('FastRestartButton')));
    set_param(obj.SimulinkHandle,'EditorScrollWheelZooms',i_onoff(dlg.getWidgetValue('ScrollWheel')));
    if slfeature('SLContentPreview')~=0
        set_param(obj.SimulinkHandle,'EditorContentPreviewDefaultOn',i_onoff(dlg.getWidgetValue('ContentPreview')));
    end
    set_param(obj.SimulinkHandle,'EditorModernTheme',i_onoff(~dlg.getWidgetValue('EditorTheme')));
    set_param(obj.SimulinkHandle,'EditorSmartEditing',i_onoff(dlg.getWidgetValue('EditorSmartEditing')));
    set_param(obj.SimulinkHandle,'EditorSmartEditingHotParam',i_onoff(dlg.getWidgetValue('EditorSmartEditingHotParam')));
    set_param(obj.SimulinkHandle,'DiagnosticViewerPreference',slmsgviewer.handlePreferenceChange(dlg));

    pxsv=dlg.getWidgetValue('PathXStyle');
    pxss='grad_pin';
    if pxsv==2
        pxss='none';
    elseif pxsv==1
        pxss='hop';
    end
    set_param(obj.SimulinkHandle,'EditorPathXStyle',pxss);

    dastudio_util.GLPreferences.setBoolPref('DAStudio DDG','DDGInPlaceEvaluation',dlg.getWidgetValue('InPlaceValueEvaluationPreference'));
    dastudio_util.GLPreferences.savePrefs();


    if obj.SimulinkHandle==0
        p=Simulink.Preferences.getInstance;
        p.Save;
    end
    dlg.refresh;
end




function onoff=i_onoff(b)
    if b
        onoff='on';
    else
        onoff='off';
    end
end

