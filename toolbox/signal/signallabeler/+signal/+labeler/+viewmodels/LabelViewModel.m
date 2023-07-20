

classdef LabelViewModel<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
        SignalLabelerActiveAppFlag=false;
    end

    properties(Constant)
        ObjID='LabelViewModel';
    end


    methods(Static)
        function ret=getViewModel()

            persistent viewModelObj;
            mlock;
            if isempty(viewModelObj)||~isvalid(viewModelObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                viewModelObj=signal.labeler.viewmodels.LabelViewModel(dispatcherObj,modelObj);
            end

            ret=viewModelObj;


            signal.labeler.viewmodels.ViewModelFeatureExtractionMode.getViewModel();
        end
    end



    methods(Hidden)
        function setSignalLabelerActiveAppFlag(this,value)
            this.SignalLabelerActiveAppFlag=value;
        end
        function value=getSignalLabelerActiveAppFlag(this)
            value=this.SignalLabelerActiveAppFlag;
        end

        function this=LabelViewModel(dispatcherObj,model)



            this.Dispatcher=dispatcherObj;
            this.Model=model;
            import signal.labeler.viewmodels.LabelViewModel;

            addlistener(signal.labeler.controllers.LabelDefinitionController.getController(),'CreateLabelDefsComplete',@(src,evt)this.cb_CreateLabelDefsComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelDefinitionController.getController(),'UpdateLabelDefsComplete',@(src,evt)this.cb_UpdateLabelDefsComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelDefinitionController.getController(),'DeleteLabelDefsComplete',@(src,evt)this.cb_DeleteLabelDefsComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelDefinitionController.getController(),'GetlabelDataForToolstripComplete',@(src,evt)this.cb_GetlabelDataForToolstripComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelDefinitionController.getController(),'ClearAllLabelDefsComplete',@(src,evt)this.cb_ClearAllLabelDefsComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelDefinitionController.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.Import.getController(),'ImportLabelDefsComplete',@(src,evt)this.cb_ImportLabelDefsComplete(src,evt));
            addlistener(signal.labeler.controllers.Import.getController(),'ImportSignalComplete',@(src,evt)this.cb_ImportSignalComplete(src,evt));
            addlistener(signal.labeler.controllers.Import.getController(),'LazyLoadImportSignalComplete',@(src,evt)this.cb_LazyLoadImportSignalComplete(src,evt));
            addlistener(signal.labeler.controllers.Import.getController(),'SwitchAcitveApp',@(src,evt)this.cb_SwitchAcitveAppOnImport(src,evt));
            addlistener(signal.labeler.controllers.Import.getController(),'SignalDataForAutoLabelDialog',@(src,evt)this.cb_SignalDataForAutoLabelDialog(src,evt));
            addlistener(signal.labeler.controllers.Import.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.Export.getController(),'ExportLabelDefComplete',@(src,evt)this.cb_ExportLabelDefComplete(src,evt));
            addlistener(signal.labeler.controllers.Export.getController(),'ExportLSSToWorkspaceComplete',@(src,evt)this.cb_ExportLSSToWorkspaceComplete(src,evt));
            addlistener(signal.labeler.controllers.Export.getController(),'ExportLabelDefinitionToWorkspaceComplete',@(src,evt)this.cb_ExportLabelDefinitionToWorkspaceComplete(src,evt));
            addlistener(signal.labeler.controllers.Export.getController(),'ExportLSSToFileComplete',@(src,evt)this.cb_ExportLSSToFileComplete(src,evt));
            addlistener(signal.labeler.controllers.Export.getController(),'BrowseFolderDialogRequestComplete',@(src,evt)this.cb_BrowseFolderDialogRequestComplete(src,evt));
            addlistener(signal.labeler.controllers.Export.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'MemberSignalDeleteComplete',@(src,evt)this.cb_MemberSignalDeleteComplete(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'ClearAllMembersComplete',@(src,evt)this.cb_ClearAllMembersComplete(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'CheckOrUncheckSignalsComplete',@(src,evt)this.cb_CheckOrUncheckSignalsComplete(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'CheckOrUncheckLabelInstancesComplete',@(src,evt)this.cb_CheckOrUncheckLabelInstancesComplete(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'ContextMenuDataComplete',@(src,evt)this.cb_ContextMenuDataComplete(src,evt));
            addlistener(signal.labeler.controllers.SignalTableController.getController(),'ScrollToComplete',@(src,evt)this.cb_ScrollToComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'CreateLabelComplete',@(src,evt)this.cb_CreateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'UpdateLabelComplete',@(src,evt)this.cb_UpdateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'DeleteLabelComplete',@(src,evt)this.cb_DeleteLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'AnimateLabelComplete',@(src,evt)this.cb_AnimateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'SelectLabelComplete',@(src,evt)this.cb_SelectLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'WidgetPreshowComplete',@(src,evt)this.cb_WidgetPreshowComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'WidgetGetTableDataComplete',@(src,evt)this.cb_WidgetGetTableDataComplete(src,evt));
            addlistener(signal.labeler.controllers.LabelController.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.AutoLabeling.AutoLabeler.getController(),'AutoLabelComplete',@(src,evt)this.cb_AutoLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.AutoLabeling.AutoLabeler.getController(),'UndoAutoLabelComplete',@(src,evt)this.cb_UndoAutoLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.AutoLabeling.AutoLabeler.getController(),'UpdateLabelComplete',@(src,evt)this.cb_UpdateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.AutoLabeling.AutoLabeler.getController(),'DeleteLabelComplete',@(src,evt)this.cb_DeleteLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.AutoLabeling.AutoLabeler.getController(),'AutoLabelSettingsWidgetData',@(src,evt)this.cb_AutoLabelSettingsWidgetData(src,evt));
            addlistener(signal.labeler.controllers.AutoLabeling.AutoLabeler.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.ImportLabelerFunction.getController(),'ImportCustomLabelerFunction',@(src,evt)this.cb_ImportCustomLabelerFunction(src,evt));
            addlistener(signal.labeler.controllers.SaveLabelerFunction.getController(),'AddCustomLabelerFunction',@(src,evt)this.cb_AddCustomLabelerFunction(src,evt));
            addlistener(signal.labeler.controllers.ImportAutoLabelMode.getController(),'SignalDataForSignalSelectionDialog',@(src,evt)this.cb_SignalDataForSignalSelectionDialog(src,evt));
            addlistener(signal.labeler.controllers.ImportAutoLabelMode.getController(),'ImportSignalComplete',@(src,evt)this.cb_ImportSignalToAutoModeComplete(src,evt));
            addlistener(signal.labeler.controllers.ImportAutoLabelMode.getController(),'PlotSignalInAutoLabelMode',@(src,evt)this.cb_PlotSignalInAutoLabelMode(src,evt));
            addlistener(signal.labeler.controllers.ExportAutoLabelMode.getController(),'AutoLabelAccept',@(src,evt)this.cb_AutoLabelAccept(src,evt));
            addlistener(signal.labeler.controllers.ExportAutoLabelMode.getController(),'UpdateLabelComplete',@(src,evt)this.cb_UpdateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.ExportAutoLabelMode.getController(),'CloseComplete',@(src,evt)this.cb_CloseCompleteInAutoLabelMode(src,evt));
            addlistener(signal.labeler.controllers.SaveLabelerFunction.getController(),'AddCustomLabelerFunction',@(src,evt)this.cb_AddCustomLabelerFunction(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromWorkspace.getController(),'ImportSignalsFromWorkspaceComplete',@(src,evt)this.cb_ImportSignalsFromWorkspaceComplete(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromWorkspace.getController(),'ReadyToShowDialog',@(src,evt)this.cb_ReadyToShowDialog(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromWorkspace.getController(),'WSBSelectionChange',@(src,evt)this.cb_WSBSelectionChange(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromWorkspace.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.SessionsController.getController(),'NewSessionComplete',@(src,evt)this.cb_NewSessionComplete(src,evt));
            addlistener(signal.labeler.controllers.SessionsController.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'ImportSignalsFromFileComplete',@(src,evt)this.cb_ImportSignalsFromFileComplete(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'ReadyToShowDialog',@(src,evt)this.cb_ReadyToShowImportSignalsFromFileDialog(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'BrowseFolderDialogRequestComplete',@(src,evt)this.cb_BrowseFolderDialogRequestCompleteImportFromFile(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'LazyLoadFileDataFailed',@(src,evt)this.cb_LazyLoadFileDataFailed(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'LazyLoadFileDataUpdate',@(src,evt)this.cb_LazyLoadFileDataUpdate(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'LazyLoadFileDataComplete',@(src,evt)this.cb_LazyLoadFileDataComplete(src,evt));
            addlistener(signal.labeler.controllers.ImportSignalsFromFile.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.ImportFastLabelMode.getController(),'ImportFastLabelComplete',@(src,evt)this.cb_ImportFastLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.ImportFastLabelMode.getController(),'PlotSignalsForMemberComplete',@(src,evt)this.cb_PlotSignalsForMemberComplete(src,evt));
            addlistener(signal.labeler.controllers.ExportFastLabelMode.getController(),'CreateLabelComplete',@(src,evt)this.cb_CreateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.ExportFastLabelMode.getController(),'UpdateLabelComplete',@(src,evt)this.cb_UpdateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.ExportFastLabelMode.getController(),'DeleteLabelComplete',@(src,evt)this.cb_DeleteLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.ExportFastLabelMode.getController(),'CloseComplete',@(src,evt)this.cb_CloseCompleteInFastLabelMode(src,evt));
            addlistener(signal.labeler.controllers.FastLabel.FastLabelController.getController(),'CreateLabelComplete',@(src,evt)this.cb_CreateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.FastLabel.FastLabelController.getController(),'UpdateLabelComplete',@(src,evt)this.cb_UpdateLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.FastLabel.FastLabelController.getController(),'DeleteLabelComplete',@(src,evt)this.cb_DeleteLabelComplete(src,evt));
            addlistener(signal.labeler.controllers.FastLabel.FastLabelController.getController(),'DirtyStateChanged',@(src,evt)this.cb_DirtyStateChanged(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'PreShowComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'PlotSelectionChangeComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'AddPlotsComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'UpdatePlotComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'UpdatePlotsOnMemberSelectionChangedComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'DeletePlotsComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'OnLabelDefinitionsUncheckedComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));
            addlistener(signal.labeler.controllers.DashboardController.getController(),'DashboardCloseComplete',@(src,evt)this.cb_DashboardActionComplete(src,evt));

        end





        function helperCloseDialogOnOK(this,clientID)
            import Simulink.sdi.internal.controllers.ExportDialog;
            this.Dispatcher.publishToClient(clientID,ExportDialog.ControllerID,'closeDialog',[]);
        end





        function cb_CreateLabelDefsComplete(this,src,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'treeLabelDefData'

                if isempty(data.parent)

                    this.Dispatcher.publishToClient(clientID,...
                    'addLabelDialog','closeDialog',[]);
                else
                    this.Dispatcher.publishToClient(clientID,...
                    'addSubLabelDialog','closeDialog',[]);
                end

                this.cb_ImportLabelDefsComplete(src,args);
            case 'treeTableLabelDefData'

                signal.labeler.controllers.SignalTableController.getController().refreshTreeTableData();
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelDefData'
                data.messageID='addLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_UpdateLabelDefsComplete(this,src,args)%#ok<INUSL>
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'closeDialog'

                if isempty(data.parent)

                    this.Dispatcher.publishToClient(clientID,...
                    'addLabelDialog','closeDialog',[]);
                else
                    this.Dispatcher.publishToClient(clientID,...
                    'addSubLabelDialog','closeDialog',[]);
                end
            case 'treeLabelDefData'
                this.Dispatcher.publishToClient(clientID,...
                'labelerTreeWidget','updateLabelDefsComplete',...
                data);
            case 'treeTableLabelDefData'

                signal.labeler.controllers.SignalTableController.getController().refreshTreeTableData();
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelDefData'
                data.messageID='updateLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_DeleteLabelDefsComplete(this,src,args)%#ok<INUSL>
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'treeLabelDefData'
                this.Dispatcher.publishToClient(clientID,...
                'labelerTreeWidget','deleteLabelDefsComplete',...
                data);
            case 'treeTableLabelDefData'
                signal.labeler.controllers.SignalTableController.getController().handleTreeTableRowChanged(data,"delete");
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelDefData'
                data.messageID='deleteLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function helperUpdateToolstripOnAutoLabelComplete(this,~,data)
            msgData=struct;
            objectID='labelerToolstripContentPane';
            if strcmp(this.Model.getAppName(),'autoLabelMode')
                objectID='autoLabelModeToolstripContentPane';
            end
            msgData.objectID=objectID;
            msgData.messageID='updateToolstripOnAutoLabelComplete';
            msgData.data=data;

            message.publish('/sdi/tableApplication',msgData);
        end

        function cb_GetlabelDataForToolstripComplete(this,~,args)
            args.Data.objectID='labelerToolstripContentPane';
            if strcmp(this.Model.getAppName(),'fastLabelMode')
                args.Data.objectID='fastLabelModeToolstripContentPane';
            end
            args.Data.messageID='updateLabelData';

            message.publish('/sdi/tableApplication',args.Data);
        end

        function cb_ClearAllLabelDefsComplete(this,src,args)%#ok<INUSL>
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'treeLabelDefData'

                this.Dispatcher.publishToClient(clientID,...
                'labelerTreeWidget','clearAllLabelDefsComplete',struct);
            case 'treeTableLabelDefData'

                this.Dispatcher.publishToClient(clientID,...
                'labelerSignalTreeTableWidget','deleteLabelComplete',...
                args.Data.data);
                signal.labeler.controllers.SignalTableController.getController().handleTreeTableRowChanged(args.Data.data,"delete");
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelDefData'

                data=struct('clientID',clientID,'data',struct,'messageID','clearAllLabelDef');
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_ImportLabelDefsComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case{'treeLabelDefData'}


                this.Dispatcher.publishToClient(clientID,...
                'labelerTreeWidget','createLabelDefsComplete',...
                data);
            case{'treeTableLabelDefData'}

                this.Dispatcher.publishToClient(clientID,...
                'labelerSignalTreeTableWidget','addLabelComplete',...
                data);
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case{'axesLabelDefData'}
                data.messageID='addLabelDef';
                message.publish('/sdi2/processLabelDataForAxes',data);

            end
        end

        function cb_ImportSignalComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;

            this.Dispatcher.publishToClient(clientID,...
            'labelerSignalTreeTableWidget','importSignalsComplete',...
            data);
            this.Dispatcher.publishToClient(clientID,...
            'labelSignalsWidgetDialog','importSignalsComplete',...
            data);
            signal.labeler.controllers.SignalTableController.getController().handleMemberSignalsChanged(clientID);
        end

        function cb_LazyLoadImportSignalComplete(~,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            if args.Data.isPlotSignalAfterLazyLoadComplete
                signal.labeler.controllers.SignalTableController.getController().lazyLoadingDataCompleteAfterCheck(clientID,data.parentIDs);
            end
        end

        function cb_ExportLabelDefComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            this.Dispatcher.publishToClient(clientID,...
            'exportLabelDefToFileDialog',messageID,...
            data);
        end

        function cb_ExportLSSToWorkspaceComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            this.Dispatcher.publishToClient(clientID,...
            'exportLSSToWSDialog',messageID,...
            data);
        end

        function cb_ExportLabelDefinitionToWorkspaceComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            this.Dispatcher.publishToClient(clientID,...
            'exportLabelDefToWSDialog',messageID,...
            data);
        end

        function cb_ExportLSSToFileComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            this.Dispatcher.publishToClient(clientID,...
            'exportLSSToFileDialog',messageID,...
            data);
        end


        function cb_BrowseFolderDialogRequestComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            this.Dispatcher.publishToClient(clientID,...
            'exportLSSToFileDialog',messageID,...
            data);
        end

        function cb_MemberSignalDeleteComplete(this,~,args)
            messageID=args.Data.messageID;
            switch messageID
            case 'treeTableData'


                this.Dispatcher.publishToClient(args.Data.clientID,...
                'labelerSignalTreeTableWidget','memberSignalDeleteComplete',args.Data.data);
            case 'labelSignalsWidgetData'

                this.Dispatcher.publishToClient(args.Data.clientID,...
                'labelSignalsWidgetDialog','memberSignalDeleteComplete',...
                args.Data.data);
            case 'SignalDataForAutoLabelDialog'

                this.Dispatcher.publishToClient(args.Data.clientID,...
                'autoLabelSignalsWidget','memberSignalDeleteComplete',...
                args.Data.data);
            case 'updateMultipleSignalsInPlot'

                args.Data.clientID=str2double(args.Data.clientID);
                args.Data.clearPlot=args.Data.data;
                args.Data.data=[];
                message.publish('/sdi/tableApplication',args.Data);
            end
        end

        function cb_ClearAllMembersComplete(this,~,args)

            this.Dispatcher.publishToClient(args.Data.clientID,...
            'labelerSignalTreeTableWidget','clearAllMembersComplete',struct);
            signal.labeler.controllers.SignalTableController.getController().handleMemberSignalsChanged(args.Data.clientID);

            this.Dispatcher.publishToClient(args.Data.clientID,...
            'labelSignalsWidgetDialog','clearAllMembersComplete',struct);

            this.Dispatcher.publishToClient(args.Data.clientID,...
            'autoLabelSignalsWidget','clearAllMembersComplete',...
            struct);


            args.Data.clientID=str2double(args.Data.clientID);
            message.publish('/sdi/tableApplication',args.Data);
        end

        function cb_CheckOrUncheckSignalsComplete(this,~,args)
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
            case 'signalColorChange'

                args.Data.clientID=str2double(args.Data.clientID);
                args.Data.clearPlot=[];
                args.Data.messageID='updateMultipleSignalsInPlot';
                args.Data.operation='signalColorChange';
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

        function cb_CheckOrUncheckLabelInstancesComplete(this,~,args)
            messageID=args.Data.messageID;
            switch messageID
            case 'removeSelectionOnCheckUncheck'
                signal.labeler.controllers.LabelController.getController().handleRemoveSelectionOnCheckUncheck(args.Data.clientID);
            case 'signalTreeTableData'

                this.Dispatcher.publishToClient(args.Data.clientID,...
                'labelerSignalTreeTableWidget','updateCheckStatusInTreeTableComplete',...
                args.Data.data);
            case 'labelTimeAxesLabelData'
                data=args.Data.data;
                data.messageID='updateLabelvisibilityLabelTimeAxes';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_ContextMenuDataComplete(this,~,args)

            this.Dispatcher.publishToClient(args.Data.clientID,...
            'labelerSignalTreeTableWidget','contextMenuDataComplete',...
            args.Data.data);
        end

        function cb_ScrollToComplete(this,~,args)

            this.Dispatcher.publishToClient(args.Data.clientID,...
            'labelerSignalTreeTableWidget','scrollToComplete',...
            args.Data.data);
        end

        function cb_AutoLabelComplete(this,src,args)
            messageID=args.Data.messageID;
            switch messageID
            case 'hideSpinner'
                clientID=args.Data.clientID;
                this.Dispatcher.publishToClient(clientID,...
                'autoLabelSignalsWidget','hideSpinner',args.Data.data);
            case 'autoLabelFailed'
                clientID=args.Data.clientID;
                this.Dispatcher.publishToClient(clientID,...
                'autoLabelSignalsWidget','autoLabelFailed',args.Data.errorID);
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'autoLabelWarning'
                clientID=args.Data.clientID;
                this.Dispatcher.publishToClient(clientID,...
                'autoLabelSignalsWidget','autoLabelWarning',args.Data.errorID);
            case 'updateWidgetsOnAutoLabelComplete'
                this.helperUpdateToolstripOnAutoLabelComplete('',args.Data.data);
                if strcmp(this.Model.getAppName(),'autoLabelMode')

                    clientID=args.Data.clientID;
                    this.Dispatcher.publishToClient(clientID,...
                    'autoLabelModeSettingsWidget','updateWidgetState',...
                    args.Data.data);
                end
            otherwise
                this.cb_CreateLabelComplete(src,args);
            end
        end

        function cb_UndoAutoLabelComplete(this,~,args)

            msgData=struct;
            msgData.objectID='labelerToolstripContentPane';
            msgData.messageID=args.Data.messageID;
            message.publish('/sdi/tableApplication',msgData);

            this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false,'bEnableRun',true));
            if strcmp(this.Model.getAppName(),'autoLabelMode')

                this.Dispatcher.publishToClient(args.Data.clientID,...
                'autoLabelModeSettingsWidget','updateWidgetState',...
                struct('bEnableRun',true));
            end
        end

        function cb_CreateLabelComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'closeDialog'
                this.Dispatcher.publishToClient(clientID,...
                'labelSignalsWidgetDialog','closeDialog',[]);
            case 'treeTableLabelData'

                signal.labeler.controllers.SignalTableController.getController().refreshTreeTableData();
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelData'
                data.messageID='addLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_UpdateLabelComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'closeDialog'
                this.Dispatcher.publishToClient(clientID,...
                'labelSignalsWidgetDialog','closeDialog',[]);
            case 'treeTableLabelData'

                this.Dispatcher.publishToClient(clientID,...
                'labelerSignalTreeTableWidget','updateLabelComplete',...
                data);
                signal.labeler.controllers.SignalTableController.getController().refreshTreeTableData();
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelData'
                data.messageID='updateLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_DeleteLabelComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch messageID
            case 'treeTableLabelData'

                signal.labeler.controllers.SignalTableController.getController().handleTreeTableRowChanged(data,'delete');
                this.Dispatcher.publishToClient(clientID,...
                'labelerSignalTreeTableWidget','deleteLabelComplete',struct);
                this.helperUpdateToolstripOnAutoLabelComplete('',struct('bEnableUndo',false));
            case 'axesLabelData'
                data.messageID='deleteLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_AutoLabelSettingsWidgetData(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            widgetName='autoLabelSignalsWidget';
            this.Dispatcher.publishToClient(clientID,...
            widgetName,'settingsWidgetsData',...
            data);
        end

        function cb_AnimateLabelComplete(~,~,args)
            data=args.Data.data;
            messageID=args.Data.messageID;
            switch messageID
            case 'axesLabelData'
                data.messageID='animateLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_SelectLabelComplete(~,~,args)
            data=args.Data.data;
            messageID=args.Data.messageID;
            switch messageID
            case 'axesLabelDataOnSelect'
                data.messageID='selectLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'axesLabelDataOnDeSelect'
                data.messageID='deSelectLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            end
        end

        function cb_WidgetPreshowComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            this.Dispatcher.publishToClient(clientID,...
            'labelSignalsWidgetDialog','showDialog',data);
        end

        function cb_WidgetGetTableDataComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            this.Dispatcher.publishToClient(clientID,...
            'labelSignalsWidgetDialog','addTableData',data);
        end

        function cb_SwitchAcitveAppOnImport(this,~,args)
            clientID=args.Data.clientID;
            this.Dispatcher.publishToClient(clientID,...
            'appViewController','showLabelView',[]);


            this.SignalLabelerActiveAppFlag=true;
        end

        function cb_SignalDataForAutoLabelDialog(this,~,args)
            data=args.Data.data;
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;

            this.Dispatcher.publishToClient(clientID,...
            'autoLabelSignalsWidget',messageID,...
            data);
        end

        function cb_ImportCustomLabelerFunction(this,src,args)
            this.cb_AddCustomLabelerFunction(src,args);
        end

        function cb_AddCustomLabelerFunction(~,~,args)
            args.Data.objectID='labelerToolstripContentPane';
            args.Data.messageID='updateFunctionsInGallery';

            message.publish('/sdi/tableApplication',args.Data);
        end

        function cb_SignalDataForSignalSelectionDialog(this,~,args)
            data=args.Data.data;
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;

            this.Dispatcher.publishToClient(clientID,...
            'autoLabelModeSignalSelectionWidget',messageID,...
            data);
        end

        function cb_ImportSignalToAutoModeComplete(this,~,args)
            data=args.Data.data;
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            switch messageID
            case 'showAutoLabelMode'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController',messageID,...
                data);
            end
        end

        function cb_PlotSignalInAutoLabelMode(this,~,args)
            messageID=args.Data.messageID;
            switch messageID
            case{'axesLabelData'}
                data=args.Data.data;
                data.messageID='addLabel';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'importMultipleSignalsInPlot'
                message.publish('/sdi/tableApplication',args.Data);
            case 'hideSpinner'
                clientID=args.Data.clientID;
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','hideSpinner',...
                args.Data.data);
            end
        end

        function cb_AutoLabelAccept(this,src,args)
            messageID=args.Data.messageID;
            switch messageID
            case 'updateWidgetsOnAutoLabelAccept'
                this.helperUpdateToolstripOnAutoLabelComplete('',args.Data.data);
            otherwise
                this.cb_CreateLabelComplete(src,args);
            end
        end

        function cb_CloseCompleteInAutoLabelMode(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch(messageID)
            case 'clearandswitchview'

                this.Dispatcher.publishToClient(clientID,...
                'appViewController','showLabelView',...
                data);
            end
        end

        function cb_CloseCompleteInFastLabelMode(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            switch(messageID)
            case 'clearFastLabelMode'

                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeTreeController','closeComplete',...
                data);
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeSignalTreeTableController','closeComplete',...
                data);
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeSignalSelectionWidget','closeComplete',...
                data);
            case 'closeFastLabelMode'

                this.Dispatcher.publishToClient(clientID,...
                'appViewController','showLabelView',...
                data);
            case 'resetDisplay'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','resetDisplay',...
                data);
            end
        end

        function cb_ImportSignalsFromWorkspaceComplete(this,~,args)
            clientID=args.Data.clientID;
            data=args.Data.data;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromWorkspaceWidget','importComplete',data);
        end

        function cb_ReadyToShowDialog(this,~,args)
            clientID=args.Data.clientID;
            data=args.Data.data;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromWorkspaceWidget','readyToShowDialog',data);
        end

        function cb_ImportSignalsFromFileComplete(this,~,args)
            clientID=args.Data.clientID;
            data=args.Data.data;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromFileWidget','importComplete',data);
        end

        function cb_ReadyToShowImportSignalsFromFileDialog(this,~,args)
            clientID=args.Data.clientID;
            data=args.Data.data;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromFileWidget','readyToShowDialog',data);
        end

        function cb_BrowseFolderDialogRequestCompleteImportFromFile(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromFileWidget',messageID,...
            data);
        end

        function cb_LazyLoadFileDataFailed(this,~,args)
            data=args.Data;
            clientID=args.Data.clientID;
            this.Dispatcher.publishToClient(clientID,...
            'appViewController','hideSpinner',...
            struct);
            if strcmp(this.Model.AppDataMode,'audioFile')
                this.Dispatcher.publishToClient(clientID,...
                'importAudioFilesController','lazyLoadFileDataFailed',...
                data);
            else
                this.Dispatcher.publishToClient(clientID,...
                'importSignalsFromFileWidget','lazyLoadFileDataFailed',...
                data);
            end
        end

        function cb_LazyLoadFileDataUpdate(this,~,args)
            data=args.Data;
            clientID=args.Data.clientID;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromFileWidget','lazyLoadFileDataUpdate',...
            data);
        end

        function cb_LazyLoadFileDataComplete(~,~,args)
            args.Data.objectID='labelerToolstripContentPane';
            message.publish('/sdi/tableApplication',args.Data);

            signal.labeler.controllers.SignalTableController.getController().refreshTreeTableData();
        end

        function cb_WSBSelectionChange(this,~,args)
            clientID=args.Data.clientID;
            data=args.Data.data;
            this.Dispatcher.publishToClient(clientID,...
            'importSignalsFromWorkspaceWidget','wsbSelectionChange',data);
        end

        function cb_NewSessionComplete(this,~,args)

            args.Data.messageID='treeLabelDefData';
            this.cb_ClearAllLabelDefsComplete([],args);

            args.Data.messageID='clearPlot';
            this.cb_ClearAllMembersComplete([],args);
        end

        function cb_DirtyStateChanged(this,~,args)



            args.Data.messageID='dirtyStateChanged';
            args.Data.dirtyStatus=this.Model.isDirty();
            message.publish('/sdi/tableApplication',args.Data);
        end

        function cb_ImportFastLabelComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            data=args.Data.data;
            switch messageID
            case 'hideSpinner'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','hideSpinner',data);
            case 'showFastLabelMode'
                this.Dispatcher.publishToClient(clientID,...
                'appViewController','showFastLabelMode',data);
            case 'importLabelDefinitions'
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeTreeController','importlabelDefsInFastLabelComplete',...
                data);
            case 'importMembers'
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeSignalTreeTableController','importMembersInFastLabelModeComplete',...
                data);
            case 'addMinNumOfSignals'
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeSignalSelectionWidget','addSignalsComplete',...
                data);
            case 'disableSelectionRadioButtons'
                msgData.objectID='fastLabelModeToolstripContentPane';
                msgData.messageID='disableSelectionRadioButtons';
                msgData.data=data;
                message.publish('/sdi/tableApplication',msgData);
            end
        end

        function cb_PlotSignalsForMemberComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            switch messageID
            case 'plotSignalsInDisplay'

                args.Data.clientID=str2double(clientID);
                args.Data.clearPlot=args.Data.signalIDsToBeCleared;
                args.Data.messageID='updateMultipleSignalsInPlot';
                message.publish('/sdi/tableApplication',args.Data);
            case 'labelViewerAxesLabelData'
                data=args.Data.data;
                data.messageID='updateLabelvisibilityLabelViewerAxes';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'labelTimeAxesLabelData'
                data=args.Data.data;
                data.messageID='updateLabelvisibilityLabelTimeAxes';
                message.publish('/sdi2/processLabelDataForAxes',data);
            case 'updatePlottedSignals'
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeSignalTreeTableController','updatePlottedSignals',...
                args.Data.data);
            case 'hideSpinner'
                this.Dispatcher.publishToClient(clientID,...
                'fastLabelModeSignalTreeTableController','hideSpinner',struct);
            case 'updateLegends'
                message.publish("/sdi2/updateLabels",args.Data.data);
            end
        end

        function cb_DashboardActionComplete(this,~,args)
            messageID=args.Data.messageID;
            clientID=args.Data.clientID;
            switch messageID
            case 'preShowComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardTabController',messageID,args.Data.data);
            case 'plotSelectionChangeComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardTabController',messageID,args.Data.data);
            case 'addPlotsComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardGraphController',messageID,args.Data.data);
            case 'updatePlotComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardGraphController',messageID,args.Data.data);
            case 'updatePlotsOnMemberSelectionChangedComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardGraphController',messageID,args.Data.data);
            case 'deletePlotsComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardGraphController',messageID,args.Data.data);
            case 'onLabelDefinitionsUncheckedComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardGraphController',messageID,args.Data.data);
            case 'dashboardCloseComplete'
                this.Dispatcher.publishToClient(clientID,'dashboardGraphController',messageID,args.Data.data);
                this.Dispatcher.publishToClient(clientID,'appViewController',messageID,args.Data.data);
            end
        end

    end
end
