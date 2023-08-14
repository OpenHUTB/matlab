


classdef SFEvent<slci.common.BdObject

    properties(Access=private)
        fScope='';
        fTrigger='';
        fPort=0;
        fParent=[];
    end

    methods


        function out=getQualifiedName(aObj)
            out=[aObj.fParent.getSID,':',aObj.getName()];
        end

        function out=getScope(aObj)
            out=aObj.fScope;
        end

        function out=getTrigger(aObj)
            out=aObj.fTrigger;
        end

        function out=getPort(aObj)
            out=aObj.fPort;
        end


        function out=isLocalEvent(aObj)
            out=strcmpi(aObj.fScope,'Local');
        end

        function out=ParentChart(aObj)
            if isa(aObj.fParent,'slci.stateflow.Chart')
                out=aObj.fParent;
            else
                out=aObj.fParent.ParentChart();
            end
        end

        function out=ParentBlock(aObj)
            out=aObj.ParentChart().ParentBlock();
        end

        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end

        function aObj=SFEvent(aEventUDDObj,aParent)
            aObj.fParent=aParent;
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameEvent');
            aObj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameEvents');
            aObj.setUDDObject(aEventUDDObj);
            aObj.setName(aEventUDDObj.Name);
            aObj.setSID(Simulink.ID.getSID(aEventUDDObj));
            aObj.fScope=aEventUDDObj.Scope;
            aObj.fTrigger=aEventUDDObj.Trigger;
            aObj.fPort=aEventUDDObj.Port;

            aObj.addConstraint(slci.compatibility.StateflowEventScopeConstraint);

            aObj.addConstraint(slci.compatibility.StateflowEventTriggerTypeConstraint);
        end

    end
end

