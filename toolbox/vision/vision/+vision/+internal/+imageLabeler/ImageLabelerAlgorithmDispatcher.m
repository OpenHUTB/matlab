




classdef ImageLabelerAlgorithmDispatcher<vision.internal.labeler.AlgorithmDispatcher

    methods(Static,Hidden)

        function repo=getRepository()
            repo=vision.internal.imageLabeler.ImageLabelerAlgorithmRepository.getInstance();
        end
    end
end