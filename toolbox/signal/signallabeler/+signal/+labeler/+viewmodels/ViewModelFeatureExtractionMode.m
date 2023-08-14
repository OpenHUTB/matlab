

classdef ViewModelFeatureExtractionMode<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ObjID='ViewModelFeatureExtractionMode';
    end


    methods(Static)
        function ret=getViewModel()

            persistent viewModelObj;
            mlock;
            if isempty(viewModelObj)||~isvalid(viewModelObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository.getModel();
                viewModelObj=signal.labeler.viewmodels.ViewModelFeatureExtractionMode(dispatcherObj,modelObj);
            end

            ret=viewModelObj;
        end
    end



    methods(Hidden)

        function this=ViewModelFeatureExtractionMode(dispatcherObj,model)



            this.Dispatcher=dispatcherObj;
            this.Model=model;
            import signal.labeler.viewmodels.ViewModelFeatureExtractionMode;

            addlistener(signal.labeler.controllers.FeatureExtraction.ImportFeatureExtractionMode.getController(),'ImportFeatureExtractionComplete',@(src,evt)this.cb_ImportFeatureExtractionComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode.getController(),'FeatureExtractionModeCloseComplete',@(src,evt)this.cb_FeatureExtractionModeCloseComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode.getController(),'InitExportFeatureTableComplete',@(src,evt)this.cb_InitExportFeatureTableComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode.getController(),'ExportFeatureToWorkSpaceComplete',@(src,evt)this.cb_ExportFeatureToWorkSpaceComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.ExportFeatureExtractionMode.getController(),'ExportToClassificationLearnerComplete',@(src,evt)this.cb_ExportToClassificationLearnerComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.SignalTableControllerFeatureExtractionMode.getController(),'CheckUnCheckSignalComplete',@(src,evt)this.cb_CheckUnCheckSignalComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.FeatureExtractor.getController(),'ShowFeatureExtractionDialogComplete',@(src,evt)this.cb_ShowFeatureExtractionDialogComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.FeatureExtractor.getController(),'FeatureExtractionComplete',@(src,evt)this.cb_FeatureExtractionComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode.getController(),'GetlabelDataForToolstripComplete',@(src,evt)this.cb_GetlabelDataForToolstripComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode.getController(),'DeleteFeatureDefsComplete',@(src,evt)this.cb_DeleteFeatureDefsComplete(src,evt));
            addlistener(signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode.getController(),'UpdateFeatureDefsComplete',@(src,evt)this.cb_UpdateFeatureDefsComplete(src,evt));
        end




        function cb_ImportFeatureExtractionComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            switch messageID
            case 'hideSpinner'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','hideSpinner',data);
            case 'error'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','showFeatureExtractionModeError',data);
            case 'showFeatureExtractionMode'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','showFeatureExtractionMode',data);
            case 'importLabelDefinitions'
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeTreeWidget','importlabelDefsComplete',...
                data);
            case 'importMembers'
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeSignalTreeTableWidget','importMembersComplete',...
                data);
            case 'addMinNumOfSignals'
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeSignalSelectionWidget','addSignalsComplete',...
                data);
            case 'disableSelectionRadioButtons'
                msgData.objectID='featureExtractionModeToolstripContentPane';
                msgData.messageID='disableSelectionRadioButtons';
                msgData.data=data;
                message.publish('/sdi/tableApplication',msgData);
            case 'setSampleRate'
                msgData.objectID='featureExtractionModeToolstripContentPane';
                msgData.messageID='setSampleRate';
                msgData.data=data;
                message.publish('/sdi/tableApplication',msgData);
            end
        end

        function cb_FeatureExtractionModeCloseComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            switch messageID
            case 'hideSpinner'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','hideSpinner',data);
            case 'clearModeView'

                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeTreeWidget','closeComplete',...
                data);
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeSignalTreeTableWidget','closeComplete',...
                data);
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeSignalSelectionWidget','closeComplete',...
                data);
            case 'treeFeatureDefData'
                this.Dispatcher.publishToClient(clientID,...
                'labelerTreeWidget','createLabelDefsComplete',...
                data);
            case 'treeTableFeatureData'

                signal.labeler.controllers.SignalTableController.getController().refreshTreeTableData();



                msgData=struct;
                objectID='labelerToolstripContentPane';
                msgData.objectID=objectID;
                msgData.messageID='updateToolstripOnAutoLabelComplete';
                msgData.data=struct('bEnableUndo',false);
                message.publish('/sdi/tableApplication',msgData);
            case 'axesFeatureData'
                data.messageID='addLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'switchview'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','showLabelView',data);

            end
        end

        function cb_InitExportFeatureTableComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            dstWidget='exportFeatureTableWidget';
            if args.Data.exportTarget=="classificationLearner"
                dstWidget='exportFeatureToCLWidget';
            end
            this.Dispatcher.publishToClient(clientID,...
            dstWidget,messageID,...
            data);
        end

        function cb_ExportFeatureToWorkSpaceComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            switch messageID
            case{'showOverWriteConfirmDialog','closeDialog'}
                this.Dispatcher.publishToClient(clientID,...
                'exportFeatureToWSDialog',messageID,...
                data);
            otherwise
                this.Dispatcher.publishToClient(clientID,...
                'exportFeatureTableWidget',messageID,...
                data);
            end
        end

        function cb_ExportToClassificationLearnerComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            this.Dispatcher.publishToClient(clientID,...
            'exportFeatureToCLWidget',messageID,...
            data);
        end

        function cb_CheckUnCheckSignalComplete(this,~,args)
            messageID=args.Data.messageID;
            switch messageID
            case 'signalTreeTableData'

                this.Dispatcher.publishToClient(args.Data.clientID,...
                'labelerSignalTreeTableWidget','updateCheckStatusInTreeTableComplete',...
                args.Data.data);
            case 'plotMultipleSignalsInDisplay'

                args.Data.clientID=str2double(args.Data.clientID);
                args.Data.clearPlot=[];
                args.Data.messageID='updateMultipleSignalsInPlot';
                message.publish('/sdi/tableApplication',args.Data);
            case 'clearMultipleSignalsInDisplay'

                args.Data.clientID=str2double(args.Data.clientID);
                args.Data.clearPlot=args.Data.data;
                args.Data.messageID='updateMultipleSignalsInPlot';
                args.Data.data=[];
                message.publish('/sdi/tableApplication',args.Data);
            case 'labelViewerAxesLabelData'
                data=args.Data.data;
                data.messageID='updateLabelvisibilityLabelViewerAxes';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'axesLabelData'
                data=args.Data.data;
                data.messageID='updateLabelvisibility';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_ShowFeatureExtractionDialogComplete(this,~,args)
            this.Dispatcher.publishToClient(args.Data.clientID,...
            'featureExtractorDialogWidget','showFeatureExtractionDialogComplete',args.Data.data);
        end

        function cb_FeatureExtractionComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            switch messageID
            case 'treeFeatureDefData'
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeTreeWidget','createLabelDefsComplete',...
                data);
            case 'axesFeatureDefData'
                data.messageID='addLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'axesFeatureData'
                data.messageID='addLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'deleteFeatureDefs'
                signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode.getController().deleteFeatureDefinitions(args.Data);
            case{'featureDefCreateStatus','featureCreateStatus','error'}
                srcWidget=args.Data.srcWidget;
                this.Dispatcher.publishToClient(clientID,...
                srcWidget,messageID,...
                data);
            case 'toolstripData'
                args.Data.objectID='featureExtractionModeToolstripContentPane';
                args.Data.messageID='updateFeatureModeData';
                message.publish('/sdi/tableApplication',args.Data);

            end
        end

        function cb_GetlabelDataForToolstripComplete(~,~,args)
            args.Data.objectID='featureExtractionModeToolstripContentPane';
            args.Data.messageID='updateLabelData';
            message.publish('/sdi/tableApplication',args.Data);
        end

        function cb_UpdateFeatureDefsComplete(this,src,args)%#ok<INUSL>
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case{'closeDialog','error'}
                srcWidget=args.Data.srcWidget;

                this.Dispatcher.publishToClient(clientID,...
                srcWidget,messageID,data);
            case 'treeLabelDefData'
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeTreeWidget','updateLabelDefsComplete',...
                data);
            case 'axesLabelDefData'
                data.messageID='updateLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_DeleteFeatureDefsComplete(this,src,args)%#ok<INUSL>
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'treeLabelDefData'
                this.Dispatcher.publishToClient(clientID,...
                'featureExtractionModeTreeWidget','deleteLabelDefsComplete',...
                data);
            case 'axesLabelDefData'
                data.messageID='deleteLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end
    end
end
