classdef SaveRestorePointForMdlRefAdvisor<Advisor.Utils.SaveRestorePoint
    methods(Access=public)
        function this=SaveRestorePointForMdlRefAdvisor(advisorObj,restoreName,description)
            this@Advisor.Utils.SaveRestorePoint(advisorObj,restoreName,description);
        end
    end


    methods(Access=protected)



        function getRestorePointList(this)
            [this.Snapshots,this.SnapshotDir,this.SnapshotInfoMat]=Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.getRestorePointList;
        end


        function updateRestorePointList(this,snapshots,snapshotdir,snapshotInfoMat)%#ok
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.updateRestorePointList(...
            this.Snapshots,this.SnapshotDir,this.SnapshotInfoMat);
        end



        function[snapShotSaved,hasUnsavedChanges]=saveWorkspaceData(this)%#ok
            snapShotSaved=true;
            hasUnsavedChanges=false;
        end


        function copyModelAdvisorData(this,workDir)%#ok
        end
    end
end
