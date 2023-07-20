
function[params,groups,FC]=get_Simulink_SFSimCC_data(cs)

    compStatus=0;
    params={};


    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={0,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        w_st=max([configset.internal.custom.hideOnStandalone(cs,'AutoInferHeaders'),SLCC.configset.DisableAutoInferBtn(cs,'AutoInferHeaders')]);
        p_widgets{2}={{'st',w_st}};
        params{end+1}={2,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={4,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={6,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.ReservedNameArray(cs,'SimReservedNameArray',0);
        p_value=p_WidgetValues{1};
        params{end+1}={8,{'value',p_value}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={9,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={10,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={12,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={13,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.isLib(cs,'SimUseLocalCustomCode');
        params{end+1}={24,{'st',p_st}};
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        w_st=configset.internal.custom.hideOnStandalone(cs,'ParseCustomCodeBtn');
        p_widgets{2}={{'st',w_st}};
        params{end+1}={25,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.CustomCodeFunctionArrayLayout(cs,'CustomCodeFunctionArrayLayout',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={43,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={49,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={50,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.SimDLTargetLibrary(cs,'SimDLTargetLibrary'));
        p_widgets{1}={{'options',w_options}};
        params{end+1}={62,{'widgets',p_widgets}};
    end



    if compStatus<3
    end


    groups={};































































