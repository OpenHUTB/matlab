




classdef ModelRefAdvisorFactory<handle
    properties(Constant)
        AdvisorMainGroupId=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorMainGroupId');
        AdvisorInputParametersId=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorInputParametersId');
        AdvisorModelConfigurationsId=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorModelConfigurationsId');
        AdvisorSubsystemInterfaceId=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceId');
        AdvisorSubsystemContentId=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentId');
        AdvisorCompleteConversionId=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionId');

        TaskIds={DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorInputParametersId'),...
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorModelConfigurationsId'),...
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemInterfaceId'),...
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorSubsystemContentId'),...
        DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorCompleteConversionId')};
    end


    methods(Static,Access=public)
        function results=runCheck(~)
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;


            if isempty(mdladvObj.UserData.ModelRefAdvisor)
                subsys=mdladvObj.SystemHandle;
                mdladvObj.UserData.ModelRefAdvisor=Simulink.ModelReference.Conversion.ModelRefAdvisorData(mdladvObj,subsys);
            end


            data=mdladvObj.UserData.ModelRefAdvisor;
            checkObj=data.ModelRefCheckFactory;
            checkId=mdladvObj.getActiveCheck;
            results=checkObj.runCheck(checkId);
        end


        function results=runFix(~)
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            data=mdladvObj.UserData.ModelRefAdvisor;
            results=ModelAdvisor.Paragraph;
            if~isempty(data)
                results.setCollapsibleMode('none');
                lineBreak=ModelAdvisor.LineBreak;


                checkObj=data.ModelRefCheckFactory;
                checkObj.runFixes;
                results.addItem(ModelAdvisor.Text(DAStudio.message('Simulink:modelReferenceAdvisor:FixDescription'),{'bold','pass'}));
                results.addItem(lineBreak);
                results.addItem(Simulink.ModelReference.Conversion.MessageBeautifier.getHTMLTextFromMessages(checkObj.getFixResults));
                checkObj.clearCheckResults;
            end
        end


        function cleanup()
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if~isempty(mdladvObj)&&isfield(mdladvObj.UserData,'ModelRefAdvisor')
                data=mdladvObj.UserData.ModelRefAdvisor;
                if~isempty(data)
                    data.ModelRefCheckFactory.terminate;
                end
            end
        end


        function restore()
            isOK=questdlg(DAStudio.message('Simulink:modelReferenceAdvisor:RestoreDialogMessage'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:RestoreDialogTitle'));
            if strcmp(isOK,'Yes')
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                rpList=mdladvObj.getRestorePointList;
                backupName=rpList{end}.name;
                loadObj=Advisor.Utils.LoadRestorePointForMdlRefAdvisor(mdladvObj,backupName);
                loadObj.load;
            end
        end

        function updateRestorePointList(snapshots,snapshotdir,snapshotInfoMat)
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if isfield(mdladvObj.UserData,'ModelRefAdvisor')
                mdladvObj.UserData.ModelRefAdvisor.Snapshots=snapshots;
                mdladvObj.UserData.ModelRefAdvisor.SnapshotDir=snapshotdir;
                mdladvObj.UserData.ModelRefAdvisor.SnapshotInfoMat=snapshotInfoMat;
            end
        end

        function[snapshots,snapshotdir,snapshotInfoMat]=getRestorePointList()
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if isfield(mdladvObj.UserData,'ModelRefAdvisor')&&~isempty(mdladvObj.UserData.ModelRefAdvisor.Snapshots)
                snapshots=mdladvObj.UserData.ModelRefAdvisor.Snapshots;
                snapshotdir=mdladvObj.UserData.ModelRefAdvisor.SnapshotDir;
                snapshotInfoMat=mdladvObj.UserData.ModelRefAdvisor.SnapshotInfoMat;
            else
                [snapshots,snapshotdir,snapshotInfoMat]=mdladvObj.getRestorePointList;
            end
        end

        function reset(mdladvObj)
            taskObj=mdladvObj.getTaskObj(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorInputParametersId);
            taskObj.reset;
            rootNode=mdladvObj.getTaskObj(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId);
            rootNode.reset;


            if~isempty(mdladvObj.MAExplorer)
                imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
                imme.selectTreeViewNode(rootNode);
            end
        end
    end
end
