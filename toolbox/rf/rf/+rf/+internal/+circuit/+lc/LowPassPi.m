classdef LowPassPi<rf.internal.circuit.lc.LongerCapacitancesTopology


    properties(Constant)
        TopologyString='lowpasspi'
    end


    methods(Access=protected)
        function updateCircuit(obj)
            ckt=circuit;
            L=obj.LCValues{1};
            C=obj.LCValues{2};


            for nC=1:numel(C)
                add(ckt,[(nC+1),1],capacitor(C(nC)))
            end


            numL=numel(L);
            for nL=1:numL
                add(ckt,[(nL+1),(nL+2)],inductor(L(nL)))
            end


            setports(ckt,[2,1],[(2+numL),1])

            obj.LadderCircuit=ckt;
        end
    end


    methods
        function obj=LowPassPi(L,C)
            obj@rf.internal.circuit.lc.LongerCapacitancesTopology(L,C)
        end
    end

end