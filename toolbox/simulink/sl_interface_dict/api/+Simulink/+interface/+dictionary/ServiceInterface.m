classdef(Hidden)ServiceInterface<Simulink.interface.dictionary.PortInterface





    properties(Access=protected)
        ElementQualifiedClassName='Simulink.interface.dictionary.FunctionElement';
    end

    methods
        function this=ServiceInterface(zcImpl,dictImpl)
            this@Simulink.interface.dictionary.PortInterface(zcImpl,dictImpl);
        end
    end
end
