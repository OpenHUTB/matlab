classdef SimulinkNodeAnalyzer<dependencies.internal.analysis.simulink.SimulinkModelAnalyzer





    properties(Constant)
        Extensions=[".mdl",".slx"];
    end

    methods

        function this=SimulinkNodeAnalyzer(varargin)
            this@dependencies.internal.analysis.simulink.SimulinkModelAnalyzer(varargin{:});
        end

    end

    methods(Access=protected)

        function deps=analyzeMatches(this,handler,node,queries,matches,owner)
            if handler.ModelInfo.IsSLX
                matches=i_filterModel(matches);
            end

            deps=this.analyzeMatches@dependencies.internal.analysis.simulink.SimulinkModelAnalyzer(...
            handler,node,queries,matches,owner);
        end

    end

end


function matches=i_filterModel(matches)


    for n=1:length(matches)
        if~isempty(matches{n})
            hints={matches{n}.Hint};


            harness_part=regexp(hints,'\/simulink\/[^_\/]+_[^\/]+\/','once');
            harness_part=~cellfun('isempty',harness_part);

            matches{n}=matches{n}(~harness_part);
        end
    end

end

