classdef Units



    properties
        Value=0;
        Unit='points';
    end

    properties(Constant,Hidden)
        UnitTypes={'inches','centimeters','millimeters','points'};
        PointsPerInch=72;
        CentimetersPerInch=2.54;
        MillimetersPerInch=25.4;
    end


    methods
        function obj=set.Unit(obj,type)
            value=lower(type);
            switch value
            case obj.UnitTypes
                obj.Unit=value;
            case 'cm'
                obj.Unit='centimeters';
            case 'mm'
                obj.Unit='millimeters';
            otherwise
                error(message('Simulink:Printing:InvalidUnitType',type));
            end
        end
    end

    methods
        function obj=Units(varargin)
            if(nargin>0)
                obj.Value=varargin{1};
            end
            if(nargin>1)
                obj.Unit=varargin{2};
            end
        end

        function disp(obj)
            dobj=SLPrint.Disp(obj);
            dobj.showEnumValue('Unit',obj.UnitTypes);
            dobj.display();
        end

        function value=toPoints(obj)
            value=obj.convertTo('points').Value;
        end
        function value=toInches(obj)
            value=obj.convertTo('inches').Value;
        end
        function value=toCentimeters(obj)
            value=obj.convertTo('centimeters').Value;
        end
        function value=toCm(obj)
            value=obj.convertTo('centimeters').Value;
        end
        function value=toMillimeters(obj)
            value=obj.convertTo('millimeters').Value;
        end
        function value=toMm(obj)
            value=obj.convertTo('millimeters').Value;
        end
        function value=toPixels(obj,resolution)
            scale=resolution/obj.PointsPerInch;
            value=scale*obj.toPoints();
        end

        function out=convertTo(obj,newUnits)
            if strcmp(newUnits,obj.Unit)
                out=obj;
                return
            end


            switch obj.Unit
            case 'points'

            case 'inches'
                obj.Value=obj.Value.*obj.PointsPerInch;
            case{'centimeters','cm'}
                obj.Value=obj.Value.*obj.PointsPerInch/obj.CentimetersPerInch;
            case{'millimeters','mm'}
                obj.Value=obj.Value.*obj.PointsPerInch/obj.MillimetersPerInch;
            otherwise
                error(message('Simulink:Printing:UnexpectedUnits',obj.Unit));
            end
            obj.Unit='points';


            switch newUnits
            case 'points'
                out=obj;
            case 'inches'
                out=SLPrint.Units(...
                obj.Value./obj.PointsPerInch,...
                'inches');
            case{'centimeters','cm'}
                out=SLPrint.Units(...
                obj.Value.*obj.CentimetersPerInch/obj.PointsPerInch,...
                'centimeters');
            case{'millimeters','mm'}
                out=SLPrint.Units(...
                obj.Value.*obj.MillimetersPerInch/obj.PointsPerInch,...
                'centimeters');
            otherwise
                error(message('Simulink:Printing:UnexpectedUnits',newUnits));
            end
        end

        function out=toString(obj)
            dobj=SLPrint.Disp(obj);
            valueLine=dobj.getPropValueDisp('Value');
            out=sprintf('%s %s',strtrim(valueLine),obj.Unit);



            out=regexprep(out,'(?<=\.\d+?)0+(?=\D|$)','');
        end
    end


    methods
        function obj=subsasgn(obj,subscript,varargin)
            if strcmp(subscript(1).type,'()')
                obj.Value(subscript(1).subs{:})=varargin{1};
            else
                obj=builtin('subsasgn',obj,subscript,varargin{:});
            end
        end
        function out=subsref(obj,subscript)
            if((length(obj)==1)&&strcmp(subscript(1).type,'()'))
                value=obj.Value(subscript(1).subs{:});
                subscript=subscript(2:end);
                out=SLPrint.Units(value,obj.Unit);
            else
                out=obj;
            end
            if~isempty(subscript)
                out=builtin('subsref',out,subscript);
            end
        end
        function out=plus(in1,in2)
            [in1,in2]=convertToMatchingUnits(in1,in2);
            out=in1;
            out.Value=in1.Value+in2.Value;
        end
        function out=minus(in1,in2)
            [in1,in2]=convertToMatchingUnits(in1,in2);
            out=in1;
            out.Value=in1.Value-in2.Value;
        end
        function out=mtimes(in1,in2)
            [in1,in2]=convertToMatchingUnits(in1,in2);
            out=in1;
            out.Value=in1.Value*in2.Value;
        end
        function out=times(in1,in2)
            [in1,in2]=convertToMatchingUnits(in1,in2);
            out=in1;
            out.Value=in1.Value.*in2.Value;
        end
        function out=mrdivide(in1,in2)
            [in1,in2]=convertToMatchingUnits(in1,in2);
            out=in1;
            out.Value=in1.Value/in2.Value;
        end
        function out=rdivide(in1,in2)
            [in1,in2]=convertToMatchingUnits(in1,in2);
            out=in1;
            out.Value=in1.Value./in2.Value;
        end
        function out=mpower(in1,pow)
            out=in1;
            out.Value=in1.Value^pow;
        end
        function out=sqrt(in1)
            out=in1;
            out.Value=sqrt(in1.Value);
        end
        function out=uminus(in1)
            out=in1;
            out.Value=-in1.Value;
        end
        function tf=eq(in1,in2)
            tf=all(in1.inPoints()==in2.inPoints());
        end
        function tf=ne(in1,in2)
            tf=~(eq(in1,in2));
        end
    end

    methods(Access='private')
        function[out1,out2]=convertToMatchingUnits(in1,in2)
            if(isa(in1,'SLPrint.Units')&&isa(in2,'SLPrint.Units'))

                out1=in1;
                out2=in2.convertTo(in1.Unit);

            elseif(~isa(in1,'SLPrint.Units')&&isa(in2,'SLPrint.Units'))
                out1=in2;
                out1.Value=in1;
                out2=in2;

            elseif(isa(in1,'SLPrint.Units')&&~isa(in2,'SLPrint.Units'))
                out1=in1;
                out2=in1;
                out2.Value=in2;
            else

                error(message('Simulink:Printing:UnableToMatchUnits'));
            end
        end
    end

    methods(Static)
        function out=fromPixels(pixels,resolution)
            scale=SLPrint.Units.PointsPerInch/resolution;
            out=SLPrint.Units();
            out.Unit='points';
            out.Value=scale*pixels;
        end
    end

end
