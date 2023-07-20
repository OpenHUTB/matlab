


classdef VariableType<uint8
    enumeration
        Local(1)
        Global(2)
        Persistent(3)
        Input(4)
        Output(8)
        InputOutput(12)
    end

    methods
        function input=isInput(this)
            input=logical(bitget(this,3));
        end

        function output=isOutput(this)
            output=logical(bitget(this,4));
        end
    end
end