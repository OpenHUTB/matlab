classdef AlertDiagnostic<handle















    properties(SetAccess=private)
alertLevels
warningMessages
    end

    properties(SetAccess=private,Hidden)
warningCondition
alertLevelStrategy
    end

    methods
        function this=AlertDiagnostic(warningCondition,alertLevelStrategy)


            this.warningCondition=warningCondition;


            this.alertLevelStrategy=alertLevelStrategy;
        end

        function determineAlertLevels(this,proposalSettings)



            for alertIndex=1:length(this.alertLevelStrategy)
                this.alertLevels{alertIndex}=this.alertLevelStrategy{alertIndex}.getAlertLevel(proposalSettings);
            end

        end

        function alertLevels=getAlertLevels(this,result,group)



            conditionFlag=this.warningCondition.check(result,group);


            alertLevels=this.alertLevels(conditionFlag);
        end

        function getWarnings(this,result,group)


            this.warningMessages=this.warningCondition.getWarning(result,group);

            emptyWarningIndex=false(length(this.warningMessages),1);


            for warningIndex=1:length(this.warningMessages)
                emptyWarningIndex(warningIndex)=isempty(this.warningMessages{warningIndex});
            end

            this.warningMessages(emptyWarningIndex)='';
            this.alertLevels(emptyWarningIndex)='';

        end
    end

end

