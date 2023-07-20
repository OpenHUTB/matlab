




classdef StateflowLinkedAtomicSubchartConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow chart must not contains linked atomic subchart';
        end


        function obj=StateflowLinkedAtomicSubchartConstraint
            obj.setEnum('StateflowLinkedAtomicSubchart');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end


        function out=check(aObj)
            out=[];
            chartUDDObj=aObj.ParentChart.getUDDObject;
            atomicSubcharts=slci.internal.getSFActiveObjs(...
            chartUDDObj.find('-isa','Stateflow.AtomicSubchart'));

            for i=1:numel(atomicSubcharts)
                atomicSubchartObj=atomicSubcharts(i);
                subChartParent=atomicSubchartObj.Subchart.getParent;





                if isLibrary(subChartParent)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowLinkedAtomicSubchart',...
                    aObj.ParentBlock().getName());
                    return;
                end

            end
        end

    end
end

