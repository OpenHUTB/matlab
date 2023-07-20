classdef HighPassPi<rf.internal.circuit.lc.LongerInductancesTopology


    properties(Constant)
        TopologyString='highpasspi'
    end


    methods(Access=protected)
        function updateCircuit(obj)
            ckt=circuit;
            L=obj.LCValues{1};
            C=obj.LCValues{2};


            for nL=1:numel(L)
                add(ckt,[(nL+1),1],inductor(L(nL)))
            end


            numC=numel(C);
            for nC=1:numC
                add(ckt,[(nC+1),(nC+2)],capacitor(C(nC)))
            end


            setports(ckt,[2,1],[(2+numC),1])

            obj.LadderCircuit=ckt;
        end
    end


    methods
        function obj=HighPassPi(L,C)
            obj@rf.internal.circuit.lc.LongerInductancesTopology(L,C)
        end
    end

end