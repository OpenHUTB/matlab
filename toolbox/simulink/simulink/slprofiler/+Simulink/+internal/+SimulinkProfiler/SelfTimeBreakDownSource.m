classdef SelfTimeBreakDownSource<handle

    properties
        rows;
    end

    methods
        function this=SelfTimeBreakDownSource(execNodes)
            this.rows=createRows(execNodes);
        end

        function children=getChildren(this)
            children=this.rows;
        end

        function refreshData(this,execNodes)
            this.rows=createRows(execNodes);
        end
    end
end

function rows=createRows(execNodes)
    if isempty(execNodes)
        rows=[];
        return;
    end
    for n=1:length(execNodes)
        rows(n)=Simulink.internal.SimulinkProfiler.SelfTimeBreakDownRow(...
        sprintf('%.3f',execNodes(n).selfTime),...
        execNodes(n).locationName,...
        execNodes(n).numCalls);%#ok<AGROW>
    end
end