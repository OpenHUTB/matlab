classdef LoadRestorePointForMdlRefAdvisor<Advisor.Utils.LoadRestorePoint
    methods(Access=public)
        function this=LoadRestorePointForMdlRefAdvisor(advisorObj,restoreName)
            this@Advisor.Utils.LoadRestorePoint(advisorObj,restoreName);
        end
    end


    methods(Access=protected)
        function loadPrivateData(this)
            Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.reset(this.AdvisorObject);
        end


        function loadMiscData(this)
            set_param(this.Model,'dirty',this.Snapshots{this.CurrentSnapshotIndex}.mdldirtyflag);
            this.updateAdvisorObjectForFastRestore;
        end

        function updateSystemInfo(this)

















        end

        function loadWorkspaceData(this)%#ok
        end


        function cacheAdvisorInfo(this)%#ok
        end


        function detachListener(this)
            appId=this.AdvisorObject.ApplicationID;
            this.ApplicationObject=Advisor.Manager.getApplication(...
            'Id',appId,'token','MWAdvi3orAPICa11');
            this.ApplicationObject.mdlListenerOperation('DetachListener');
        end


        function attachListener(this)
            this.ApplicationObject.mdlListenerOperation('AttachListener');
        end


        function getRestorePointList(this)



            [this.Snapshots,this.SnapshotDir]=Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.getRestorePointList;
        end
    end
end
