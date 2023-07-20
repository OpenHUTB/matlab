function doToolstripNotificationAction(method,testingFlag)

    switch(method)
    case 'apps_in_simulink'
        loc_apps_in_simulink();
    case 'menus_to_toolstrip_mappings'
        helpview(strcat(docroot,'/simulink/release-notes.html#simulink_toolstrip_mapping'));
    case 'do_not_show_again'
        SLM3I.SLDomain.setShowToolstripNotificationPreference(false);
    case 'disable_during_testing'
        loc_during_testing('query');
    case 'modify_during_testing_flag'
        loc_during_testing('set',testingFlag);
    otherwise
        error('Method name invalid');
    end
end

function loc_apps_in_simulink()

    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    st=allStudios(1);
    ts=st.getToolStrip();
    ts.ActiveTab='globalAppsTab';
end

function loc_during_testing(modeStr,isEnabled)

    persistent isEnabledToTestToolstripNotificationBarSpecifically;
    if strcmp(modeStr,'set')
        isEnabledToTestToolstripNotificationBarSpecifically=isEnabled;
    elseif isempty(isEnabledToTestToolstripNotificationBarSpecifically)
        isEnabledToTestToolstripNotificationBarSpecifically=false;
    end

    SLM3I.SLDomain.setShowToolstripNotificationPreference(isEnabledToTestToolstripNotificationBarSpecifically);
end