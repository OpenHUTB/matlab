




classdef StateflowExecOnInitConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts or atomic subcharts must deselect ''Execute (enter) Chart at Initialization''';
        end

        function obj=StateflowExecOnInitConstraint
            obj.setEnum('StateflowExecOnInit');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            if aObj.getOwner().isAtomicSubchart()
                stateflowObjType=DAStudio.message('Slci:compatibility:ClassTypeAtomicSubchart');
            else
                stateflowObjType=DAStudio.message('Slci:compatibility:ClassTypeChart');
            end
            out=[];
            if aObj.ParentChart().getExecuteAtInitialization()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowExecOnInit',...
                stateflowObjType,...
                aObj.ParentBlock().getName());
                return;
            end
        end


        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try
                aObj.ParentChart().getUDDObject.ExecuteAtInitialization=false;
                out=true;
            catch
            end
        end

    end
end
