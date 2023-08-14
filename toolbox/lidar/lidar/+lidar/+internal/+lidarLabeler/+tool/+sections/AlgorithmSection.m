classdef AlgorithmSection<vision.internal.labeler.tool.sections.AlgorithmSection




    methods(Access=public)
        function this=AlgorithmSection(tool)
            this@vision.internal.labeler.tool.sections.AlgorithmSection(tool);
        end
    end
    methods(Access=protected)
        function createNewAlgorithm(this)
            lidar.labeler.AutomationAlgorithm.openTemplateInEditor('lidar');
        end

        function repo=getAlgorithmRepository(this)
            repo=lidar.internal.lidarLabeler.LidarLabelerAlgorithmRepository.getInstance();
        end
    end
end