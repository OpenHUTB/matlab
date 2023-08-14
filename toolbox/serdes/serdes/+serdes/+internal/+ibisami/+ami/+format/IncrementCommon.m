classdef(Abstract)IncrementCommon<serdes.internal.ibisami.ami.format.AmiFormat

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



    properties(Constant,Access=protected)
        TypIndex=1;
        MinIndex=2;
        MaxIndex=3;
        StepsOrDeltaIndex=4;
    end
    properties(Dependent)
Typ
Min
Max
    end
    properties(Access=protected)
DeltaToUse
    end
    methods
        function incrementCommon=IncrementCommon(varargin)
            if nargin==1
                values=varargin{1};
            elseif nargin==4
                values=varargin;
            else
                values={};
            end
            incrementCommon.Values=values;
            if~isempty(incrementCommon.Values)
                incrementCommon.Default=incrementCommon.Values(1);
            end
            incrementCommon.AllowedTypeNames=[serdes.internal.ibisami.ami.type.Float().Name,...
            serdes.internal.ibisami.ami.type.UI().Name,...
            serdes.internal.ibisami.ami.type.Integer().Name,...
            serdes.internal.ibisami.ami.type.Tap().Name];
        end
        function typ=get.Typ(obj)
            typ=obj.Values(obj.TypIndex);
        end
        function set.Typ(obj,typ)
            obj.setValue(typ,obj.TypIndex);
        end
        function min=get.Min(obj)
            min=obj.Values(obj.MinIndex);
        end
        function set.Min(obj,min)
            obj.setValue(min,obj.MinIndex);
        end
        function max=get.Max(obj)
            max=obj.Values(obj.MaxIndex);
        end
        function set.Max(obj,max)
            obj.setValue(max,obj.MaxIndex);
        end
    end
    methods

        function verified=verifyValueForType(format,type,valuePassed)


            verified=false;
            if~isa(type,'serdes.internal.ibisami.ami.type.AmiType')
                return;
            end
            value=string(valuePassed);
            if~type.verifyValueForType(value)
                return
            end
            dMin=str2double(format.Min);
            dMax=str2double(format.Max);
            dDelta=str2double(format.DeltaToUse);
            testValue=dMin;
            while testValue<=dMax
                if type.isEqual(string(testValue),value)
                    verified=true;
                    return
                end
                testValue=testValue+dDelta;
            end
        end
    end
end

