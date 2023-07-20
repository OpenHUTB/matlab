
function[params,groups,FC]=get_SlCovCC_ConfigComp_data(cs)

    mcs=configset.internal.getConfigSetStaticData;
    mcc=mcs.getComponent('SlCovCC.ConfigComp');
    if isempty(mcc);compStatus=3;elseif isempty(mcc.Dependency);compStatus=0;else;compStatus=mcc.Dependency.getStatus(cs,'');end
    params={};


    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={1,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.SlCovButtonValue(cs,'CovPath',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        w_st=configset.internal.custom.disableOnStandalone(cs,'SelectSubsystem');
        p_widgets{1}={{'value',w_value},{'st',w_st}};
        params{end+1}={2,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.SlCovButtonValue(cs,'CovModelRefExcluded',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        w_st=configset.internal.custom.disableOnStandalone(cs,'SelectModels');
        p_widgets{1}={{'value',w_value},{'st',w_st}};
        params{end+1}={3,{'widgets',p_widgets}};
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


    groups={};




































