classdef TypMinMaxCommon<serdes.internal.ibisami.ami.format.AmiFormat


...
...
...
...
...
...
...
...
...
...


    properties(Constant)
        TypIdx=1
        MinIdx=2
        MaxIdx=3
    end
    properties(Dependent)
Typ
Min
Max
    end

    methods
        function format=TypMinMaxCommon(varargin)
            if(nargin>0)
                if nargin==1
                    typMinMax=varargin{1};
                else
                    typMinMax=varargin;
                end
                if length(typMinMax)==3
                    format.Default=typMinMax{1};
                    format.Values=typMinMax;
                else
                    error(message('serdes:ibis:InvalidConstructor'))
                end
            end
        end

        function set.Typ(format,value)
            format.setValue(value,format.TypIdx)
        end
        function set.Min(format,value)
            format.setValue(value,format.MinIdx)
        end
        function set.Max(format,value)
            format.setValue(value,format.MaxIdx)
        end
        function typ=get.Typ(format)
            typ=format.Values{format.TypIdx};
        end
        function min=get.Min(format)
            min=format.Values{format.MinIdx};
        end
        function max=get.Max(format)
            max=format.Values{format.MaxIdx};
        end
    end
    methods

        function verified=verifyValueForType(format,type,passedValue)




            verified=false;
            value=string(passedValue);
            if~type.verifyValueForType(value)
                return
            end
            verified=(type.isEqual(value,format.Min)||type.isGreaterThan(value,format.Min))&&...
            (type.isEqual(value,format.Max)||type.isLessThan(value,format.Max));
        end
        function branch=getKeyWordBranch(format,type,~)
            typ=type.convertToAmiValue(format.Typ);
            min=type.convertToAmiValue(format.Min);
            max=type.convertToAmiValue(format.Max);
            branch="("+format.Name+" "+typ+" "+min+" "+max+")";
        end
    end
end

