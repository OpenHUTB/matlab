
function[params,groups,FC]=get_Simulink_SolverCC_data(cs)

    compStatus=0;
    params={};


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
        p_disp=configset.internal.custom.FixedStepSizePrompt(cs,'FixedStep');
        p_tooltip=configset.internal.custom.FixedStepSize_TT(cs,'FixedStep');
        params{end+1}={7,{'disp',p_disp},{'prompt',p_disp},{'tooltip',p_tooltip}};
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
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
        params{end+1}={31,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.solver_entries(cs,'SolverName'));
        params{end+1}={32,{'options',p_options}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={35,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={36,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={38,{'widgets',p_widgets}};
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

        p_widgets{1}={};
        params{end+1}={48,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={49,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.SampleTimeProperty(cs,'SampleTimeProperty',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
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
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.oden_solver_entries(cs,'ODENIntegrationMethod'));
        params{end+1}={65,{'options',p_options}};
    end



    if compStatus<3
        p_options=configset.internal.util.convertToOptions(configset.internal.custom.oden_solver_entries(cs,'ODENIntegrationMethod'));
        params{end+1}={66,{'options',p_options}};
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











    g_expand=configset.internal.custom.SolverToggleStatus(cs,'Solver:AdditionalOptions');
    groups{end+1}={'Solver:AdditionalOptions',{'expand',g_expand}};




























