classdef SimulinkListenerUtils<handle




    methods(Static)


        function restoreListener=disableSimulinkListener(model)
            mapping=autosar.api.Utils.modelMapping(model);
            assert(isa(mapping,'Simulink.AutosarTarget.CompositionModelMapping'));
            restoreListener=onCleanup(@()...
            autosar.composition.studio.SimulinkListenerUtils.enableSimulinkListener(model));
            mapping.IsSimulinkListenerEnabled=false;
        end
    end

    methods(Hidden,Static)
        function enableSimulinkListener(model)
            mapping=autosar.api.Utils.modelMapping(model);
            assert(isa(mapping,'Simulink.AutosarTarget.CompositionModelMapping'));
            mapping.IsSimulinkListenerEnabled=true;
        end
    end
end
