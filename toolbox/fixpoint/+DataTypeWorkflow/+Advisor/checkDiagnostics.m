classdef checkDiagnostics<handle





    methods
        function obj=checkDiagnostics()
        end

    end

    methods(Static)
        function reportObject=runFailSafe(analyzerScope)
            try
                reportObject=DataTypeWorkflow.Advisor.checkDiagnostics.run(analyzerScope);
            catch exDiagnostics
                reportObject{1}=analyzerScope.reportInternalErrorFromExceptionInScope(exDiagnostics);
            end
        end

        function reportObject=run(analyzerScope)

            diagnosticsSetting=[];

            settingOfInterest={'IntegerOverflowMsg','IntegerSaturationMsg','SignalRangeChecking'};
            for i=1:numel(analyzerScope.AllSystemsToScale)
                model=analyzerScope.AllSystemsToScale{i};

                cs=getActiveConfigSet(model);

                checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(model);


                for idx=1:numel(settingOfInterest)
                    settingIdx=settingOfInterest{idx};
                    originalSetting=get_param(cs,settingIdx);


                    if strcmpi(originalSetting,'none')

                        try
                            set_param(cs,settingIdx,'warn');

                            beforeV=originalSetting;
                            afterV=get_param(cs,settingIdx);
                            diagnosticsSetting{end+1}=checkEntry.setPassWithChange(beforeV,afterV);%#ok<AGROW>
                        catch setParamException

                            beforeV=originalSetting;
                            diagnosticsSetting{end+1}=checkEntry.setFailWithoutChange(beforeV,...
                            DataTypeWorkflow.Advisor.internal.CauseRationale(setParamException,'parametersCannotBeUpdated'));%#ok<AGROW>
                        end
                    else

                        diagnosticsSetting{end+1}=checkEntry.setPassWithoutChange();%#ok<AGROW>
                    end
                end

            end


            reportObject=diagnosticsSetting;
        end
    end
end
