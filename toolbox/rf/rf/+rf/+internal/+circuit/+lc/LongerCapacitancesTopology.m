classdef LongerCapacitancesTopology<rf.internal.circuit.lc.LadderTopology





    methods(Access=protected)
        function validateLCValuesFcn(obj,L,C)

            if isempty(L)
                validateattributes(L,{'numeric'},{},...
                obj.TopologyString,'Inductances')
            else

                validateattributes(L,{'numeric'},...
                {'vector','nonnan','real','nonnegative'},...
                obj.TopologyString,'Inductances')
            end


            validateattributes(C,{'numeric'},...
            {'nonempty','vector','nonnan','real','nonnegative'},...
            obj.TopologyString,'Capacitances')

            numL=numel(L);
            numC=numel(C);
            if(numL~=numC)&&(numC~=(numL+1))

                error(message('rf:shared:LCLadderBadBadLCLengths_LongerC',obj.TopologyString))
            end
        end
    end


    methods
        function obj=LongerCapacitancesTopology(L,C)
            obj@rf.internal.circuit.lc.LadderTopology(L,C)
        end
    end

end