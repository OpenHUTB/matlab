classdef SaveRestorePointForFPCA<Advisor.Utils.SaveRestorePoint
    methods(Access=public)
        function this=SaveRestorePointForFPCA(advisorObj,restoreName,description)
            this@Advisor.Utils.SaveRestorePoint(advisorObj,restoreName,description);
        end
    end


    methods(Access=protected)
        function savePrivateData(this)
            fpcadvisorprivate('utilHandle_FPAdvisorData','save',this.System,this.SnapshotDir,this.SubDirName);
        end


        function saveReferencedModels(this)
            if(length(fpcadvisorprivate('utilFindMdlRefsOfInterest',this.Model))>1)
                this.Snapshots{this.CurrentSnapshotIndex}.fpca_ref_mdls=...
                fpcadvisorprivate('utilHandle_FPAdvisorRefMdls','save',this.Model,this.FullSubDirName);
            end
        end
    end
end
