
function rbMapPlotTabRefresher(userData,cbinfo,action)


    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end

    pref=get_param(cbinfo.uiObject.Handle,'PlotPreferences');
    currView=pref.Map.Type;
    switch currView
    case DAStudio.message('record_playback:params:Street')
        if strcmp(userData,'rbStreet')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:Satellite')
        if strcmp(userData,'rbSatelite')
            action.selected=1;
        end
    end
end