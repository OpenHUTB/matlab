classdef XYPlotPreferences




    properties


TicksColor


PlotColor


GridColor


Line


LineColor


Markers


MarkerBorder


MarkerFill


MarkerSize


TrendLine


TrendLineColor


TrendLineWeight


TrendLineType


PolynomialOrder


GridLines


LocalXYSettings
    end


    methods


        function obj=XYPlotPreferences()
            obj.TicksColor=[0,0,0];
            obj.PlotColor=[1,1,1];
            obj.GridColor=[0.815,0.823,0.827];
            obj.Line='Show';
            obj.LineColor='YColor';
            obj.Markers='Hide';
            obj.MarkerBorder='XColor';
            obj.MarkerFill='YColor';
            obj.MarkerSize=3.5;
            obj.TrendLine='Hide';
            obj.TrendLineWeight=2.5;
            obj.TrendLineColor=[1,0,0];
            obj.TrendLineType='Linear';
            obj.PolynomialOrder=3;
            obj.GridLines='On';
            obj.LocalXYSettings=[];
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


        function obj=set.Line(obj,value)
            valid=strcmpi(value,obj.VISIBILITY_OPTIONS);
            if any(valid)
                pos(1)=find(valid);
                obj.Line=obj.VISIBILITY_OPTIONS{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidToggleLine',...
                DAStudio.message('record_playback:errors:InvalidToggleLine')));
            end
        end


        function obj=set.LineColor(obj,value)
            error=obj.locValidateColor(value);
            color=value;
            if~error
                if ischar(value)
                    color=obj.locGetColorOption(value);
                end
                obj.LineColor=color;
            else
                throwAsCaller(MException('record_playback:errors:InvalidLineColor',...
                DAStudio.message('record_playback:errors:InvalidLineColor')));
            end
        end


        function obj=set.Markers(obj,value)
            matchingPos=strcmpi(value,obj.VISIBILITY_OPTIONS);
            if any(matchingPos)
                pos(1)=find(matchingPos);
                obj.Markers=obj.VISIBILITY_OPTIONS{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidShowMarkers',...
                DAStudio.message('record_playback:errors:InvalidShowMarkers')));
            end
        end


        function obj=set.MarkerBorder(obj,value)
            error=obj.locValidateColor(value);
            color=value;
            if~error
                if ischar(value)
                    color=obj.locGetColorOption(value);
                end
                obj.MarkerBorder=color;
            else
                throwAsCaller(MException('record_playback:errors:InvalidMarkerBorderColor',...
                DAStudio.message('record_playback:errors:InvalidMarkerBorderColor')));
            end
        end


        function obj=set.MarkerFill(obj,value)
            error=obj.locValidateColor(value);
            color=value;
            if~error
                if ischar(value)
                    color=obj.locGetColorOption(value);
                end
                obj.MarkerFill=color;
            else
                throwAsCaller(MException('record_playback:errors:InvalidMarkerBorderColor',...
                DAStudio.message('record_playback:errors:InvalidMarkerBorderColor')));
            end
        end


        function obj=set.MarkerSize(obj,value)
            try
                validateattributes(value,obj.MARKER_SIZE_CLASS,obj.MARKER_SIZE_ATTRIBUTES);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidMarkerSize',...
                DAStudio.message('record_playback:errors:InvalidMarkerSize')));
            end
            obj.MarkerSize=value;
        end


        function obj=set.TrendLine(obj,value)
            valid=strcmpi(value,obj.VISIBILITY_OPTIONS);
            if any(valid)
                pos(1)=find(valid);
                obj.TrendLine=obj.VISIBILITY_OPTIONS{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidShowTrendLine',...
                DAStudio.message('record_playback:errors:InvalidShowTrendLine')));
            end
        end


        function obj=set.TrendLineColor(obj,value)
            try
                validateattributes(value,obj.NUMERIC_CLASS,obj.COLOR_ATTRIBUTES);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidTrendLineColor',...
                DAStudio.message('record_playback:errors:InvalidTrendLineColor')));
            end
            obj.TrendLineColor=value;
        end


        function obj=set.TrendLineWeight(obj,value)
            try
                validateattributes(value,obj.MARKER_SIZE_CLASS,obj.MARKER_SIZE_ATTRIBUTES);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidToggleTrendLine',...
                DAStudio.message('record_playback:errors:InvalidToggleTrendLine')));
            end
            obj.TrendLineWeight=value;
        end


        function obj=set.TrendLineType(obj,value)
            valid=strcmpi(value,obj.TREND_LINE_TYPES);
            if any(valid)
                pos(1)=find(valid);
                obj.TrendLineType=obj.TREND_LINE_TYPES{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidTrendLineType',...
                DAStudio.message('record_playback:errors:InvalidTrendLineType')));
            end
        end


        function obj=set.PolynomialOrder(obj,value)
            try
                validateattributes(value,obj.NUMERIC_CLASS,obj.POLYNOMIAL_ATTRIBUTES);
            catch
                throwAsCaller(MException('record_playback:errors:InvalidPolynomialOrder',...
                DAStudio.message('record_playback:errors:InvalidPolynomialOrder')));
            end
            obj.PolynomialOrder=value;
        end


        function obj=set.GridLines(obj,value)
            valid=strcmpi(value,obj.GRID_LINE_OPTIONS);
            if any(valid)
                pos(1)=find(valid);
                obj.GridLines=obj.GRID_LINE_OPTIONS{pos};
            else
                throwAsCaller(MException('record_playback:errors:InvalidGridDisplay',...
                DAStudio.message('record_playback:errors:InvalidGridDisplay')));
            end
        end

    end


    methods(Access=private)


        function error=locValidateColor(obj,value)
            error=false;
            if ischar(value)
                matchingPos=strcmpi(value,obj.COLOR_OPTIONS);
                if~any(matchingPos)
                    error=true;
                end
            elseif isnumeric(value)
                try
                    validateattributes(value,obj.NUMERIC_CLASS,obj.COLOR_ATTRIBUTES);
                catch
                    error=true;
                end
            end
        end


        function colorOption=locGetColorOption(obj,value)
            matches=strcmpi(value,obj.COLOR_OPTIONS);
            pos(1)=find(matches);
            colorOption=obj.COLOR_OPTIONS{pos};
        end
    end


    properties(Constant,Access=private)

        VISIBILITY_OPTIONS={DAStudio.message('record_playback:params:Show'),...
        DAStudio.message('record_playback:params:Hide')}

        COLOR_OPTIONS={DAStudio.message('record_playback:params:YColor'),...
        DAStudio.message('record_playback:params:XColor')}

        NUMERIC_CLASS={'numeric'}

        COLOR_ATTRIBUTES={'ncols',3,'real','nonnegative','<=',1}

        LIMITS_ATTRIBUTES={'ncols',4,'real'}

        MARKER_SIZE_CLASS={'double'}

        MARKER_SIZE_ATTRIBUTES={'nonnegative','<=',4}

        POLYNOMIAL_ATTRIBUTES={'real','nonnegative','integer','>=',2,'<=',6}

        GRID_LINE_OPTIONS={DAStudio.message('record_playback:params:On'),...
        DAStudio.message('record_playback:params:Off'),...
        DAStudio.message('record_playback:params:Horizontal'),...
        DAStudio.message('record_playback:params:Vertical')}

        TREND_LINE_TYPES={DAStudio.message('record_playback:params:TrendLineLinear'),...
        DAStudio.message('record_playback:params:TrendLineLogarithmic'),...
        DAStudio.message('record_playback:params:TrendLinePolynomial'),...
        DAStudio.message('record_playback:params:TrendLinePower'),...
        DAStudio.message('record_playback:params:TrendLineExponential')}

    end

end


