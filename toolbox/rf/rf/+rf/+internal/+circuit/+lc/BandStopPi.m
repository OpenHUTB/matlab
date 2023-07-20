classdef BandStopPi<rf.internal.circuit.lc.LengthsAreEqualTopology


    properties(Constant)
        TopologyString='bandstoppi'
    end


    methods(Access=protected)
        function updateCircuit(obj)
            ckt=circuit;
            L=obj.LCValues{1};
            C=obj.LCValues{2};
            numL=numel(L);


            for n=1:2:numL
                add(ckt,[(n+1),(n+2)],inductor(L(n)))
                add(ckt,[(n+2),1],capacitor(C(n)))
            end


            for n=2:2:numL
                add(ckt,[n,(n+2)],inductor(L(n)))
                add(ckt,[n,(n+2)],capacitor(C(n)))
            end


            p2plusnode=2*floor(1+numL/2);
            setports(ckt,[2,1],[p2plusnode,1])

            obj.LadderCircuit=ckt;
        end
    end


    methods
        function obj=BandStopPi(L,C)
            obj@rf.internal.circuit.lc.LengthsAreEqualTopology(L,C)
        end
    end

end