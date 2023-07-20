classdef units
















    properties(Constant,Hidden)
        PointsPerInch=72;
        CentimetersPerInch=2.54;
        MillimetersPerInch=25.4;
        PicasPerInch=6;
        EMUPerInch=914400;
    end

    methods(Static)
        function value=toPixels(varargin)








































            units=mlreportgen.utils.units;
            [value,unitType,dpi]=units.parse(varargin{:});
            switch unitType
            case "pixel"

            case "point"
                value=value.*dpi/units.PointsPerInch;
            case "inch"
                value=value.*dpi;
            case "centimeter"
                value=value.*dpi/units.CentimetersPerInch;
            case "millimeter"
                value=value.*dpi/units.MillimetersPerInch;
            case "pica"
                value=value.*dpi/units.PicasPerInch;
            case "EMU"
                value=value.*dpi/units.EMUPerInch;
            otherwise
                error(message("mlreportgen:utils:error:InvalidUnitType"));
            end
        end

        function value=toPoints(varargin)








































            units=mlreportgen.utils.units;
            [value,unitType,dpi]=units.parse(varargin{:});
            switch unitType
            case "pixel"
                value=value.*units.PointsPerInch/dpi;
            case "point"

            case "inch"
                value=value.*units.PointsPerInch;
            case "centimeter"
                value=value.*units.PointsPerInch/units.CentimetersPerInch;
            case "millimeter"
                value=value.*units.PointsPerInch/units.MillimetersPerInch;
            case "pica"
                value=value.*units.PointsPerInch/units.PicasPerInch;
            case "EMU"
                value=value.*units.PointsPerInch/units.EMUPerInch;
            otherwise
                error(message("mlreportgen:utils:error:InvalidUnitType"));
            end
        end

        function value=toInches(varargin)








































            units=mlreportgen.utils.units;
            value=units.toPoints(varargin{:})/units.PointsPerInch;
        end

        function value=toCentimeters(varargin)









































            units=mlreportgen.utils.units;
            value=mlreportgen.utils.units.toPoints(varargin{:});
            value=value.*units.CentimetersPerInch/units.PointsPerInch;
        end

        function value=toMillimeters(varargin)









































            value=10*mlreportgen.utils.units.toCentimeters(varargin{:});
        end

        function value=toPicas(varargin)








































            units=mlreportgen.utils.units;
            value=mlreportgen.utils.units.toInches(varargin{:});
            value=value.*units.PicasPerInch;
        end

        function isValid=isValidDimensionString(str)
            if(ischar(str))||(isstring(str))
                units=mlreportgen.utils.units;
                [val,unitType]=units.parse(str);
                if strcmp(unitType,"")
                    is=false;
                else
                    is=true;
                end
                isValid=is&&~isnan(val);
            else
                isValid=false;
            end
        end
    end

    methods(Static,Access=private)
        function[value,unitType,dpi]=parse(varargin)
            units=mlreportgen.utils.units;


            args=varargin;
            for i=1:nargin
                if ischar(varargin{i})
                    args{i}=string(args{i});
                end
            end

            value=[];
            unitType=string.empty();

            if(mod(nargin,2)==1)
                arg1=args{1};
                if isstring(arg1)
                    tokens=regexp(string(arg1),"([0-9.]*)\s*([a-zA-Z%*]*)","tokens","once");
                    value=str2double(tokens(1));
                    unitType=units.getUnitType(tokens(2));
                end
            else
                value=args{1};
                if isstring(value)
                    value=str2double(value);
                end
                unitType=units.getUnitType(args{2});
            end

            dpi=rptgen.utils.getScreenPixelsPerInch();
            if(numel(args)>2)
                argDPIName=args{end-1};
                argDPIValue=args{end};
                if(isstring(argDPIName)&&strcmpi(argDPIName,"dpi"))
                    assert(isnumeric(argDPIValue));
                    dpi=argDPIValue;
                end
            end
        end

        function unitType=getUnitType(str)
            switch lower(str)
            case{"in","inches","inch"}
                unitType="inch";
            case{"cm","centimeters","centimeter"}
                unitType="centimeter";
            case{"mm","millimeters","millimeter"}
                unitType="millimeter";
            case{"pt","points","point"}
                unitType="point";
            case{"px","pixels","pixel"}
                unitType="pixel";
            case{"pi","picas","pica","pc"}
                unitType="pica";
            case{"EMU","emu"}
                unitType="EMU";
            case ""
                unitType="pixel";
            otherwise
                unitType="";
            end
        end
    end
end