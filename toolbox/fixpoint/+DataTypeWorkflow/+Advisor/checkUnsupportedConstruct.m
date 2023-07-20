classdef checkUnsupportedConstruct<handle





    methods
        function obj=checkUnsupportedConstruct()
        end
    end

    methods(Static)
        function reportObject=runFailSafe(analyzerScope)
            try
                reportObject=DataTypeWorkflow.Advisor.checkUnsupportedConstruct.run(analyzerScope);
            catch exUnsupported
                reportObject{1}=analyzerScope.reportInternalErrorFromExceptionInScope(exUnsupported);
            end
        end

        function reportObject=run(analyzerCheck)

            sudInScope=analyzerCheck.SelectedSystem;
            sudInScopeObject=get_param(sudInScope,'Object');

            checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(sudInScope);

            capabilityMgr=DataTypeWorkflow.Advisor.CapabilityManager();
            try
                blocksRequireDecouple=capabilityMgr.getUnsupportedConstruct(analyzerCheck);
            catch modelFail

                reportObject{1}=checkEntry.setFailWithoutChange(analyzerCheck.SelectedSystem,...
                DataTypeWorkflow.Advisor.internal.CauseRationale(modelFail,'modelCannotUpdate'));
                return;
            end


            if DataTypeWorkflow.Advisor.Utils.isLibraryLinked(sudInScopeObject)
                if isempty(blocksRequireDecouple)
                    reportObject{1}=checkEntry.setPassWithoutChange();
                else
                    reportObject{1}=checkEntry.setFailWithoutChange(analyzerCheck.SelectedSystem,...
                    DataTypeWorkflow.Advisor.internal.CauseRationale([],'modelCannotUpdate'));
                end
                return;
            end


            subsystemDecoupled=capabilityMgr.decoupleUnsupportedConstruct();

            unsupportedList=[];

            for idx=1:numel(subsystemDecoupled)

                checkEntryLocal=DataTypeWorkflow.Advisor.CheckResultEntry(analyzerCheck.SelectedSystem);
                blockNameBefore=blocksRequireDecouple{idx}.constructName;
                blockNameAfter=subsystemDecoupled{idx};

                unsupportedList{idx}=checkEntryLocal.setPassWithChange(blockNameBefore,blockNameAfter);%#ok<AGROW>
            end


            if isempty(unsupportedList)
                checkEntryLocal=DataTypeWorkflow.Advisor.CheckResultEntry(analyzerCheck.SelectedSystem);
                reportObject{1}=checkEntryLocal.setPassWithoutChange();
            else
                reportObject=unsupportedList;
            end
        end
    end
end
