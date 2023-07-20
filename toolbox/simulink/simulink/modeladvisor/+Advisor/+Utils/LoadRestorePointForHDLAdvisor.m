classdef LoadRestorePointForHDLAdvisor<Advisor.Utils.LoadRestorePoint
    methods(Access=public)
        function this=LoadRestorePointForHDLAdvisor(advisorObj,restoreName)
            this@Advisor.Utils.LoadRestorePoint(advisorObj,restoreName);
        end
    end


    methods(Access=protected)
        function loadPrivateData(this)
            hdladvisor(this.System,'AutoRestore');
        end
    end
end
