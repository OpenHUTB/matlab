classdef DataInterface<Simulink.interface.dictionary.PortInterface




    properties(Access=protected)
        ElementQualifiedClassName='Simulink.interface.dictionary.DataElement';
    end

    methods
        function this=DataInterface(zcImpl,dictImpl)
            this@Simulink.interface.dictionary.PortInterface(zcImpl,dictImpl);
        end
    end
end
