classdef AbstractDiagnostic<handle







    properties(Hidden)
alertDiagnostics
    end

    methods(Access=public)
        function this=AbstractDiagnostic()
            this.registerConditions();
        end

        function highestAlertLevel=getAlertLevel(this,result,group,proposalSettings)



            this.calculateAlertLevels(proposalSettings);

            alertLevels={};


            for index=1:length(this.alertDiagnostics)


                currentAlertLevels=this.getAllAlertLevels(this.alertDiagnostics{index},result,group);



                actionableAlertsIndex=cellfun(@(x)(~isempty(x)),currentAlertLevels);


                actionableAlerts=currentAlertLevels(actionableAlertsIndex)';

                alertLevels=[alertLevels;actionableAlerts];%#ok<AGROW>

            end

            alertLevels=[alertLevels{:}];


            highestAlertLevel=...
            SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.max(alertLevels);
        end

        function actionableDiagnostics=getDiagnostics(this,result,group,proposalSettings)



            this.calculateAlertLevels(proposalSettings);



            this.getActionableDiagnostics(result,group);



            actionableDiagnosticsIndex=false(length(this.alertDiagnostics),1);
            for diagnosticIndex=1:length(this.alertDiagnostics)
                actionableDiagnosticsIndex(diagnosticIndex)=any(cellfun(@(y)(~isempty(y)),this.alertDiagnostics{diagnosticIndex}.warningMessages));
            end

            actionableDiagnostics=this.alertDiagnostics(actionableDiagnosticsIndex);
            actionableDiagnostics=[actionableDiagnostics{:}];
        end
    end

    methods(Access=public,Hidden)
        function calculateAlertLevels(this,proposalSettings)




            for index=1:length(this.alertDiagnostics)
                this.alertDiagnostics{index}.determineAlertLevels(proposalSettings);
            end
        end
    end

    methods(Abstract,Access=public,Hidden)
        alertLevels=getAllAlertLevels(this,alertDiagnostic,result,group)
        getActionableDiagnostics(this,result,group)
        registerConditions(this)
    end
end

