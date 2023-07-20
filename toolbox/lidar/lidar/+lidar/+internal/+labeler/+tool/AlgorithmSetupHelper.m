classdef AlgorithmSetupHelper<vision.internal.labeler.tool.AlgorithmSetupHelper




    methods
        function this=AlgorithmSetupHelper(appName)

            this=this@vision.internal.labeler.tool.AlgorithmSetupHelper(appName);
            this.Dispatcher=lidar.internal.lidarLabeler.LidarLabelerAlgorithmDispatcher();
        end

        function algorithmClass=getDispatcherAlgorithmClass(this)
            algorithmClass=this.Dispatcher.AlgorithmClass;
        end
    end
end