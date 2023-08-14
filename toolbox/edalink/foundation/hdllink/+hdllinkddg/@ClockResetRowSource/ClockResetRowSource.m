classdef ClockResetRowSource<matlab.mixin.SetGet&matlab.mixin.Copyable









    properties(SetObservable)

        path{matlab.internal.validation.mustBeASCIICharRowVector(path,'path')}='';

        edge(1,1)int16{mustBeReal}=2;

        period{matlab.internal.validation.mustBeASCIICharRowVector(period,'period')}='';
    end

    methods
        function this=ClockResetRowSource(varargin)



            if(nargin==1)
                s=varargin{1};
                this.path=s.path;
                this.edge=l_convertEdgeValue(s.edge);
                this.period=s.period;

            elseif(nargin==3)
                [path,edge,period]=deal(varargin{:});
                this.path=path;
                this.edge=l_convertEdgeValue(edge);
                this.period=period;
            elseif(nargin==0)
                this.path='/top/clk';
                this.edge=l_convertEdgeValue('Active Rising Edge Clock');
                this.period='2';
            else
                error(message('HDLLink:ClockRowSource:BadCtor'));
            end
        end
    end

    methods
        function set.path(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.path=value;
        end

        function set.edge(obj,value)




            obj.edge=value;
        end

        function set.period(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','period')
            obj.period=value;
        end
    end

    properties(Access=private,Constant)
        edgeStr={'Active Falling Edge Clock','Active Rising Edge Clock','Step 1 to 0','Step 0 to 1'};
        edgeInt={1,2,3,4};
        edgeStr2Int=containers.Map(hdllinkddg.ClockResetRowSource.edgeStr,hdllinkddg.ClockResetRowSource.edgeInt);
        edgeInt2Str=containers.Map(hdllinkddg.ClockResetRowSource.edgeInt,hdllinkddg.ClockResetRowSource.edgeStr);
    end
    methods(Static)
        function valout=convertPropValue(propname,valin)
            if ischar(valin)
                valout=hdllinkddg.ClockResetRowSource.([propname,'Str2Int'])(valin);
            else
                valout=hdllinkddg.ClockResetRowSource.([propname,'Int2Str'])(valin);
            end
        end
        function allInts=getIntValues(propname)
            allInts=cell2mat(hdllinkddg.ClockResetRowSource.([propname,'Int']));
        end
        function allStrs=getStrValues(propname)
            allStrs=hdllinkddg.ClockResetRowSource.([propname,'Str']);
        end
    end
end

function valout=l_convertEdgeValue(valin)
    valout=hdllinkddg.ClockResetRowSource.convertPropValue('edge',valin);
end
