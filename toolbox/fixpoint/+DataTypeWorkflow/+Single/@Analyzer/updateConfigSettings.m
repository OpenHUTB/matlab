function[solverSettingResults,configSettingResults]=updateConfigSettings(analyzer)




    solverSettingResults={};
    configSettingResults={};
    for i=1:numel(analyzer.AllSystemsToScale)

        model=analyzer.AllSystemsToScale{i};

        cs=getActiveConfigSet(model);

        if~DataTypeWorkflow.Single.Utils.checkConfigSetRef(model)


            originalSolverType=get_param(cs,'SolverType');

            if strcmp(originalSolverType,'Variable-step')



                set_param(cs,'SolverType','Fixed-step');
                set_param(cs,'Solver','FixedStepAuto');
                set_param(cs,'SolverMode','Auto');
                set_param(cs,'AutoInsertRateTranBlk','on');


                resSolver.System=model;
                resSolver.OriginalSolverSetting=originalSolverType;
                resSolver.AfterSolverSettting=get_param(cs,'SolverType');
                solverSettingResults{end+1}=resSolver;%#ok<AGROW>
            end


            resConfig.System='';

            originalGenCommentField=get_param(cs,'GenerateComments');
            if strcmp(originalGenCommentField,'off')
                if cs.getPropEnabled('GenerateComments')

                    set_param(cs,'GenerateComments','on');

                    resConfig.System=model;
                    resConfig.OriginalGenCommentSetting=originalGenCommentField;
                    resConfig.AfterGenCommentSettting=get_param(cs,'GenerateComments');
                end
            end


            originalPrecisionLossMsg=get_param(cs,'ParameterPrecisionLossMsg');
            if~strcmp(originalPrecisionLossMsg,'None')
                if cs.getPropEnabled('ParameterPrecisionLossMsg')

                    set_param(cs,'ParameterPrecisionLossMsg','None');

                    resConfig.System=model;
                    resConfig.OriginalPrecisionSetting=originalPrecisionLossMsg;
                    resConfig.AfterPrecisionSettting=get_param(cs,'ParameterPrecisionLossMsg');
                end
            end

            if~isempty(resConfig.System)

                configSettingResults{end+1}=resConfig;%#ok<AGROW>
            end
        end
    end
