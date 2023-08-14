




classdef MultiSignalLabelerAlgorithmDispatcher<vision.internal.labeler.AlgorithmDispatcher

    methods(Static,Hidden)

        function repo=getRepository()
            repo=vision.internal.videoLabeler.MultiSignalLabelerAlgorithmRepository.getInstance();
        end
    end
end