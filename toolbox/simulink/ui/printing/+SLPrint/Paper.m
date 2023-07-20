classdef Paper
    properties
        PaperType='usletter';
        Orientation='portrait';
    end

    properties(Dependent)
        Size;
    end

    properties
        Margins=SLPrint.Units([0.5,0.5,0.5,0.5],'inches');
    end

    properties(Constant,Hidden)
        OrientationValues={'portrait','landscape','rotated'};
    end

    properties(Constant,Hidden)
        usletter=SLPrint.Units([8.5,11],'inches');
        letter=SLPrint.Units([8.5,11],'inches');
        uslegal=SLPrint.Units([8.5,14],'inches');
        legal=SLPrint.Units([8.5,14],'inches');
        tabloid=SLPrint.Units([11,17],'inches');

        a0=SLPrint.Units([841,1189],'mm');
        a1=SLPrint.Units([594,841],'mm');
        a2=SLPrint.Units([420,594],'mm');
        a3=SLPrint.Units([297,420],'mm');
        a4=SLPrint.Units([210,297],'mm');
        a5=SLPrint.Units([148,210],'mm');

        b0=SLPrint.Units([1029,1456],'mm');
        b1=SLPrint.Units([728,1028],'mm');
        b2=SLPrint.Units([514,728],'mm');
        b3=SLPrint.Units([364,514],'mm');
        b4=SLPrint.Units([257,364],'mm');
        b5=SLPrint.Units([182,257],'mm');

        archa=SLPrint.Units([9,12],'inches');
        archb=SLPrint.Units([12,18],'inches');
        archc=SLPrint.Units([18,24],'inches');
        archd=SLPrint.Units([24,36],'inches');
        arche=SLPrint.Units([36,48],'inches');

        a=SLPrint.Units([8.5,11],'inches');
        b=SLPrint.Units([11,17],'inches');
        c=SLPrint.Units([17,22],'inches');
        d=SLPrint.Units([22,34],'inches');
        e=SLPrint.Units([34,43],'inches');


        a4letter=SLPrint.Units([29.7,21],'inches');

        custom=SLPrint.Units([0,0],'inches');
    end

    properties(Access=private)
        CustomPaperSize=SLPrint.Units([0,0],'inches');
    end

    methods
        function obj=Paper(type,orientation,margins)
            if(nargin>0)
                obj.PaperType=type;
            end
            if(nargin>1)
                obj.Orientation=orientation;
            end
            if(nargin>2)
                obj.Margins=margins;
            end
        end

        function obj=set.Orientation(obj,value)
            value=lower(value);
            if ismember(value,obj.OrientationValues)
                obj.Orientation=value;
            else
                error(message('Simulink:Printing:InvalidOrientation',value));
            end
        end

        function obj=set.PaperType(obj,value)
            try
                obj.getPaperSize(value);
                obj.PaperType=value;
            catch me
                error(message('Simulink:Printing:InvalidPaperType',value));
            end
        end

        function obj=set.Margins(obj,newMargins)
            if isa(newMargins,'SLPrint.Units')
                value=newMargins.Value;
                units=newMargins.Unit;

            elseif isnumeric(newMargins)
                value=newMargins;
                units=obj.Margins.Units;
            else
                error(message('Simulink:Printing:InvalidMargins',newMargins));
            end

            if(length(value)==1)
                value=repmat(value,1,4);
            end

            if(length(value)==4)
                obj.Margins=SLPrint.Units(value,units);
            else
                error(message('Simulink:Printing:InvalidMargins',newMargins));
            end
        end

        function paperSize=get.Size(obj)
            if strcmpi(obj.PaperType,'custom')
                paperSize=obj.CustomPaperSize;
            else
                paperSize=obj.getPaperSize(obj.PaperType);
            end

            if~strcmp(obj.Orientation,'portrait')
                paperSize.Value=fliplr(paperSize.Value);
            end
        end

        function obj=set.Size(obj,newSize)
            if~strcmpi(obj.PaperType,'custom')
                error(message('Simulink:Printing:CannotSetSize'));
            end

            if isa(newSize,'SLPrint.Units')
                value=newSize.Value;
                units=newSize.Unit;

            elseif isnumeric(newSize)
                value=newSize;
                units=obj.CustomPaperSize.Unit;
            else
                error(message('Simulink:Printing:InvalidSize'));
            end

            if(length(value)==2)
                if~strcmp(obj.Orientation,'portrait')
                    value=fliplr(value);
                end

                obj.CustomPaperSize=SLPrint.Units(value,units);
            else
                error(message('Simulink:Printing:InvalidSize'));
            end
        end

        function disp(obj)
            dobj=SLPrint.Disp(obj);
            dobj.showEnumValue('Orientation',obj.OrientationValues);
            dobj.updatePropValue('Size',obj.Size.toString());
            dobj.updatePropValue('Margins',...
            [obj.Margins.toString(),' [left top right bottom]']);
            dobj.display();
        end
    end

    methods(Static)
        function paperSize=getPaperSize(paperType)

            paperType=strrep(lower(paperType),'-','');
            paperSize=SLPrint.Paper.(paperType);
        end
    end
end
