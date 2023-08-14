




classdef VideoLabelerAlgorithmDispatcher<vision.internal.labeler.AlgorithmDispatcher

    methods(Static,Hidden)

        function repo=getRepository()
            repo=vision.internal.labeler.VideoLabelerAlgorithmRepository.getInstance();
        end
    end
end