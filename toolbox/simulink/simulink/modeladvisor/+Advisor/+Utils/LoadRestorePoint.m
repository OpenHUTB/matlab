classdef LoadRestorePoint<handle
    properties(SetAccess=protected,GetAccess=protected)
AdvisorObject
Model
System

Snapshots
SnapshotDir

FullSubDirName
SubDirName
CurrentSnapshotIndex


ApplicationObject


HarnessOwnerModel
HarnessOwnerFullPath
HarnessName
    end


    properties(SetAccess=private,GetAccess=private)
RestoreName
    end


    methods(Static,Access=public)
        function obj=getLoadRestorePointObject(advisorObj,name)
            rootId=advisorObj.CustomTARootID;
            if strcmp(rootId,Advisor.Utils.AdvisorRootIds.ModelReferenceConversionAdvisor)
                obj=Advisor.Utils.LoadRestorePointForMdlRefAdvisor(advisorObj,name);
            elseif strcmp(rootId,Advisor.Utils.AdvisorRootIds.FixedPointAdvisor)
                obj=Advisor.Utils.LoadRestorePointForFPCA(advisorObj,name);
            elseif strcmp(rootId,Advisor.Utils.AdvisorRootIds.HDLAdvisor)
                obj=Advisor.Utils.LoadRestorePointForHDLAdvisor(advisorObj,name);
            elseif strcmp(rootId,Advisor.Utils.AdvisorRootIds.PerformanceAdvisor)

                obj=Advisor.Utils.LoadRestorePoint(advisorObj,name);
            else
                obj=Advisor.Utils.LoadRestorePoint(advisorObj,name);
            end
        end
    end


    methods(Access=public)
        function load(this)
            this.prepare;
            this.detachListener;
            this.loadModel;
            this.loadWorkspaceData;
            this.loadMiscData;
            this.loadPrivateData;
            this.attachListener;
        end
    end


    methods(Access=protected)
        function this=LoadRestorePoint(advisorObj,restoreName)
            this.AdvisorObject=advisorObj;
            this.System=advisorObj.SystemName;
            this.Model=advisorObj.ModelName;
            this.RestoreName=restoreName;
        end


        function detachListener(this)%#ok
        end


        function attachListener(this)%#ok
        end

        function updateAdvisorObjectForFastRestore(this)
            mdlObj=get_param(this.Model,'Object');


            mdlObj.setModelAdvisorObj(this.AdvisorObject);
            Simulink.ModelAdvisor.getActiveModelAdvisorObj(this.AdvisorObject);
            this.updateSystemInfo;
        end

        function updateSystemInfo(this)


            try
                this.AdvisorObject.System=this.System;
                this.AdvisorObject.SystemName=this.System;
                this.AdvisorObject.SystemHandle=get_param(this.System,'handle');
            catch me %#ok
            end
        end

        function loadWorkspaceData(this)
            if exist(fullfile(this.SnapshotDir,['dd',this.SubDirName,'.sldd']),'file')

                ddName=get_param(this.Model,'DataDictionary');
                ddPath=which(ddName);
                set_param(this.Model,'DataDictionary','');


                delete(ddPath);

                copyfile(fullfile(this.SnapshotDir,['dd',this.SubDirName,'.sldd']),ddPath);


                dd=Simulink.dd.open(ddName);
                dd.discardChanges();
                dd.close();
                set_param(this.Model,'DataDictionary',ddName);
            else


                workspacematfile=fullfile(this.SnapshotDir,['workspace',this.SubDirName,'.mat']);
                evalin('base',['load(''',workspacematfile,''')']);
            end
        end


        function loadReferencedModels(this)%#ok
        end


        function loadPrivateData(this)
            if~isempty(this.AdvisorObject.CustomObject)&&~isempty(this.AdvisorObject.CustomObject.LoadRestorePointCallback)
                modeladvisorprivate('modeladvisorutil2','ProcessCallbackFcn',this.AdvisorObject.CustomObject.LoadRestorePointCallback,this.AdvisorObject);
            else
                if isempty(this.Snapshots{this.CurrentSnapshotIndex}.ConfigFilePath)
                    modeladvisor(this.System);
                else
                    modeladvisor(this.System,'configuration',this.Snapshots{this.CurrentSnapshotIndex}.ConfigFilePath);
                end
            end
        end


        function loadMiscData(this)
            set_param(this.Model,'dirty',this.Snapshots{this.CurrentSnapshotIndex}.mdldirtyflag);


            this.loadReferencedModels;


            copyfile(this.FullSubDirName,this.AdvisorObject.WorkDir,'f');



            Simulink.ModelAdvisor.getActiveModelAdvisorObj([]);
        end


        function cacheAdvisorInfo(this)
            advisorObj=this.AdvisorObject;
            this.AdvisorObject=[];
            this.AdvisorObject.CustomTARootID=advisorObj.CustomTARootID;
            this.AdvisorObject.WorkDir=advisorObj.getWorkDir('CheckOnly');
            this.AdvisorObject.CustomObject=advisorObj.CustomObject;
            this.AdvisorObject.System=getfullname(advisorObj.System);
            this.AdvisorObject.SystemName=advisorObj.SystemName;
        end

        function setModelFile(this,modelName,modelFile)
            if get_param(modelName,'IsHarness')=="on"&&~Simulink.harness.internal.isSavedIndependently(modelName)
                slInternal('associate_with_file',this.HarnessOwnerModel,...
                modelFile);
            else
                slInternal('associate_with_file',modelName,modelFile);
            end
        end


        function openModel(this,modelName)
            if~isempty(this.HarnessName)
                open_system(this.HarnessOwnerModel);
                Simulink.harness.open(this.HarnessOwnerFullPath,...
                this.HarnessName);
            else
                open_system(modelName);
            end
        end


        function closeModel(this,modelName)
            if(strcmp(get_param(modelName,'IsHarness'),'on'))
                hInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelName);
                this.HarnessOwnerModel=hInfo.model;
                this.HarnessOwnerFullPath=hInfo.ownerFullPath;
                this.HarnessName=hInfo.name;
                close_system(this.HarnessOwnerModel,0);
            else
                close_system(modelName,0);
            end
        end


        function getRestorePointList(this)
            [this.Snapshots,this.SnapshotDir]=this.AdvisorObject.getRestorePointList;
        end
    end



    methods(Access=private)
        function prepare(this)
            this.getRestorePointList;


            foundInList=false;
            for i=1:length(this.Snapshots)
                if strcmp(this.Snapshots{i}.name,this.RestoreName)
                    foundInList=true;
                    break;
                end
            end
            if~foundInList
                DAStudio.error('Simulink:tools:MAUnableLocateRestorePointName',this.RestoreName);
            end


            this.CurrentSnapshotIndex=i;
            this.SubDirName=num2str(this.Snapshots{this.CurrentSnapshotIndex}.Index);
            this.FullSubDirName=fullfile(this.SnapshotDir,this.SubDirName);


            this.cacheAdvisorInfo;
        end


        function loadModel(this)





            origFileName=get_param(this.Model,'FileName');
            this.closeModel(this.Model);


            originaldir=pwd;
            addpath(originaldir);
            cd(this.FullSubDirName);

            this.openModel(this.Model);

            cd(originaldir);
            rmpath(originaldir);






            this.setModelFile(this.Model,origFileName);
        end
    end
end
