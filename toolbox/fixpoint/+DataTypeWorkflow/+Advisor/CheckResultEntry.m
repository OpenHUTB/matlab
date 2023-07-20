classdef CheckResultEntry<handle




    properties(Hidden)
        entry=''
        entryIdentifer=''
        Status=DataTypeWorkflow.Advisor.CheckStatus.NotRun
        BeforeValue=''
        AfterValue=''
        Causes=[]
    end

    methods
        function resultEntry=CheckResultEntry(selectedEntry)
            resultEntry.entry=selectedEntry;
            if~isempty(selectedEntry)



                entryParts=strsplit(selectedEntry,'/');
                entryModelName=entryParts{1};
                if bdIsLoaded(entryModelName)
                    entryObject=get_param(selectedEntry,'Object');
                    resultEntry.entryIdentifer=fxptds.SimulinkIdentifier(entryObject);
                end
            end
        end
    end

    methods
        function resultEntry=setPassWithoutChange(resultEntry)
            resultEntry.Status=DataTypeWorkflow.Advisor.CheckStatus.PassWithoutChange;
        end

        function resultEntry=setPassWithChange(resultEntry,beforeV,afterV)
            resultEntry.Status=DataTypeWorkflow.Advisor.CheckStatus.PassWithChange;
            resultEntry.BeforeValue=beforeV;
            resultEntry.AfterValue=afterV;

        end

        function resultEntry=setFailWithoutChange(resultEntry,beforeV,causes)
            resultEntry.Status=DataTypeWorkflow.Advisor.CheckStatus.FailWithoutChange;
            resultEntry.BeforeValue=beforeV;

            resultEntry.Causes=causes;
        end

        function resultEntry=setWarnWithoutChange(resultEntry,beforeV,causes)
            resultEntry.Status=DataTypeWorkflow.Advisor.CheckStatus.WarnWithoutChange;
            resultEntry.BeforeValue=beforeV;

            resultEntry.Causes=causes;
        end

    end

end


