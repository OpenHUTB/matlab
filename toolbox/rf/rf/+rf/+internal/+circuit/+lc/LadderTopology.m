classdef LadderTopology<handle



    properties(Dependent)

Inductances
Capacitances
    end
    properties(Access=protected)
LCValues
    end
    properties(SetAccess=protected)

LadderCircuit
    end
    properties(Abstract,Constant)
TopologyString
    end


    methods(Abstract,Access=protected)

        updateCircuit(obj)
        validateLCValuesFcn(obj,L,C)
    end


    methods
        function obj=LadderTopology(L,C)
            obj.LCValues={L,C};
        end
    end


    methods
        function set.LCValues(obj,LCcell)
            L=LCcell{1};
            C=LCcell{2};
            validateLCValuesFcn(obj,L,C)
            obj.LCValues={L(:).',C(:).'};
            updateCircuit(obj)
        end

        function set.Inductances(obj,newL)
            oldC=obj.LCValues{2};
            obj.LCValues={newL,oldC};
        end

        function set.Capacitances(obj,newC)
            oldL=obj.LCValues{1};
            obj.LCValues={oldL,newC};
        end
    end


    methods
        function L=get.Inductances(obj)
            L=obj.LCValues{1};
        end

        function C=get.Capacitances(obj)
            C=obj.LCValues{2};
        end
    end

end