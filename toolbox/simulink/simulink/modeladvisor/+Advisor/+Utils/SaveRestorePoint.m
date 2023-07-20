classdef SaveRestorePoint<handle
    properties(SetAccess=protected,GetAccess=protected)
System
Model

Snapshots
SnapshotDir
SnapshotInfoMat

FullSubDirName
SubDirName
CurrentSnapshotIndex
CustomTARootID
    end


    properties(SetAccess=private,GetAccess=private)
AdvisorObject
MAExplorer
RestoreName
Description
    end


    methods(Static,Access=public)
        function obj=getSaveRestorePointObject(advisorObj,restoreName,description)
            rootId=advisorObj.CustomTARootID;
            if strcmp(rootId,Advisor.Utils.AdvisorRootIds.ModelReferenceConversionAdvisor)
                obj=Advisor.Utils.SaveRestorePointForMdlRefAdvisor(advisorObj,restoreName,description);
            elseif strcmp(rootId,Advisor.Utils.AdvisorRootIds.FixedPointAdvisor)
                obj=Advisor.Utils.SaveRestorePointForFPCA(advisorObj,restoreName,description);
            else
                obj=Advisor.Utils.SaveRestorePoint(advisorObj,restoreName,description);
            end
        end
    end


    methods(Access=public)
        function varargout=save(this)
            this.prepare;
            [snapShotSaved,hasUnsavedChanges]=this.saveWorkspaceData;



            if snapShotSaved
                this.savePrivateData;
                this.saveModel;
                this.saveMiscData;
            end




            this.updateRestorePointList;





            if nargout==1
                varargout{1}=hasUnsavedChanges;
            end
        end
    end



    methods(Access=protected)
        function this=SaveRestorePoint(advisorObj,restoreName,description)
            this.AdvisorObject=advisorObj;
            this.MAExplorer=this.AdvisorObject.MAExplorer;
            this.System=getfullname(this.AdvisorObject.System);
            this.Model=bdroot(this.System);
            this.CustomTARootID=this.AdvisorObject.CustomTARootID;
            this.RestoreName=restoreName;
            this.Description=description;
        end


        function savePrivateData(this)%#ok
        end


        function saveReferencedModels(this)%#ok
        end


        function getRestorePointList(this)
            [this.Snapshots,this.SnapshotDir,this.SnapshotInfoMat]=this.AdvisorObject.getRestorePointList;
        end


        function updateRestorePointList(this)%#ok
        end


        function copyModelAdvisorData(this,workDir)
            copyfile(fullfile(workDir,'ModelAdvisorData'),this.FullSubDirName);
        end


        function[snapShotSaved,hasUnsavedChanges]=saveWorkspaceData(this)







            snapShotSaved=true;
            hasUnsavedChanges=false;

            ddName=get_param(bdroot(this.AdvisorObject.SystemName),'DataDictionary');
            if modeladvisorprivate('modeladvisorutil2','FeatureControl','DDRestorePoint')&&~isempty(ddName)

                ddConnection=Simulink.dd.open(ddName);


                if ddConnection.hasUnsavedChanges
                    answer=questdlg(DAStudio.message('ModelAdvisor:engine:MASnapshotDDUnsavedChanges'),...
                    DAStudio.message('ModelAdvisor:engine:MASnapshotDDUnsavedChangesTitle'),...
                    DAStudio.message('Simulink:tools:MAOk'),...
                    DAStudio.message('Simulink:tools:MANo'),...
                    DAStudio.message('Simulink:tools:MACancel'),...
                    DAStudio.message('Simulink:tools:MACancel'));

                    if strcmp(answer,DAStudio.message('Simulink:tools:MACancel'))

                        ddConnection.close();
                        this.MAExplorer.setStatusMessage('');
                        rmdir([this.SnapshotDir,filesep,this.SubDirName]);
                        snapShotSaved=false;
                        hasUnsavedChanges=true;
                        return;
                    elseif strcmp(answer,DAStudio.message('Simulink:tools:MAOk'))

                        ddConnection.saveChanges;
                    end
                end



                hasUnsavedChanges=ddConnection.hasUnsavedChanges;
                copyfile(which(ddName),fullfile(this.SnapshotDir,['dd',this.SubDirName,'.sldd']));


                ddConnection.close();

                if slfeature('SLModelAllowedBaseWorkspaceAccess')>0&&...
                    strcmp(get_param(bdroot(this.AdvisorObject.SystemName),'HasAccessToBaseWorkspace'),'on')


                    workspaceMat=fullfile(this.SnapshotDir,['workspace',this.SubDirName,'.mat']);
                    evalin('base',['save(''',workspaceMat,''')']);
                end
            else


                workspaceMat=fullfile(this.SnapshotDir,['workspace',this.SubDirName,'.mat']);
                evalin('base',['save(''',workspaceMat,''')']);
            end
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
                if~isempty(this.Snapshots)
                    subdirIndex=this.Snapshots{end}.Index+1;
                else
                    subdirIndex=1;
                end
                this.CurrentSnapshotIndex=length(this.Snapshots)+1;
            else
                subdirIndex=this.Snapshots{i}.Index;
                this.CurrentSnapshotIndex=i;
            end

            this.Snapshots{this.CurrentSnapshotIndex}.name=this.RestoreName;
            this.Snapshots{this.CurrentSnapshotIndex}.description=this.Description;
            this.Snapshots{this.CurrentSnapshotIndex}.timestamp=now;
            this.Snapshots{this.CurrentSnapshotIndex}.Index=subdirIndex;
            this.Snapshots{this.CurrentSnapshotIndex}.ConfigFilePath=this.AdvisorObject.ConfigFilePath;

            this.SubDirName=num2str(subdirIndex);
            this.FullSubDirName=fullfile(this.SnapshotDir,this.SubDirName);


            if exist(this.FullSubDirName,'dir')
                delete(fullfile(this.FullSubDirName,'*.*'));
            else
                mkdir(this.SnapshotDir,this.SubDirName);
            end


            if isa(this.MAExplorer,'DAStudio.Explorer')
                this.MAExplorer.setStatusMessage(DAStudio.message('Simulink:tools:MASavingRestorePoint',this.RestoreName));
            end
        end


        function saveModel(this)
            this.saveReferencedModels;
            [~,~,rootMdlExtension]=fileparts(which(this.Model));
            mdlSaveName=fullfile(this.FullSubDirName,[this.Model,rootMdlExtension]);
            if strcmp(get_param(this.Model,'IsHarness'),'on')
                ownerModel=Simulink.harness.internal.getHarnessOwnerBD(this.Model);
                mdlSaveName=fullfile(this.FullSubDirName,[ownerModel,'.slx']);
                slInternal('snapshot_slx',ownerModel,mdlSaveName);
            elseif strcmp(rootMdlExtension,'.slx')
                slInternal('snapshot_slx',this.Model,mdlSaveName);
            else
                slInternal('snapshot_mdl',this.Model,mdlSaveName);
            end
        end


        function saveMiscData(this)
            this.Snapshots{this.CurrentSnapshotIndex}.mdldirtyflag=get_param(this.Model,'dirty');


            modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorInfo',this.AdvisorObject);
            workdir=this.AdvisorObject.getWorkDir('CheckOnly');
            if exist(fullfile(workdir,'*.html'),'file')
                copyfile(fullfile(workdir,'*.html'),this.FullSubDirName);
            end

            this.copyModelAdvisorData(workdir);


            if isa(this.MAExplorer,'DAStudio.Explorer')
                this.MAExplorer.setStatusMessage('');
            end


            snapshots=this.Snapshots;%#ok
            save(this.SnapshotInfoMat,'snapshots');
        end
    end
end
