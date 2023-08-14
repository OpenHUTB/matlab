
function[params,groups,FC]=get_Simulink_OptimizationCC_data(cs)

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
        p_WidgetValues=configset.internal.customwidget.DefaultParameterBehaviorValues(cs,'DefaultParameterBehavior',0);
        p_widgets=cell(1,4);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        w_st=configset.internal.custom.disableOnInactiveOrDD(cs,'DefaultParamBehaviorConfigure');
        p_widgets{2}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{3};
        w_st=configset.internal.custom.hasAttachedPLCCoder(cs,'PLC_DefaultParameterBehavior');
        p_widgets{3}={{'value',w_value},{'st',w_st}};

        w_value=p_WidgetValues{4};
        w_st=max([configset.internal.custom.hasAttachedPLCCoder(cs,'PLC_DefaultParamBehaviorConfigure'),configset.internal.custom.disableOnInactiveOrDD(cs,'PLC_DefaultParamBehaviorConfigure')]);
        p_widgets{4}={{'value',w_value},{'st',w_st}};
        params{end+1}={4,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,2);

        p_widgets{1}={};

        p_widgets{2}={};
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
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'OptimizeBlockIOStorage',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={19,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'BufferReuse',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={20,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={21,{'widgets',p_widgets}};
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
        params{end+1}={27,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'ExpressionFolding',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={29,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={31,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'EnableMemcpy',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={33,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'MemcpyThreshold',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={34,{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'LocalBlockOutputs',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={39,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'RollThreshold',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={41,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'StateBitsets',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={43,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.OptimizationGRTERTValue(cs,'DataBitsets',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={44,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        p_widgets{1}={};
        params{end+1}={45,{'widgets',p_widgets}};
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
        p_WidgetValues=configset.internal.customwidget.MaxStackSizeValue(cs,'MaxStackSize',0);
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};

        w_value=p_WidgetValues{2};
        p_widgets{2}={{'value',w_value}};
        params{end+1}={59,{'widgets',p_widgets}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_st=configset.internal.custom.isModelAccelerationAllowed(cs,'SimCompilerOptimization');
        params{end+1}={62,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.isModelAccelerationAllowed(cs,'AccelVerboseBuild');
        params{end+1}={63,{'st',p_st}};
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












