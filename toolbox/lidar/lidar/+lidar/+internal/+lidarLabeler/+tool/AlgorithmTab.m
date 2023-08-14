



classdef AlgorithmTab<vision.internal.videoLabeler.tool.AlgorithmTab

    methods(Access=protected)

        function createViewSection(this)
            this.ViewSection=lidar.internal.lidarLabeler.tool.sections.ViewSection;
            this.addSectionToTab(this.ViewSection);
        end
    end


end