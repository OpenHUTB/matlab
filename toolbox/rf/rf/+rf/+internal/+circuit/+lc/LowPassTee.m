classdef LowPassTee<rf.internal.circuit.lc.LongerInductancesTopology


    properties(Constant)
        TopologyString='lowpasstee'
    end


    methods(Access=protected)
        function updateCircuit(obj)
            ckt=circuit;
            L=obj.LCValues{1};
            C=obj.LCValues{2};


            numL=numel(L);
            for nL=1:numL
                add(ckt,[(nL+1),(nL+2)],inductor(L(nL)))
            end


            for nC=1:numel(C)
                add(ckt,[(nC+2),1],capacitor(C(nC)))
            end


            setports(ckt,[2,1],[(2+numL),1])

            obj.LadderCircuit=ckt;
        end
    end


    methods
        function obj=LowPassTee(L,C)
            obj@rf.internal.circuit.lc.LongerInductancesTopology(L,C)
        end
    end

end