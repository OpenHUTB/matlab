classdef(Hidden)annotation

    methods(Hidden,Static)
        function enable()

            sequencediagram.internal.annotation.loadLibraries();
            slfeature('SequenceDiagramAnnotation',1);
            slfeature('SequenceDiagramZCIntegAnnotationToolstrip',1);
        end


        function disable()
            sequencediagram.internal.annotation.loadLibraries();
            slfeature('SequenceDiagramAnnotation',0);
            slfeature('SequenceDiagramZCIntegAnnotationToolstrip',0);
        end
    end


    methods(Access=private,Static)
        function loadLibraries()
            sequencediagram.internal.sl.kernel.getSimulinkApp();

        end
    end
end


