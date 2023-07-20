

classdef Snapshot<handle
    properties(Access=public)
        selectedTasks;
        systemInfo;
        pwd;
        parallelinfoFile;
        parallelJobInfoFile;
        TaskID;
        dbIndex;
    end

    methods(Access=public)
        function obj=Snapshot(mdladvObj,ID)
            obj.selectedTasks=zeros(length(mdladvObj.TaskAdvisorCellArray),1);
            obj.systemInfo.sysPath=mdladvObj.SystemName;
            obj.systemInfo.lastModified=get_param(bdroot(mdladvObj.SystemName),'LastModifiedDate');
            obj.systemInfo.system=bdroot(mdladvObj.SystemName);
            obj.systemInfo.systemName=mdladvObj.SystemName;
            obj.systemInfo.snapshotPath=fullfile(mdladvObj.getWorkDir,'parallel');
            if exist(obj.systemInfo.snapshotPath,'dir')
                delete(fullfile(obj.systemInfo.snapshotPath,'*.*'));
            else
                mkdir(obj.systemInfo.snapshotPath);
            end
            obj.pwd=pwd;%#ok<CPROP>


            obj.systemInfo.workspaceMat=fullfile(obj.systemInfo.snapshotPath,'workspace.mat');
            try
                testMode=modeladvisorprivate('modeladvisorutil2','FeatureControl','test');
                if~testMode
                    evalin('base',['save(''',obj.systemInfo.workspaceMat,''')']);
                else
                    testingMode=true;%#ok<NASGU>
                    save(obj.systemInfo.workspaceMat,'testingMode');
                end
            catch E
            end

            rootMdlName=get_param(bdroot(mdladvObj.System),'Name');
            [~,~,rootMdlExtension]=fileparts(which(rootMdlName));
            if strcmp(rootMdlExtension,'.slx')
                mdlSaveName=fullfile(obj.systemInfo.snapshotPath,[rootMdlName,'.slx']);
                slInternal('snapshot_slx',rootMdlName,mdlSaveName);
            else
                mdlSaveName=fullfile(obj.systemInfo.snapshotPath,[rootMdlName,'.mdl']);
                slInternal('snapshot_mdl',rootMdlName,mdlSaveName);
            end
            obj.TaskID=ID;
            obj.serialize(mdladvObj);
        end

        function serialize(obj,mdladvObj)
            mdladvObj.Database.overwriteLatestData('ParallelInfo','sysPath',{obj.systemInfo.sysPath},...
            'lastModified',obj.systemInfo.lastModified,...
            'system',{obj.systemInfo.system},...
            'systemName',{obj.systemInfo.systemName},...
            'snapshotPath',{obj.systemInfo.snapshotPath},...
            'workspaceMat',{obj.systemInfo.workspaceMat},...
            'pwd',{obj.pwd},...
            'TaskID',obj.TaskID);

        end

        function out=getSelectedTasks(obj)
            out=obj.selectedTasks;
        end

        function out=getConfigInfo(obj)
            out=obj.configInfo;
        end

        function out=getTaskID(obj)
            out=obj.TaskID;
        end

        function out=getparallelinfoFile(obj)
            out=obj.parallelinfoFile;
        end

        function out=getSystemInfo(obj)
            out=obj.systemInfo;
        end

        function out=getCleared(obj)
            out=obj.clearedFlag;
        end

        function setCleared(obj,val)
            obj.clearedFlag=val;
        end

    end
end