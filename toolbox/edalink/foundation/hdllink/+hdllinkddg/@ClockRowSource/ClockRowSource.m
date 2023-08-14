classdef ClockRowSource<matlab.mixin.SetGet&matlab.mixin.Copyable









    properties(SetObservable)

        path{matlab.internal.validation.mustBeASCIICharRowVector(path,'path')}='';


        edge(1,1)int16{mustBeReal}=2;

        period{matlab.internal.validation.mustBeASCIICharRowVector(period,'period')}='';
    end

    methods
        function this=ClockRowSource(varargin)



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
                this.edge=l_convertEdgeValue('Rising');
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
        edgeStr2Int=containers.Map({'Falling','Rising'},{1,2});
    end
    methods(Static)
        function valout=convertEdgeValue(valin)
            if ischar(valin)
                valout=hdllinkddg.ClockRowSource.edgeStr2Int(valin);
            else
                valout=valin;
            end
        end
        function edgeInts=getEdgeIntValues()
            edgeInts=cell2mat(hdllinkddg.ClockRowSource.edgeStr2Int.values);
        end
        function edgeStrs=getEdgeStrValues()
            edgeStrs=hdllinkddg.ClockRowSource.edgeStr2Int.keys;
        end
    end
end

function valout=l_convertEdgeValue(valin)
    valout=hdllinkddg.ClockRowSource.convertEdgeValue(valin);
end