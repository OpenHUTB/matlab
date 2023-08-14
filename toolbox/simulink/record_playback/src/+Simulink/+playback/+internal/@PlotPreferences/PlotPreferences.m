classdef PlotPreferences


    properties


        Sparklines;

    end

    methods

        function obj=PlotPreferences()
            obj.Sparklines=[];
        end

        function obj=set.Sparklines(obj,sparklinePrefs)
            if~isempty(sparklinePrefs)
                if~isa(sparklinePrefs,'Simulink.record.internal.SparklinePlotPreferences')
                    throwAsCaller(MException('record_playback:errors:InvalidSparklinePrefs',...
                    DAStudio.message('record_playback:errors:InvalidSparklinePrefs')));
                end
                obj.Sparklines=sparklinePrefs;
            else
                obj.Sparklines=[];
            end
        end

    end
end
