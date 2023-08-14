
function[params,groups,FC]=get_pslink_ConfigComp_data(cs)

    compStatus=0;
    params={};


    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.pslink_VerificationModeValue(cs,'PSVerificationMode',0);
        p_value=p_WidgetValues{1};
        params{end+1}={0,{'value',p_value}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.pslink_VerificationSettingsValues(cs,'PSVerificationSettings',0);
        p_widgets=cell(1,3);

        w_value=p_WidgetValues{1};
        w_st=configset.internal.custom.pslink_VerificationSettings(cs,'PSVerificationSettings');
        p_widgets{1}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};

        w_value=p_WidgetValues{3};
        p_widgets{3}={{'value',w_value}};
        params{end+1}={1,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.pslink_VerificationSettings(cs,'PSCxxVerificationSettings');
        params{end+1}={2,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={4,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.pslink_AdditionalFileListValues(cs,'PSEnableAdditionalFileList',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={5,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={6,{'widgets',p_widgets}};
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
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={18,{'widgets',p_widgets}};
    end



    if compStatus<3
    end


    groups={};




































