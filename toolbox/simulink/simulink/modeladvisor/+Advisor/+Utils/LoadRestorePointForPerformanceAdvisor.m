classdef LoadRestorePointForPerformanceAdvisor<Advisor.Utils.LoadRestorePoint
    properties(SetAccess=private,GetAccess=private)
        IsHarness=false
        Owner=''
        MainModel=''
    end


    methods(Access=public)
        function this=LoadRestorePointForPerformanceAdvisor(advisorObj,restoreName)
            this@Advisor.Utils.LoadRestorePoint(advisorObj,restoreName);
        end
    end


    methods(Access=protected)
        function closeModel(this,modelName)
            if strcmp(get_param(modelName,'IsHarness'),'on')
                hInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelName);
                this.Owner=hInfo.ownerFullPath;
                this.MainModel=hInfo.model;
                close_system(this.MainModel,0);
                this.IsHarness=true;
            else
                close_system(modelName,0);
            end
        end


        function openModel(this,modelName)
            if this.IsHarness
                open_system(this.MainModel);
                Simulink.harness.open(this.Owner,modelName);
            else
                open_system(modelName);
            end
        end


        function setModelFile(this,modelName,modelFile)
            if get_param(modelName,'IsHarness')=="on"&&~Simulink.harness.internal.isSavedIndependently(modelName)
                slInternal('associate_with_file',this.MainModel,modelFile);
            else
                slInternal('associate_with_file',modelName,modelFile);
            end
        end


        function loadPrivateData(this)%#ok
        end


        function loadMiscData(this)
            set_param(this.Model,'dirty',this.Snapshots{this.CurrentSnapshotIndex}.mdldirtyflag);
            this.updateAdvisorObjectForFastRestore;
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
    end
end
function attachListener(this)
    this.ApplicationObj.mdlListenerOperation('AttachListener');
end


function detachListener(this)

    this.ApplicationObj.mdlListenerOperation('DettachListener');
end


function loadPrivateData(this)%#ok

end


function updateAdvisorGui(this)
    this.updateAdvisorGuiForFastRestore;
end


function cacheAdvisorObject(this)%#ok

end
