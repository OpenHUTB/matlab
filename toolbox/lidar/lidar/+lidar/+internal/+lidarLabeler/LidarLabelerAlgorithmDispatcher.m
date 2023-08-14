




classdef LidarLabelerAlgorithmDispatcher<vision.internal.labeler.AlgorithmDispatcher

    methods(Static,Hidden)

        function repo=getRepository()
            repo=lidar.internal.lidarLabeler.LidarLabelerAlgorithmRepository.getInstance();
        end
    end
end
