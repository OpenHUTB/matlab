classdef checkRestorePoint<handle




    methods
        function obj=checkRestorePoint()
        end
    end

    methods(Static)
        function reportObject=runFailSafe(topModel)



            if(DataTypeWorkflow.Advisor.checkRestorePoint.hasValidRestorePoint(topModel))
                reportObject=DataTypeWorkflow.Advisor.checkRestorePoint.getPassWithoutChangeStatus(topModel);
            else
                reportObject=DataTypeWorkflow.Advisor.checkRestorePoint.run(topModel);
            end

        end

        function reportObject=run(topModel)










            try
                status=DataTypeWorkflow.Converter.createRestorePoint(topModel,false);
            catch err
                status=DataTypeWorkflow.RestorePointStatus;
                status.Status=0;
                status.Rationale=err;
            end

            reportObject=DataTypeWorkflow.Advisor.checkRestorePoint.processStatus(status,topModel);
        end
        function reportObject=processStatus(status,topModel)



            reportObject={};
            if status.Status
                reportObject=DataTypeWorkflow.Advisor.checkRestorePoint.getPassWithChangeStatus(topModel);
            else
                if~isempty(status.DirtyFiles)
                    reportObject=[reportObject;DataTypeWorkflow.Advisor.checkRestorePoint.processDirtyFiles(status.DirtyFiles,topModel)];
                end
                if~isempty(status.MissingFiles)
                    reportObject=[reportObject;DataTypeWorkflow.Advisor.checkRestorePoint.processMissingFiles(status.MissingFiles,topModel)];
                end
                if~isempty(status.Rationale)
                    reportObject{end+1}=DataTypeWorkflow.Advisor.checkRestorePoint.processError(status.Rationale,topModel);
                end


                if isempty(reportObject)
                    reportObject{1}=DataTypeWorkflow.Advisor.checkRestorePoint.getGenericWarnMessage(topModel);
                end
            end
        end
        function reportObject=getPassWithoutChangeStatus(topModel)
            checkResultEntry=DataTypeWorkflow.Advisor.CheckResultEntry(topModel);
            reportObject{1}=checkResultEntry.setPassWithoutChange();
        end
        function reportObject=getPassWithChangeStatus(topModel)
            checkResultEntry=DataTypeWorkflow.Advisor.CheckResultEntry(topModel);
            reportObject{1}=checkResultEntry.setPassWithChange(topModel,topModel);
        end
        function checkResultEntries=processDirtyFiles(dirtyFiles,topModel)

            checkResultEntries=DataTypeWorkflow.Advisor.checkRestorePoint.getFileList(dirtyFiles,'RestorePointFilesWarnWithoutChangeHeader',topModel,false);
        end
        function checkResultEntries=processMissingFiles(missingFiles,topModel)

            checkResultEntries=DataTypeWorkflow.Advisor.checkRestorePoint.getFileList(missingFiles,'RestorePointFilesFailWithoutChangeHeader',topModel,true);
        end
        function checkResultEntry=processError(errorException,topModel)

            checkResultEntry=DataTypeWorkflow.Advisor.CheckResultEntry(topModel);
            checkResultEntry=checkResultEntry.setFailWithoutChange(topModel,...
            DataTypeWorkflow.Advisor.internal.CauseRationale(errorException,'RestorePointExceptionFailWithoutChangeHeader'));
        end
        function checkResultEntry=getGenericWarnMessage(topModel)

            checkResultEntry=DataTypeWorkflow.Advisor.CheckResultEntry(topModel);
            checkResultEntry=checkResultEntry.setWarnWithoutChange(topModel,...
            DataTypeWorkflow.Advisor.internal.CauseRationale([],'RestorePointWarnWithoutChangeHeader'));
        end
        function checkList=getFileList(files,header,topModel,isFailStatus)

            checkList=cell(numel(files),1);
            for idx=1:numel(files)
                checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(topModel);
                if isFailStatus
                    checkList{idx}=checkEntry.setFailWithoutChange(files{idx},...
                    DataTypeWorkflow.Advisor.internal.CauseRationale([],header));
                else
                    checkList{idx}=checkEntry.setWarnWithoutChange(files{idx},...
                    DataTypeWorkflow.Advisor.internal.CauseRationale([],header));
                end
            end
        end
        function isValidRestorePoint=hasValidRestorePoint(topModel)
            isValidRestorePoint=false;

            dataLayer=fxptds.DataLayerInterface.getInstance();
            facade=dataLayer.getWorkflowTopologyFacade(topModel);

            report=facade.query(topModel,'type','Prepare','property','Results','limit',1);
            report=report{1};
            if~isempty(report)&&...
                ~isempty(report.RestorePoint)&&...
                numel(report.RestorePoint{1})==1&&...
                (isequal(report.RestorePoint{1}.Status,DataTypeWorkflow.Advisor.CheckStatus.PassWithChange)||...
                isequal(report.RestorePoint{1}.Status,DataTypeWorkflow.Advisor.CheckStatus.PassWithoutChange))&&...
                DataTypeWorkflow.Converter.hasValidRestorePoint(topModel)
                isValidRestorePoint=true;
            end
        end
    end
end


