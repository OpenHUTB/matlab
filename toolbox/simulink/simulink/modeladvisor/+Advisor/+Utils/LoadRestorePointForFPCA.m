classdef LoadRestorePointForFPCA<Advisor.Utils.LoadRestorePoint
    methods(Access=public)
        function this=LoadRestorePointForFPCA(advisorObj,restoreName)
            this@Advisor.Utils.LoadRestorePoint(advisorObj,restoreName);
        end
    end


    methods(Access=protected)
        function loadPrivateData(this)
            if~isempty(this.AdvisorObject.CustomObject)&&~isempty(this.AdvisorObject.CustomObject.LoadRestorePointCallback)
                modeladvisorprivate('modeladvisorutil2','ProcessCallbackFcn',this.AdvisorObject.CustomObject.LoadRestorePointCallback,this);
            else
                fpcadvisor(this.System,'RestorePointLoad',this.SnapshotDir,this.SubDirName);
            end
        end


        function loadReferencedModels(this)
            if(length(fpcadvisorprivate('utilFindMdlRefsOfInterest',this.Model))>1)
                fpcadvisorprivate('utilHandle_FPAdvisorRefMdls','load',this.Model,this.FullSubDirName,this.Snapshots{this.CurrentSnapshotIndex});
            end
        end
    end
end
