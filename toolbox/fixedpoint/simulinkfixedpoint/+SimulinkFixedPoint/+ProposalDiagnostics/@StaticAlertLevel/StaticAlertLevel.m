classdef StaticAlertLevel<SimulinkFixedPoint.ProposalDiagnostics.AbstractAlertLevel







    properties(SetAccess=private,Hidden)
staticAlertLevel
    end

    methods
        function this=StaticAlertLevel(alertLevel)


            this.staticAlertLevel=alertLevel;
        end

        function alertLevel=getAlertLevel(this,~)


            alertLevel=this.staticAlertLevel;
        end
    end

end

