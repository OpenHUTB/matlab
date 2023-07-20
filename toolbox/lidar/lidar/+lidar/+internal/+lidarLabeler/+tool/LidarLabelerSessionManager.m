classdef LidarLabelerSessionManager<vision.internal.videoLabeler.tool.VideoLabelerSessionManager




    methods

        function this=LidarLabelerSessionManager()
            this=this@vision.internal.videoLabeler.tool.VideoLabelerSessionManager();
            this.AppName='Lidar Labeler';
            this.SessionField='lidarLabelingSession';
            this.SessionClass='lidar.internal.lidarLabeler.tool.Session';
        end
    end
end
