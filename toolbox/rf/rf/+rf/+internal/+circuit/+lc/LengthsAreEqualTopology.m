classdef LengthsAreEqualTopology<rf.internal.circuit.lc.LadderTopology





    methods(Access=protected)
        function validateLCValuesFcn(obj,L,C)

            validateattributes(L,{'numeric'},...
            {'nonempty','vector','nonnan','real','nonnegative'},...
            obj.TopologyString,'Inductances')


            validateattributes(C,{'numeric'},...
            {'nonempty','vector','nonnan','real','nonnegative'},...
            obj.TopologyString,'Capacitances')

            if numel(L)~=numel(C)

                error(message('rf:shared:LCLadderBadBadLCLengths_Equal',obj.TopologyString))
            end
        end
    end


    methods
        function obj=LengthsAreEqualTopology(L,C)
            obj@rf.internal.circuit.lc.LadderTopology(L,C)
        end
    end

end