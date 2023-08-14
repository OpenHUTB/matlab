classdef checkTargetHardware<handle




    properties(Constant,Access=private)

        defaultDeviceTypeStr='Intel->x86-64 (Windows64)';
        genericDeviceValue1='Generic->Unspecified (assume 32-bit Generic)';
        genericDeviceValue2='32-bit Generic';
    end

    methods
        function obj=checkTargetHardware()
        end
    end

    methods
        function reportObject=runFailSafe(this,analyzerScope)
            try
                reportObject=this.run(analyzerScope);
            catch exHWTarget
                reportObject{1}=analyzerScope.reportInternalErrorFromExceptionInScope(exHWTarget);
            end
        end

        function reportObject=run(this,analyzerScope)


            deviceTypeResult=[];


            sudSystem=analyzerScope.SelectedSystem;
            sudSettingValue=DataTypeWorkflow.Advisor.Utils.getTargetSettingValueFromActiveConfigSet(sudSystem);
            sudTargetSettingValue=sudSettingValue.ProdHWDeviceType;


            systemNeedsChange=bdroot(sudSystem);
            checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(systemNeedsChange);



            if this.isGenericOrUnspecified(sudTargetSettingValue)
                deviceTypeResult{end+1}=checkEntry.setFailWithoutChange(sudSettingValue,...
                DataTypeWorkflow.Advisor.internal.CauseRationale([],'topModelUseGeneric'));
            else


                checkEntry.BeforeValue=sudSettingValue;
                deviceTypeResult{end+1}=checkEntry.setPassWithoutChange();

                modelsInHierarchy=analyzerScope.AllSystemsToScale;

                modelsInHierarchy(ismember(modelsInHierarchy,systemNeedsChange))=[];



                deviceTypeResult=this.prepareModelHierarchy(sudTargetSettingValue,modelsInHierarchy,deviceTypeResult);
            end


            reportObject=deviceTypeResult;

        end
    end

    methods(Access={?tcheckTargetHardware})
        function deviceTypeResult=prepareModelHierarchy(~,sudTargetSettingValue,modelsInHierarchy,deviceTypeResult)


            for i=1:numel(modelsInHierarchy)

                model=modelsInHierarchy{i};
                checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(model);


                originalSettings=DataTypeWorkflow.Advisor.Utils.getTargetSettingValueFromActiveConfigSet(model);

                if strcmpi(sudTargetSettingValue,originalSettings.ProdHWDeviceType)

                    deviceTypeResult{end+1}=checkEntry.setPassWithoutChange();%#ok<AGROW>
                else

                    status=DataTypeWorkflow.Advisor.Utils.setTargetSettingValueOnActiveConfigSet(model,sudTargetSettingValue);

                    if status
                        deviceTypeResult{end+1}=checkEntry.setPassWithChange('','');%#ok<AGROW>
                    else

                        deviceTypeResult{end+1}=checkEntry.setFailWithoutChange('',...
                        DataTypeWorkflow.Advisor.internal.CauseRationale([],'parametersCannotBeUpdated'));%#ok<AGROW>
                    end
                end
            end
        end

        function boolGenericSetting=isGenericOrUnspecified(this,csValue)

            boolGenericSetting=strcmpi(csValue,this.genericDeviceValue1)||strcmpi(csValue,this.genericDeviceValue2);
        end
    end

end



