classdef Utils<handle




    methods(Static)
        function unsupportedConstructsWithPassStatus=getUnsupportedConstructs(analyzerReport)






            unsupportedConstructsWithPassStatus={};


            if isempty(analyzerReport)
                return;
            end

            unsupportedConstructs=analyzerReport.UnsupportedConstruct;

            for idx=1:length(unsupportedConstructs)
                status=unsupportedConstructs{idx}.Status;
                if ismember(status,DataTypeWorkflow.Advisor.CheckStatus.PassWithChange)
                    name=unsupportedConstructs{idx}.AfterValue;
                    unsupportedConstructsWithPassStatus=[unsupportedConstructsWithPassStatus;name];%#ok<AGROW>
                end
            end
        end
    end
end
