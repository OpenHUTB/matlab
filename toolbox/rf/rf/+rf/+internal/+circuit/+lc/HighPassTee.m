classdef HighPassTee<rf.internal.circuit.lc.LongerCapacitancesTopology


    properties(Constant)
        TopologyString='highpasstee'
    end


    methods(Access=protected)
        function updateCircuit(obj)
            ckt=circuit;
            L=obj.LCValues{1};
            C=obj.LCValues{2};


            numC=numel(C);
            for nC=1:numC
                add(ckt,[(nC+1),(nC+2)],capacitor(C(nC)))
            end


            for nL=1:numel(L)
                add(ckt,[(nL+2),1],inductor(L(nL)))
            end


            setports(ckt,[2,1],[(2+numC),1])

            obj.LadderCircuit=ckt;
        end
    end


    methods
        function obj=HighPassTee(L,C)
            obj@rf.internal.circuit.lc.LongerCapacitancesTopology(L,C)
        end
    end

end