classdef(Sealed)ProposalDiagnosticInterface<handle




















    properties(SetAccess=private,Hidden)
groupDiagnostic
resultDiagnostic
groupedResultDiagnostic
proposalSettings
    end

    methods(Access=private)

        function this=ProposalDiagnosticInterface
        end
    end

    methods(Static)

        function singleObject=getInterface(proposalSettings)





            persistent localObject;




            if isempty(localObject)||~isvalid(localObject)
                localObject=SimulinkFixedPoint.ProposalDiagnosticInterface;
                localObject.initialize();
            end


            singleObject=localObject;
            singleObject.proposalSettings=proposalSettings;
        end

    end

    methods(Access=public)
        diagnostics=getResultDiagnostics(this,result,group)
        diagnostics=getGroupDiagnostics(this,group)
        alertLevel=getGroupAlertLevel(this,group)
        alertLevel=getResultAlertLevel(this,result,group)
    end

    methods(Access=public,Hidden)
        initialize(this)
    end

end


