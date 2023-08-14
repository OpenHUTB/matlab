classdef(Hidden)PhysicalInterface<Simulink.interface.dictionary.PortInterface





    properties(Access=protected)
        ElementQualifiedClassName='Simulink.interface.dictionary.PhysicalElement';
    end

    methods
        function this=PhysicalInterface(zcImpl,dictImpl)
            this@Simulink.interface.dictionary.PortInterface(zcImpl,dictImpl);
        end
    end
end
