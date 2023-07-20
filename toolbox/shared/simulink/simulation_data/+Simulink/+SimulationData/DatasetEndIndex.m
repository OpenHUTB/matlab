classdef DatasetEndIndex



    properties
        bEnd=0;
        pEnd=0;
    end

    methods
        function obj=DatasetEndIndex(pIndex,bIndex)
            obj.pEnd=pIndex;
            obj.bEnd=bIndex;
        end

        function obj=min(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=min(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=min(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=max(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=max(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=max(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=plus(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=plus(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=plus(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=minus(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=minus(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=minus(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=rdivide(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=rdivide(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=rdivide(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=ldivide(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=ldivide(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=ldivide(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=times(first,second)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            obj.bEnd=times(locGetBEnd(first),locGetBEnd(second));
            obj.pEnd=times(locGetPEnd(first),locGetPEnd(second));
        end

        function obj=uminus(obj)
            obj.bEnd=-obj.bEnd;
            obj.pEnd=-obj.pEnd;
        end

        function obj=uplus(obj)
            obj.bEnd=obj.bEnd;
            obj.pEnd=obj.pEnd;
        end

        function obj=colon(a,b,c)
            obj=Simulink.SimulationData.DatasetEndIndex(0,0);
            if nargin==2
                obj.pEnd=[locGetPEnd(a):locGetPEnd(b)];
                obj.bEnd=[locGetBEnd(a):locGetBEnd(b)];
            else
                obj.pEnd=[locGetPEnd(a):locGetPEnd(b):locGetPEnd(c)];
                obj.bEnd=[locGetBEnd(a):locGetBEnd(b):locGetBEnd(c)];
            end
        end

        function obj=transpose(obj)
            obj.pEnd=obj.pEnd';
            obj.bEnd=obj.bEnd';
        end

    end
end

function bEnd=locGetBEnd(val)
    if isa(val,'Simulink.SimulationData.DatasetEndIndex')
        bEnd=val.bEnd;
    else
        bEnd=val;
    end
end

function pEnd=locGetPEnd(val)
    if isa(val,'Simulink.SimulationData.DatasetEndIndex')
        pEnd=val.pEnd;
    else
        pEnd=val;
    end
end

