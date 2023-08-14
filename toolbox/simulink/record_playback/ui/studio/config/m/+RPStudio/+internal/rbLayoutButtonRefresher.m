function schema=rbLayoutButtonRefresher(userData,cbinfo,action)


    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end

    schema=sl_action_schema;

    if isempty(cbinfo.uiObject.Handle)
        return;
    end

    layoutType=get_param(cbinfo.uiObject.Handle,'Layout');

    switch(layoutType)
    case DAStudio.message('record_playback:params:Auto')
        if strcmp(userData,'LayoutAuto')
            action.selected=1;
        end
    case '[1 1]'
        if strcmp(userData,'Layout1by1')
            action.selected=1;
        end
    case '[2 1]'
        if strcmp(userData,'Layout2by1')
            action.selected=1;
        end
    case '[1 2]'
        if strcmp(userData,'Layout1by2')
            action.selected=1;
        end
    case '[2 2]'
        if strcmp(userData,'Layout2by2')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:RowTop')
        if strcmp(userData,'LayoutRowTop')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:RowRight')
        if strcmp(userData,'LayoutRowRight')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:RowBottom')
        if strcmp(userData,'LayoutRowBottom')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:RowLeft')
        if strcmp(userData,'LayoutRowLeft')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:OverlayTop')
        if strcmp(userData,'LayoutOverlayTop')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:OverlayRight')
        if strcmp(userData,'LayoutOverlayRight')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:OverlayBottom')
        if strcmp(userData,'LayoutOverlayBottom')
            action.selected=1;
        end
    case DAStudio.message('record_playback:params:OverlayLeft')
        if strcmp(userData,'LayoutOverlayLeft')
            action.selected=1;
        end
    otherwise
        if strcmp(userData,'CustomGrid')
            action.selected=1;
        end
    end
end