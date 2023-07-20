






classdef BlockSignalSource<slsim.SignalSource

    properties(SetAccess=private,GetAccess=public)




        Outport(1,1)int32=0
    end

    methods(Static,Hidden)

        function validateOutport(outport)
            mustBePositive(outport);
            mustBeInteger(outport);
        end

    end

end
