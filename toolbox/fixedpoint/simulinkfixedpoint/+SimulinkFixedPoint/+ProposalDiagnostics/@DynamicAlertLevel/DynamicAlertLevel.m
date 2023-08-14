classdef DynamicAlertLevel<SimulinkFixedPoint.ProposalDiagnostics.AbstractAlertLevel



    properties(SetAccess=private,Hidden)
dynamicStrategy
    end

    methods
        function this=DynamicAlertLevel(dynamicStrategy)



            this.dynamicStrategy=dynamicStrategy;
        end

        function alertLevel=getAlertLevel(this,proposalSettings)



            alertLevel=this.dynamicStrategy.getAlertLevel(proposalSettings);
        end
    end

end

