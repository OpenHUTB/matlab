function setDefaults(hObj,cs)





    set_param(cs,'LifeSpan','auto');

    if isValidParam(cs,'PassReuseOutputArgsThreshold')
        set_param(cs,'PassReuseOutputArgsThreshold',12);
    end





    if(slfeature('InlinePrmsAsCodeGenOnlyOption')==1&&...
        slfeature('ERTInlineOn')==1)

        set_param(cs,'InlineParams','on');
    end

    if strcmp(hObj.InMdlLoading,'off')

        set_param(cs,'RemoveResetFunc','on');
        set_param(cs,'ConvertIfToSwitch','on');
        set_param(cs,'SuppressUnreachableDefaultCases','on');





        set_param(cs,'ZeroExternalMemoryAtStartup','off');
        set_param(cs,'ZeroInternalMemoryAtStartup','off');

        set_param(cs,'MATLABDynamicMemAlloc','off');


        set_param(cs,'GenerateComments','on');
        set_param(cs,'SimulinkBlockComments','on');
        set_param(cs,'StateflowObjectComments','off');
        set_param(cs,'SimulinkDataObjDesc','on');
        set_param(cs,'InsertBlockDesc','on');
        set_param(cs,'ForceParamTrailComments','on');
        set_param(cs,'SFDataObjDesc','on');
        set_param(cs,'MATLABFcnDesc','off');
        set_param(cs,'MATLABSourceComments','off');
        set_param(cs,'OperatorAnnotations','on');
        set_param(cs,'ShowEliminatedStatement','on');


    end

    if strcmp(hObj.InMdlLoading,'off')
        if isValidParam(cs,'PassReuseOutputArgsAs')
            set_param(cs,'PassReuseOutputArgsAs','Individual arguments');
        end
    else
        if isValidParam(cs,'PassReuseOutputArgsAs')
            set_param(cs,'PassReuseOutputArgsAs','Structure');
        end
    end

    if strcmp(hObj.InMdlLoading,'off')
        set_param(cs,'OptimizeBlockIOStorage','on');

        set_param(cs,'OptimizationPriority','Balanced');
        set_param(cs,'OptimizationLevel','level2');
        set_param(cs,'OptimizationCustomize','off');



        cs.getComponent('Optimization').setPropEnabled('EfficientTunableParamExpr',true);
        set_param(cs,'EfficientTunableParamExpr','on');
    end

    if strcmp(hObj.InMdlLoading,'off')




























        set_param(cs,'ParameterTunabilityLossMsg','error');
    end

end



