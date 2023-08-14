classdef PlotPreferences


    properties


        Time;


        XY;


        Map;


        Sparklines;

    end

    methods

        function obj=PlotPreferences()
            obj.Time=Simulink.record.internal.TimePlotPreferences;
            obj.XY=Simulink.record.internal.XYPlotPreferences;
            obj.Map=Simulink.record.internal.MapPlotPreferences;
            obj.Sparklines=[];
        end

        function obj=set.Time(obj,timePlotPrefs)
            if~isa(timePlotPrefs,'Simulink.record.internal.TimePlotPreferences')
                throwAsCaller(MException('record_playback:errors:InvalidTimePlotTypePrefs',...
                DAStudio.message('record_playback:errors:InvalidTimePlotTypePrefs')));
            end
            obj.Time=timePlotPrefs;
        end

        function obj=set.XY(obj,xyPlotPrefs)
            if~isa(xyPlotPrefs,'Simulink.record.internal.XYPlotPreferences')
                throwAsCaller(MException('record_playback:errors:InvalidXYPlotTypePrefs',...
                DAStudio.message('record_playback:errors:InvalidXYPlotTypePrefs')));
            end
            obj.XY=xyPlotPrefs;
        end

        function obj=set.Map(obj,mapPlotPrefs)
            if~isa(mapPlotPrefs,'Simulink.record.internal.MapPlotPreferences')
                throwAsCaller(MException('record_playback:errors:InvalidMapPlotTypePrefs',...
                DAStudio.message('record_playback:errors:InvalidMapPlotTypePrefs')));
            end
            obj.Map=mapPlotPrefs;
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

