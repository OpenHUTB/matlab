classdef TimePlotPreferences




    properties


TicksColor


TicksPosition


TickLabels


PlotColor


GridColor


LegendPosition


Markers


GridLines


PlotBorder


UpdateMode


TimeSpan


TLimits


YLimits


ScaleAtStop

    end


    methods


        function obj=TimePlotPreferences()
            obj.TicksColor=[0,0,0];
            obj.PlotColor=[1,1,1];
            obj.GridColor=[0.815,0.823,0.827];
            obj.TicksPosition='Outside';
            obj.TickLabels='All';
            obj.LegendPosition='TopLeft';
            obj.Markers='Hide';
            obj.GridLines='All';
            obj.PlotBorder='Show';
            obj.UpdateMode='Wrap';
            obj.TimeSpan='Auto';
            obj.TLimits=[0,100];
            obj.YLimits=[-3,3];
            obj.ScaleAtStop=true;
        end


        function obj=set.TicksColor(obj,value)
            try
                obj.locValidateColor(value);
                obj.TicksColor=double(value);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidColorArray',...
                DAStudio.message('record_playback:errors:InvalidColorArray')));
            end
        end


        function obj=set.PlotColor(obj,value)
            try
                obj.locValidateColor(value);
                obj.PlotColor=double(value);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidColorArray',...
                DAStudio.message('record_playback:errors:InvalidColorArray')));
            end
        end


        function obj=set.GridColor(obj,value)
            try
                obj.locValidateColor(value);
                obj.GridColor=double(value);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidColorArray',...
                DAStudio.message('record_playback:errors:InvalidColorArray')));
            end
        end



        function obj=set.TicksPosition(obj,value)
            labelValid=strcmpi(value,obj.TICKS_POSITION);
            if any(labelValid)
                labelPos(1)=find(labelValid);
                obj.TicksPosition=obj.TICKS_POSITION{labelPos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidTickPositions',...
                DAStudio.message('record_playback:errors:InvalidTickPositions')));
            end
        end


        function obj=set.LegendPosition(obj,value)
            labelValid=strcmpi(value,obj.LEGEND_POSITION);
            if any(labelValid)
                labelPos(1)=find(labelValid);
                obj.LegendPosition=obj.LEGEND_POSITION{labelPos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidLegendPosition',...
                DAStudio.message('record_playback:errors:InvalidLegendPosition')));
            end
        end


        function obj=set.Markers(obj,value)
            valid=strcmpi(value,obj.VISIBILITY_OPTIONS);
            if any(valid)
                pos(1)=find(valid);
                obj.Markers=obj.VISIBILITY_OPTIONS{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidShowMarkers',...
                DAStudio.message('record_playback:errors:InvalidShowMarkers')));
            end
        end


        function obj=set.TickLabels(obj,value)
            labelValid=strcmpi(value,obj.TICK_LABELS);
            if any(labelValid)
                labelPos(1)=find(labelValid);
                obj.TickLabels=obj.TICK_LABELS{labelPos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidTickLabels',...
                DAStudio.message('record_playback:errors:InvalidTickLabels')));
            end
        end


        function obj=set.GridLines(obj,value)
            labelValid=strcmpi(value,obj.GRID_LINE_OPTIONS);
            if any(labelValid)
                labelPos(1)=find(labelValid);
                obj.GridLines=obj.GRID_LINE_OPTIONS{labelPos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidGridDisplay',...
                DAStudio.message('record_playback:errors:InvalidGridDisplay')));
            end
        end


        function obj=set.PlotBorder(obj,value)
            valid=strcmpi(value,obj.VISIBILITY_OPTIONS);
            if any(valid)
                pos(1)=find(valid);
                obj.PlotBorder=obj.VISIBILITY_OPTIONS{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidAxesBorder',...
                DAStudio.message('record_playback:errors:InvalidAxesBorder')));
            end
        end


        function obj=set.UpdateMode(obj,value)
            modeValid=strcmpi(value,obj.UPDATE_MODE);
            if any(modeValid)
                modePos(1)=find(modeValid);
                obj.UpdateMode=obj.UPDATE_MODE{modePos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidUpdateMode',...
                DAStudio.message('record_playback:errors:InvalidUpdateMode')));
            end
        end


        function obj=set.TimeSpan(obj,value)
            error=false;
            if ischar(value)&&~strcmpi(value,DAStudio.message('record_playback:params:Auto'))
                error=true;
            elseif isnumeric(value)
                try
                    validateattributes(value,obj.NUMERIC_CLASS,{'scalar','>',0,'finite'});
                catch
                    error=true;
                end
            end

            if~error
                obj.TimeSpan=value;
            else
                throwAsCaller(MException('record_playback:errors:InvalidTimeSpan',...
                DAStudio.message('record_playback:errors:InvalidTimeSpan')));
            end
        end


        function obj=set.TLimits(obj,value)
            validateattributes(value,obj.NUMERIC_CLASS,obj.LIMITS_ATTRIBUTES);
            obj.TLimits=value;
        end


        function obj=set.YLimits(obj,value)
            validateattributes(value,obj.NUMERIC_CLASS,obj.LIMITS_ATTRIBUTES);
            obj.YLimits=value;
        end


        function obj=set.ScaleAtStop(obj,value)
            if isscalar(value)&&isnumeric(value)
                value=logical(value);
            end
            try
                validateattributes(value,'logical',{'scalar'});
                obj.ScaleAtStop=value;
            catch
                throwAsCaller(MException('record_playback:errors:InvalidScaleAtStop',...
                DAStudio.message('record_playback:errors:InvalidScaleAtStop')));
            end
        end

    end


    methods(Access=protected)


        function locValidateColor(obj,value)
            validateattributes(value,obj.NUMERIC_CLASS,obj.COLOR_ATTRIBUTES);
        end

    end


    properties(Constant,Access=protected)

        TICKS_POSITION={DAStudio.message('record_playback:params:TickOutside'),...
        DAStudio.message('record_playback:params:TickInside'),...
        DAStudio.message('record_playback:params:TickHide')}

        LEGEND_POSITION={DAStudio.message('record_playback:params:LegendTopLeft'),...
        DAStudio.message('record_playback:params:LegendOutsideRight'),...
        DAStudio.message('record_playback:params:LegendInsideLeft'),...
        DAStudio.message('record_playback:params:LegendInsideRight'),...
        DAStudio.message('record_playback:params:None')}

        TICK_LABELS={DAStudio.message('record_playback:params:All'),...
        DAStudio.message('record_playback:params:TimeAxis'),...
        DAStudio.message('record_playback:params:YAxis'),...
        DAStudio.message('record_playback:params:None')}

        GRID_LINE_OPTIONS={DAStudio.message('record_playback:params:All'),...
        DAStudio.message('record_playback:params:None'),...
        DAStudio.message('record_playback:params:Horizontal'),...
        DAStudio.message('record_playback:params:Vertical')}

        UPDATE_MODE={DAStudio.message('record_playback:params:Wrap'),...
        DAStudio.message('record_playback:params:Scroll')}

        VISIBILITY_OPTIONS={DAStudio.message('record_playback:params:Show'),...
        DAStudio.message('record_playback:params:Hide')}

        NUMERIC_CLASS={'numeric'}

        COLOR_ATTRIBUTES={'ncols',3,'real','nonnegative','<=',1}

        LIMITS_ATTRIBUTES={'ncols',2,'real','finite'}

    end
end

