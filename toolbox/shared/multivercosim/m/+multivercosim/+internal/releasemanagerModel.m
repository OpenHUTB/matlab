classdef releasemanagerModel<handle

    properties(Constant)
        publishReleaseListChannelSTM='/STM/ReleaseList';
    end


    methods

        function obj=releasemanagerModel()
        end


        function delete(~)

        end


        function update(obj,msg)
            action=msg.command;
            switch action
            case 'update test manager checkbox'
                try
                    Simulink.CoSimServiceUtils.updateReleaseCheckbox(msg.releaseName,msg.releaseChecked);
                    obj.notifyViewUpdateSucceeded(msg.view);
                catch exception
                    obj.popupErrorToGUI('updateCheckboxFailed',exception.message,msg.view);
                end
            case 'update release name'
                try
                    Simulink.CoSimServiceUtils.updateReleaseName(msg.releaseOldName,msg.releaseNewName);
                    obj.notifyViewUpdateSucceeded(msg.view);
                catch exception
                    obj.popupErrorToGUI('nameFailed',exception.message,msg.view,msg.releaseOldName);
                end
            case 'update release path'
                try
                    Simulink.CoSimServiceUtils.updateReleasePath(msg.releaseName,msg.releaseNewPath);
                    obj.notifyViewUpdateSucceeded(msg.view);
                catch exception
                    obj.popupErrorToGUI('pathFailed',exception.message,msg.view,msg.releaseName,msg.releaseOldPath);
                end
            case 'delete release'
                try
                    if strcmp(msg.releaseName,'Current')
                        obj.popupErrorToGUI('deleteFailed','The current release cannot be deleted.',msg.view);
                    else
                        Simulink.CoSimServiceUtils.unregisterMatlab(msg.releaseName);
                        obj.notifyViewUpdateSucceeded(msg.view);
                    end
                catch exception
                    obj.popupErrorToGUI('deleteFailed',exception.message,msg.view);
                end
            case 'add new release'
                try
                    releaseName=obj.defaultReleaseName();
                    Simulink.CoSimServiceUtils.registerMatlab(releaseName,msg.newReleasePath);
                    obj.notifyViewUpdateSucceeded(msg.view);
                catch exception
                    obj.popupErrorToGUI('newPathFailed',exception.message,msg.view);
                end
            case 'launch release'
                try
                    Simulink.CoSimServiceUtils.launchMatlab(msg.releaseName);
                    obj.notifyViewUpdateSucceeded(msg.view);
                catch exception
                    obj.popupErrorToGUI('launchFailed',exception.message,msg.view);
                end
            case 'stop all release'
                try
                    Simulink.CoSimServiceUtils.stopMatlab(msg.releaseName);
                    obj.notifyViewUpdateSucceeded(msg.view);
                catch exception
                    obj.popupErrorToGUI('stopFailed',exception.message,msg.view);
                end
            otherwise
            end
        end



        function initializeView(~,viewChannel)
            initialList=Simulink.CoSimServiceUtils.listInstalledMatlabs;
            msg=struct('command','initialize release manager','initialReleaseList',initialList);
            message.publish(viewChannel,msg);
        end



        function notifyViewUpdateSucceeded(~,view)
            operationMessage=struct('command','update succeeded');
            message.publish(view,operationMessage);
            multivercosim.internal.releasemanagerModel.updateView(view);
        end


        function popupErrorToGUI(~,actionID,errorMessage,view,varargin)

            switch actionID
            case 'nameFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage,'errorName',varargin{1},'errorPath',''));
            case 'pathFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage,'errorName',varargin{1},'errorPath',varargin{2}));
            case 'newPathFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage));
            case 'deleteFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage));
            case 'updateCheckboxFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage));
            case 'launchFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage));
            case 'stopFailed'
                ReleaseManagerMSG=struct('command','error popup',...
                'error',struct('type',actionID,'message',errorMessage));
            otherwise
                return
            end
            message.publish(view,ReleaseManagerMSG);

            multivercosim.internal.releasemanagerModel.updateView(view);
        end



        function defaultName=defaultReleaseName(~)
            matlabs=Simulink.CoSimServiceUtils.listInstalledMatlabs;
            names={matlabs.MatlabRelease};
            index=1;
            newName=strcat('matlab',num2str(index));
            while find(strcmp(names,newName))
                index=index+1;
                newName=strcat('matlab',num2str(index));
            end
            defaultName=newName;
        end

    end

    methods(Static)
        function releaseManagerModel=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=multivercosim.internal.releasemanagerModel();
            end
            releaseManagerModel=localObj;
        end

        function updateView(channel)
            installedList=Simulink.CoSimServiceUtils.listInstalledMatlabs;
            msg=struct('command','update view','list',installedList);
            message.publish(channel,msg)
        end

        function updateMdlRefDialog()

            dlgs=DAStudio.ToolRoot.getOpenDialogs;
            for i=1:length(dlgs)
                if strcmp(dlgs(i).dialogTag,'ModelReference')
                    dlgs(i).refresh;
                end
            end
        end


    end
end
