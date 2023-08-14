

classdef ExportFeatureExtractionMode<handle




    properties(Hidden)
        Model;
        Engine;
    end

    properties(Access=protected)
        Dispatcher;

    end

    properties(Constant)
        ControllerID='ExportFeatureExtractionMode';
    end

    events
FeatureExtractionModeCloseComplete
InitExportFeatureTableComplete
ExportFeatureToWorkSpaceComplete
ExportToClassificationLearnerComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=ExportFeatureExtractionMode(dispatcherObj,modelObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode;

            this.Dispatcher.subscribe(...
            [ExportFeatureExtractionMode.ControllerID,'/','cancel'],...
            @(arg)cb_Cancel(this,arg));

            this.Dispatcher.subscribe(...
            [ExportFeatureExtractionMode.ControllerID,'/','accept'],...
            @(arg)cb_Accept(this,arg));

            this.Dispatcher.subscribe(...
            [ExportFeatureExtractionMode.ControllerID,'/','initexportfeaturetable'],...
            @(arg)cb_InitExportFeatureTable(this,arg));

            this.Dispatcher.subscribe(...
            [ExportFeatureExtractionMode.ControllerID,'/','exportfeaturetoworkspace'],...
            @(arg)cb_ExportFeatureToWorkSpace(this,arg));

            this.Dispatcher.subscribe(...
            [ExportFeatureExtractionMode.ControllerID,'/','exporttoclassificationlearner'],...
            @(arg)cb_ExportToClassificationLearner(this,arg));

            this.Dispatcher.subscribe(...
            [ExportFeatureExtractionMode.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)




        function cb_HelpButton(~,args)

            data=args.data;
            signal.labeler.controllers.SignalLabelerHelp(data.messageID);
        end

        function cb_Cancel(this,args)

            lblDefIDs=this.Model.getModeCreatedFeatureDefinitionIDs();
            data=struct("LabelDefinitionID","");
            for idx=1:numel(lblDefIDs)
                data.LabelDefinitionID=lblDefIDs(idx);
                this.Model.deleteLabelDefinitions(data);
            end
            outData.clientID=args.clientID;
            outData.messageID='clearModeView';
            outData.data=struct;
            this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(outData));

            this.Model.resetModel();
            this.Model.setAppName('labeler');

            outData.clientID=args.clientID;
            outData.messageID='switchview';
            outData.data=struct('hideSpinner',true);
            this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(outData));
        end

        function cb_Accept(this,args)
            this.Model.setAppName('labeler');
            data=args.data;
            clientID=num2str(data.signalLabelerClientID);
            lblDefIDs=this.Model.getModeCreatedFeatureDefinitionIDs();
            if~isempty(lblDefIDs)
                for idx=1:numel(lblDefIDs)
                    treeFeatureDefData=this.Model.getLabelDefinitionsDataForTree(lblDefIDs(idx));
                    this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                    'messageID','treeFeatureDefData',...
                    'data',treeFeatureDefData)));
                end

                this.Model.resetCheckedSignalIDsCallback();
                axesFeatureData=this.Model.getLabelDataForAxesForPlottedMembersInMainApp(lblDefIDs);
                for idx=1:numel(axesFeatureData)
                    dataPacket.clientID=clientID;
                    dataPacket.signalID=axesFeatureData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesFeatureData(idx);
                    this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                    'messageID','axesFeatureData','data',dataPacket)));
                end
                this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','treeTableFeatureData',...
                'data',struct)));
            end

            outData.clientID=args.clientID;
            outData.messageID='clearModeView';
            outData.data=struct;
            this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(outData));

            this.Model.resetModel();
            this.Model.setAppName('labeler');

            outData.clientID=args.clientID;
            outData.messageID='switchview';
            outData.data=struct('hideSpinner',true);
            this.notify('FeatureExtractionModeCloseComplete',signal.internal.SAEventData(outData));
        end

        function cb_InitExportFeatureTable(this,args)
            clientID=args.clientID;

            lblDefIDs=this.Model.getSupportedLabelDefinitionIDs(false);
            tableData=this.Model.getExportFeatureTableDataForLabelDefIDs(lblDefIDs);

            this.notify('InitExportFeatureTableComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','responseDefData',...
            'exportTarget',args.data.exportTarget,...
            'data',tableData)));

            lblDefIDs=this.Model.getModeCreatedFeatureDefinitionIDs();
            tableData=this.Model.getExportFeatureTableDataForLabelDefIDs(lblDefIDs);
            this.notify('InitExportFeatureTableComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','featureDefData',...
            'exportTarget',args.data.exportTarget,...
            'data',tableData)));

            this.notify('InitExportFeatureTableComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','showDialog',...
            'exportTarget',args.data.exportTarget,...
            'data',args.data)));
        end

        function cb_ExportFeatureToWorkSpace(this,args)
            clientID=args.clientID;
            forceOverwriteVariable=false;
            if isfield(args.data,'forceOverwriteVariable')
                forceOverwriteVariable=args.data.forceOverwriteVariable;
            end
            exportCtrl=signal.labeler.controllers.Export.getController();
            varName=args.data.varName;
            if~forceOverwriteVariable
                if exportCtrl.isVariableExistInWorkspace(varName)
                    outData.clientID=args.clientID;
                    outData.messageID='showOverWriteConfirmDialog';
                    outData.data=args.data;
                    this.notify('ExportFeatureToWorkSpaceComplete',signal.internal.SAEventData(outData));
                    return;
                end
            end
            isOutputFormatTable=args.data.OutputFormat=="table";
            responses=string(args.data.featureData.Responses);
            numResponses=numel(responses);
            if~isOutputFormatTable&&numResponses>0
                responseVarName=varName+"response";
                idx=1;
                while exportCtrl.isVariableExistInWorkspace(responseVarName)
                    responseVarName=varName+"response"+idx;
                    idx=idx+1;
                end
            end

            lss=exportCtrl.createLabeledSignalSetFromLabeler(this.Model.getLabelerModel().getMemberIDsForExport(),'');
            try
                nameValuePairCellArray={'OutputFormat',args.data.OutputFormat};
                nameValuePairCellArray{end+1}='ExpandResponseLabels';
                nameValuePairCellArray{end+1}=true;
                nameValuePairCellArray{end+1}='Features';
                nameValuePairCellArray{end+1}=string(args.data.featureData.Features);
                if numResponses>0
                    nameValuePairCellArray{end+1}='Responses';
                    nameValuePairCellArray{end+1}=responses;
                    [FTDATA,RESPDATA]=lss.createFeatureData(nameValuePairCellArray{:});
                    if args.data.OutputFormat=="table"
                        exportedFeatureData=horzcat(FTDATA,RESPDATA);
                    end
                else
                    exportedFeatureData=lss.createFeatureData(nameValuePairCellArray{:});
                end
            catch ex
                this.notify('ExportFeatureToWorkSpaceComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','error','data',ex)));
                return;
            end
            if isOutputFormatTable||numResponses==0
                exportCtrl.addVariableInWorkspace(varName,exportedFeatureData);
            else
                exportCtrl.addVariableInWorkspace(varName,FTDATA);
                exportCtrl.addVariableInWorkspace(responseVarName,RESPDATA);
            end
            this.notify('ExportFeatureToWorkSpaceComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','closeDialog','data',struct)));
        end

        function cb_ExportToClassificationLearner(this,args)
            clientID=args.clientID;
            responses=string(args.data.Responses);
            numResponses=numel(responses);
            exportCtrl=signal.labeler.controllers.Export.getController();
            lss=exportCtrl.createLabeledSignalSetFromLabeler(this.Model.getLabelerModel().getMemberIDsForExport(),'');
            try
                nameValuePairCellArray={'OutputFormat','table'};
                nameValuePairCellArray{end+1}='ExpandResponseLabels';
                nameValuePairCellArray{end+1}=true;
                nameValuePairCellArray{end+1}='Features';
                nameValuePairCellArray{end+1}=string(args.data.Features);
                if numResponses>0
                    nameValuePairCellArray{end+1}='Responses';
                    nameValuePairCellArray{end+1}=responses;
                    [FTDATA,RESPDATA]=lss.createFeatureData(nameValuePairCellArray{:});
                    exportedFeatureData=horzcat(FTDATA,RESPDATA);
                else
                    exportedFeatureData=lss.createFeatureData(nameValuePairCellArray{:});
                end
            catch ex
                this.notify('ExportToClassificationLearnerComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','error','data',ex)));
                return;
            end
            this.launchClassificationLearner(exportedFeatureData);
            this.notify('ExportToClassificationLearnerComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','closeDialog','data',struct)));
        end

        function launchClassificationLearner(~,exportedFeatureData)
            mlearnapp.internal.launchSeparateClassificationApp(...
            'signalLabeler',...
            message('SDI:labeler:classificationLearnerTitle'),...
            exportedFeatureData,'ft');
        end
    end
end
