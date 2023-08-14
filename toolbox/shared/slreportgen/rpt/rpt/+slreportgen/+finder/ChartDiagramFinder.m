classdef ChartDiagramFinder<slreportgen.finder.DiagramFinder
















































































    methods
        function h=ChartDiagramFinder(varargin)
            h=h@slreportgen.finder.DiagramFinder(varargin{:});
        end

        function results=find(h)








































            results=find@slreportgen.finder.DiagramFinder(h);
        end
    end

    methods(Access=protected)
        function tf=satisfyResultConstraint(~,result)
            obj=result.Object;
            tf=isa(obj,'Stateflow.Chart')...
            ||(isa(obj,'Stateflow.State')&&obj.IsSubChart);
        end
    end
end

