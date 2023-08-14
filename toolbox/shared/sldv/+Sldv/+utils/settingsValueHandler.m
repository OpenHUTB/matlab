function features=settingsValueHandler(features,modelH,toStore,testcomp)








    if nargin<4
        testcomp=[];
    end

    configSet=[];
    if~isempty(modelH)
        configSet=getActiveConfigSet(modelH);
    end

    for idx=1:length(features)
        cf=features{idx};

        prevEnabledValue=[];
        if~isempty(configSet)&&configSet.isValidParam(cf{1})&&~configSet.getPropEnabled(cf{1})
            prevEnabledValue=false;
            configSet.setPropEnabled(cf{1},true);
        end

        startIdx=1;
        if isempty(modelH)
            startIdx=2;
        end
        pars={};
        for i=startIdx:length(cf)
            ca=cf{i};
            if ischar(ca)
                ca=['''',ca,''''];%#ok
            else
                ca=num2str(ca);
            end
            pars{end+1}=[ca,','];%#ok
        end
        cmd=[cf{1},'('];
        if(toStore)
            if~isempty(modelH)
                cmd=['get_param(''',getfullname(modelH),''','];
            else
                for idxp=1:length(pars)
                    if strcmp(pars{idxp},'''set'',')
                        pars{idxp}='''get'',';%#ok
                        break;
                    end
                end
            end

            parExpr=cat(2,pars{1:end-1});
            getExpr=[cmd,parExpr(1:end-1),');'];
            getCurrentValue=eval(getExpr);
            if ischar(getCurrentValue)
                getCurrentValue=strrep(getCurrentValue,'''','''''');
            end
            cf{end}=getCurrentValue;

            features{idx}=cf;
        else
            if~isempty(modelH)
                cmd=['set_param(''',getfullname(modelH),''','];
            end

            parExpr=cat(2,pars{:});
            setExpr=[cmd,parExpr(1:end-1),');'];
            eval(setExpr);
        end

        if~isempty(prevEnabledValue)
            configSet.setPropEnabled(cf{1},prevEnabledValue);
        end
    end


    if~isempty(testcomp)&&~isempty(modelH)&&~toStore
        setSldvAnalysisOptions(modelH,testcomp);
    end
end

function setSldvAnalysisOptions(modelH,testcomp)
    try
        settings=testcomp.activeSettings;

        avData=get_param(modelH,'AutoVerifyData');
        if~isempty(avData)&&isfield(avData,'DVopt')
            avData.DVopt=[];
        end

        mode=get(settings,'Mode');
        avData.DVopt.Mode=mode;
        avData.DVopt.MinmaxConstr=get(settings,'DesignMinMaxConstraints');

        switch mode
        case 'TestGeneration'
            avData.DVopt.CoverageObj=settings.getDerivedModelCoverageObjectives();
            avData.DVopt.RelBoundary=get(settings,'IncludeRelationalBoundary');

        case 'DesignErrorDetection'
            avData.DVopt.DeadLogic=get(settings,'DetectDeadLogic');


            if strcmp(avData.DVopt.DeadLogic,'on')
                avData.DVopt.ActiveLogic=get(settings,'DetectActiveLogic');
            else
                avData.DVopt.ActiveLogic='off';
            end




            avData.DVopt.CoverageObj=settings.getDerivedModelCoverageObjectives();

            if slfeature('SLDVCombinedDLRTE')
                avData.DVopt.DivByZero=get(settings,'DetectDivisionByZero');
                avData.DVopt.IntOvf=get(settings,'DetectIntegerOverflow');
                avData.DVopt.MinmaxCheck=get(settings,'DesignMinMaxCheck');
                avData.DVopt.OutOfBound=get(settings,'DetectOutOfBounds');
                if slavteng('feature','DsmHazards')
                    avData.DVopt.DetectDSMAccessViolations=get(settings,'DetectDSMAccessViolations');
                else
                    avData.DVopt.DetectDSMAccessViolations='off';
                end

                avData.DVopt.FloatInf=get(settings,'DetectInfNaN');
                avData.DVopt.FloatNaN=get(settings,'DetectInfNaN');
                avData.DVopt.FloatSubnormal=get(settings,'DetectSubnormal');

                if slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2
                    avData.DVopt.BlockInputRangeViolations=get(settings,'DetectBlockInputRangeViolations');
                else
                    avData.DVopt.BlockInputRangeViolations='off';
                end
                avData=checkDetectBlockConditionsVal(avData,settings);
            else

                if strcmp(avData.DVopt.DeadLogic,'on')
                    avData.DVopt.DivByZero='off';
                    avData.DVopt.IntOvf='off';
                    avData.DVopt.MinmaxCheck='off';
                    avData.DVopt.OutOfBound='off';
                    avData.DVopt.DetectDSMAccessViolations='off';
                    avData.DVopt.FloatInf='off';
                    avData.DVopt.FloatNaN='off';
                    avData.DVopt.FloatSubnormal='off';
                    avData.DVopt.BlockInputRangeViolations='off';
                    avData.DVopt.Hisl_0002='off';
                    avData.DVopt.Hisl_0003='off';
                    avData.DVopt.Hisl_0004='off';
                    avData.DVopt.Hisl_0005='off';
                    avData.DVopt.Hisl_0028='off';
                else
                    avData.DVopt.DivByZero=get(settings,'DetectDivisionByZero');
                    avData.DVopt.IntOvf=get(settings,'DetectIntegerOverflow');
                    avData.DVopt.MinmaxCheck=get(settings,'DesignMinMaxCheck');
                    avData.DVopt.OutOfBound=get(settings,'DetectOutOfBounds');
                    if slavteng('feature','DsmHazards')
                        avData.DVopt.DetectDSMAccessViolations=get(settings,'DetectDSMAccessViolations');
                    else
                        avData.DVopt.DetectDSMAccessViolations='off';
                    end

                    avData.DVopt.FloatInf=get(settings,'DetectInfNaN');
                    avData.DVopt.FloatNaN=get(settings,'DetectInfNaN');
                    avData.DVopt.FloatSubnormal=get(settings,'DetectSubnormal');

                    if slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2
                        avData.DVopt.BlockInputRangeViolations=get(settings,'DetectBlockInputRangeViolations');
                    else
                        avData.DVopt.BlockInputRangeViolations='off';
                    end
                    avData=checkDetectBlockConditionsVal(avData,settings);
                end
            end
        end

        set_param(modelH,'AutoVerifyData',avData);
    catch Mex %#ok<NASGU>

    end
end

function autoVerifyData=checkDetectBlockConditionsVal(autoVerifyData,testCompActiveSettings)
    autoVerifyData.DVopt.Hisl_0002='off';
    autoVerifyData.DVopt.Hisl_0003='off';
    autoVerifyData.DVopt.Hisl_0004='off';
    autoVerifyData.DVopt.Hisl_0005='off';
    autoVerifyData.DVopt.Hisl_0028='off';
    if~isempty(get(testCompActiveSettings,'DetectBlockConditions'))
        if contains(get(testCompActiveSettings,'DetectBlockConditions'),'HISL_0002')
            autoVerifyData.DVopt.Hisl_0002='on';
        end
        if contains(get(testCompActiveSettings,'DetectBlockConditions'),'HISL_0003')
            autoVerifyData.DVopt.Hisl_0003='on';
        end
        if contains(get(testCompActiveSettings,'DetectBlockConditions'),'HISL_0004')
            autoVerifyData.DVopt.Hisl_0004='on';
        end
        if slavteng('feature','Hisl_0005')&&contains(get(testCompActiveSettings,'DetectBlockConditions'),'HISL_0005')
            autoVerifyData.DVopt.Hisl_0005='on';
        end
        if contains(get(testCompActiveSettings,'DetectBlockConditions'),'HISL_0028')
            autoVerifyData.DVopt.Hisl_0028='on';
        end
    end
end


