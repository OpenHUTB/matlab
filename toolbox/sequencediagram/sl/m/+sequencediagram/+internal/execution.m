classdef(Hidden)execution




    methods(Hidden,Static)
        function enable()



            sequencediagram.internal.execution.loadLibraries();
            slfeature('SequenceDiagramExecutionToolstrip',1);
            slfeature('ObserverMessageSupport',1);
            slfeature('SequenceDiagramZCIntegExecutionToolstrip',1);
            slfeature('SDMessageOperandOrphanHighlighting',1);
        end

        function disable()
            sequencediagram.internal.execution.loadLibraries();
            slfeature('SequenceDiagramExecutionToolstrip',0);
            slfeature('ObserverMessageSupport',0);
            slfeature('SequenceDiagramZCIntegExecutionToolstrip',0);
            slfeature('SDMessageOperandOrphanHighlighting',0);
        end
    end

    methods(Access=private,Static)
        function loadLibraries()












            sequencediagram.internal.sl.kernel.getSimulinkApp();

        end
    end
end


