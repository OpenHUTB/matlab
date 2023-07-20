
function[params,groups,FC]=get_CoderTarget_SettingsController_data(cs)

    compStatus=0;
    params={};


    if compStatus<3
        p_WidgetValues=configset.internal.custom.CoderTargetData(cs,'CoderTargetData',0);
        p_value=p_WidgetValues{1};
        params{end+1}={0,{'value',p_value}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end


    groups={};
