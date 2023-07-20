classdef LongerInductancesTopology<rf.internal.circuit.lc.LadderTopology





    methods(Access=protected)
        function validateLCValuesFcn(obj,L,C)

            validateattributes(L,{'numeric'},...
            {'nonempty','vector','nonnan','real','nonnegative'},...
            obj.TopologyString,'Inductances')


            if isempty(C)
                validateattributes(C,{'numeric'},{},...
                obj.TopologyString,'Capacitances')
            else

                validateattributes(C,{'numeric'},...
                {'vector','nonnan','real','nonnegative'},...
                obj.TopologyString,'Capacitances')
            end

            numL=numel(L);
            numC=numel(C);
            if(numL~=numC)&&(numL~=(numC+1))

                error(message('rf:shared:LCLadderBadBadLCLengths_LongerL',obj.TopologyString))
            end
        end
    end


    methods
        function obj=LongerInductancesTopology(L,C)
            obj@rf.internal.circuit.lc.LadderTopology(L,C)
        end
    end

end