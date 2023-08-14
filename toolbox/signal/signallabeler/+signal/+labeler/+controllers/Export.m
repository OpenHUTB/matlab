

classdef Export<handle




    properties(Hidden)
        Model;
        Engine;
    end

    properties(Access=protected)
        Dispatcher;

    end

    properties(Constant)
        ControllerID='Export';
    end

    events
ExportLabelDefComplete
ExportLSSToWorkspaceComplete
ExportLabelDefinitionToWorkspaceComplete
ExportLSSToFileComplete
BrowseFolderDialogRequestComplete
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.Export(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=Export(dispatcherObj,modelObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.Export;

            this.Dispatcher.subscribe(...
            [Export.ControllerID,'/','exportlsstoworkspace'],...
            @(arg)cb_ExportLSSToWorkspace(this,arg));

            this.Dispatcher.subscribe(...
            [Export.ControllerID,'/','exportlabeldefinitiontoworkspace'],...
            @(arg)cb_ExportLabelDefinitionToWorkspace(this,arg));

            this.Dispatcher.subscribe(...
            [Export.ControllerID,'/','exportlsstofile'],...
            @(arg)cb_ExportLSSToFile(this,arg));

            this.Dispatcher.subscribe(...
            [Export.ControllerID,'/','browsefolderdialog'],...
            @(arg)cb_BrowseFolderDialogRequest(this,arg));

            this.Dispatcher.subscribe(...
            [Export.ControllerID,'/','exportlabeldefinitiontofile'],...
            @(arg)cb_ExportLabelDefinitionToFile(this,arg));

            this.Dispatcher.subscribe(...
            [Export.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)
        function flag=isVariableExistInWorkspace(~,varName)
            cmd=sprintf('exist(''%s'')',varName);
            flag=(evalin('base',cmd)==1);
        end

        function addVariableInWorkspace(~,varName,data)
            assignin('base',varName,data);
        end

        function lss=createLabeledSignalSetFromLabeler(this,sigIDs,description)
            if this.Model.getAppDataMode()~="inmemory"&&~isempty(this.Model.getDataStoreForApp())
                src=this.Model.getDataStoreForApp();
                lss=labeledSignalSet(src);
            else
                numSigIDs=length(sigIDs);
                src=cell(1,numSigIDs);
                mnames=cell(1,numSigIDs);
                memberInfo=signal.sigappsshared.SignalUtilities.getSignalHierarchyFromIDs(this.Engine,sigIDs,'labeler');
                for member_idx=1:length(memberInfo)




                    varInfo=signal.sigappsshared.SignalUtilities.verifyValidHierarchy(this.Engine,memberInfo(member_idx));
                    varInfo=Simulink.sdi.internal.signalanalyzer.Utilities.convertSigNamesToVarNames(this.Engine,varInfo);

                    if varInfo(1).isLSS

                        src{member_idx}=getMemberDataFromLabeledSignalSet(this,varInfo);
                    else

                        if length(varInfo)>1



                            for cell_idx=1:length(varInfo)
                                memberData{cell_idx}=getMemberDataFromSignal(this,varInfo(cell_idx));
                            end
                            src{member_idx}=memberData;
                        else
                            src{member_idx}=getMemberDataFromSignal(this,varInfo);
                        end
                    end

                    currentMemberName=this.Engine.getSignalName(sigIDs(member_idx));
                    mnames{member_idx}=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(currentMemberName);
                end
                cellIdx=cellfun(@iscell,src);
                if any(cellIdx)&&~all(cellIdx)
                    toCellMember=find(~cellIdx);
                    for idx=1:length(toCellMember)
                        if istimetable(src{toCellMember(idx)})
                            src(toCellMember(idx))={src(toCellMember(idx))};
                        else
                            numCols=size(src{toCellMember(idx)},2);
                            cellOfVector=cell(1,numCols);
                            for col_idx=1:numCols
                                cellOfVector(col_idx)={src{toCellMember(idx)}(:,col_idx)};
                            end
                            src(toCellMember(idx))={cellOfVector};
                        end
                    end
                end
                lss=labeledSignalSet(src,'MemberNames',mnames);
            end
            this.Model.copyMf0ModelLabelsToLSS(lss);
            lss.Description=description;
        end




        function cb_HelpButton(~,args)


            data=args.data;
            if strcmp(data.messageID,'acceptAll')
                signal.labeler.controllers.SignalLabelerHelp('acceptAllHelp');
            elseif strcmp(data.messageID,'exportLSSToWS')
                signal.labeler.controllers.SignalLabelerHelp('exportLSSToWSHelp');
            elseif strcmp(data.messageID,'exportLSSToFile')
                signal.labeler.controllers.SignalLabelerHelp('exportLSSToFileHelp');
            elseif strcmp(data.messageID,'exportLabelDefinitionToWS')
                signal.labeler.controllers.SignalLabelerHelp('exportLabelDefinitionToWSHelp');
            else
                signal.labeler.controllers.SignalLabelerHelp('exportLabelDefinitionHelp');
            end
        end

        function cb_BrowseFolderDialogRequest(this,args)
            fileName=args.data.fileName;
            keyForDialogTitle='ExportLSSToWorkspaceDialogTitle';

            if~isempty(fileName)
                fileName=this.checkAndAddFileExtension(args.data.fileName);
            end
            fileFilter={'*.mat'};
            try
                [fileNameDlg,pathNameDlg]=uiputfile(fileFilter,...
                getString(message(['SDI:dialogsLabeler:',keyForDialogTitle])),...
                fileName);
            catch

            end

            if ischar(fileNameDlg)&&ischar(pathNameDlg)
                fileName=fullfile(pathNameDlg,fileNameDlg);
            else
                fileName=[];
            end
            outData.clientID=args.clientID;
            outData.messageID='fileNameFromBrowseFolderDialog';
            outData.data.fileName=fileName;
            this.notify('BrowseFolderDialogRequestComplete',signal.internal.SAEventData(outData));
        end

        function cb_ExportLSSToFile(this,args)

            fileName=this.checkAndAddFileExtension(args.data.fileName);
            if~validateToolboxLicense(this,args.clientID)
                outData=struct('clientID',args.clientID,...
                'messageID','closeDialog','data',[]);
                this.notify('ExportLSSToFileComplete',signal.internal.SAEventData(outData));
                return;
            end
            forceOverwriteFile=false;
            if isfield(args.data,'forceOverwriteFile')
                forceOverwriteFile=args.data.forceOverwriteFile;
            end
            if~forceOverwriteFile
                if this.isFileExists(fileName)
                    outData.clientID=args.clientID;
                    outData.messageID='showOverWriteConfirmDialog';
                    outData.data=args.data;
                    this.notify('ExportLSSToFileComplete',signal.internal.SAEventData(outData));
                    return;
                end
            end

            ls=this.createLabeledSignalSetFromLabeler(this.Model.getMemberIDsForExport(),args.data.description);

            try
                save(fileName,"ls");
            catch me
                outData.clientID=args.clientID;
                outData.messageID='showWriteToFileError';
                outData.data.message=me.message;
                this.notify('ExportLSSToFileComplete',signal.internal.SAEventData(outData));
                return;
            end
            outData.clientID=args.clientID;
            outData.messageID='closeDialog';
            outData.data=[];
            this.notify('ExportLSSToFileComplete',signal.internal.SAEventData(outData));


            this.onDirtyStateChange(args.clientID);
        end

        function cb_ExportLSSToWorkspace(this,args)


            if~validateToolboxLicense(this,args.clientID)
                outData=struct('clientID',args.clientID,...
                'messageID','closeDialog','data',[]);
                this.notify('ExportLSSToWorkspaceComplete',signal.internal.SAEventData(outData));
                return;
            end
            varName=args.data.varName;
            forceOverwriteVariable=false;
            if isfield(args.data,'forceOverwriteVariable')
                forceOverwriteVariable=args.data.forceOverwriteVariable;
            end
            if~forceOverwriteVariable
                if this.isVariableExistInWorkspace(varName)
                    outData.clientID=args.clientID;
                    outData.messageID='showOverWriteConfirmDialog';
                    outData.data=args.data;
                    this.notify('ExportLSSToWorkspaceComplete',signal.internal.SAEventData(outData));
                    return;
                end
            end
            outData.clientID=args.clientID;
            outData.messageID='closeDialog';
            outData.data=[];
            this.addVariableInWorkspace(varName,this.createLabeledSignalSetFromLabeler(this.Model.getMemberIDsForExport(),args.data.description));
            this.notify('ExportLSSToWorkspaceComplete',signal.internal.SAEventData(outData));


            this.onDirtyStateChange(args.clientID);
        end

        function cb_ExportLabelDefinitionToFile(this,args)


            fileName=this.checkAndAddFileExtension(args.data.fileName);
            forceOverwriteFile=false;
            if isfield(args.data,'forceOverwriteFile')
                forceOverwriteFile=args.data.forceOverwriteFile;
            end
            if~forceOverwriteFile
                if this.isFileExists(fileName)
                    outData.clientID=args.clientID;
                    outData.messageID='showOverWriteConfirmDialog';
                    outData.data=args.data;
                    this.notify('ExportLabelDefComplete',signal.internal.SAEventData(outData));
                    return;
                end
            end
            lblDefs=getAllSignalLabelDefinitions(this.Model);

            try
                save(fileName,"lblDefs");
            catch me
                outData.clientID=args.clientID;
                outData.messageID='showWriteToFileError';
                outData.data.message=me.message;
                this.notify('ExportLabelDefComplete',signal.internal.SAEventData(outData));
                return;
            end
            outData.clientID=args.clientID;
            outData.messageID='closeDialog';
            outData.data=[];
            this.notify('ExportLabelDefComplete',signal.internal.SAEventData(outData));

            if~this.Model.isAppHasMembers()
                this.onDirtyStateChange(args.clientID);
            end
        end

        function cb_ExportLabelDefinitionToWorkspace(this,args)


            varName=args.data.varName;
            forceOverwriteVariable=false;
            if isfield(args.data,'forceOverwriteVariable')
                forceOverwriteVariable=args.data.forceOverwriteVariable;
            end
            if~forceOverwriteVariable
                if this.isVariableExistInWorkspace(varName)
                    outData.clientID=args.clientID;
                    outData.messageID='showOverWriteConfirmDialog';
                    outData.data=args.data;
                    this.notify('ExportLabelDefinitionToWorkspaceComplete',signal.internal.SAEventData(outData));
                    return;
                end
            end
            outData.clientID=args.clientID;
            outData.messageID='closeDialog';
            outData.data=[];
            this.addVariableInWorkspace(varName,getAllSignalLabelDefinitions(this.Model));
            this.notify('ExportLabelDefinitionToWorkspaceComplete',signal.internal.SAEventData(outData));

            if~this.Model.isAppHasMembers()
                this.onDirtyStateChange(args.clientID);
            end
        end
    end

    methods(Access=protected)
        function flag=isFileExists(~,fileName)
            flag=exist(fileName,'file')==2;
        end

        function fileName=checkAndAddFileExtension(~,fileName)

            [~,~,fext]=fileparts(fileName);
            if~strcmpi(fext,'.mat')
                fileName=[fileName,'.mat'];
            end
        end

        function sendInvalidVariableNameMsgToClient(this,clientID)
            import Simulink.sdi.internal.controllers.ExportDialog;
            this.Dispatcher.publishToClient(clientID,...
            ExportDialog.ControllerID,'baseWorkspace_VarNameError',...
            getString(message('SDI:dialogsLabeler:InValidVariableName')));
        end

        function success=validateToolboxLicense(this,clientID)
            success=true;
            if strcmp(this.Model.getAppDataMode(),'audioFile')


                [success,errMsg]=audio.labeler.internal.AudioModeController.checkoutAudioToolboxLicense();
                if~success
                    errStruct=struct('ErrorID','AudioToolboxLicenseFailedAtExport',...
                    'ErrorMsg',errMsg);
                    this.Dispatcher.publishToClient(clientID,...
                    'importAudioFilesController','audioToolboxLicenseFailed',errStruct);
                end
            end
        end

        function[childData]=getMemberDataFromLabeledSignalSet(this,varInfo)

            if~isempty(varInfo.Children)
                if all([varInfo.Children.isTT])

                    childData=exportToTimetable(this.Engine,varInfo);
                elseif all([varInfo.Children.isMatrix])

                    if varInfo.isExportToTimetable

                        childData=exportToTimetable(this.Engine,varInfo);
                    else

                        for child_idx=1:length(varInfo.Children)
                            dataValues=this.Model.getSignalValue(varInfo.Children(child_idx).signalID);
                            data(:,child_idx)=dataValues.Data;%#ok<AGROW>
                        end
                        childData=data;
                    end
                else

                    childData=cell(1,length(varInfo.Children));
                    for child_idx=1:length(varInfo.Children)
                        childData{child_idx}=getMemberDataFromLabeledSignalSet(this,varInfo.Children(child_idx));
                    end
                end
            else
                if varInfo.isExportToTimetable

                    childData=exportToTimetable(this.Engine,varInfo);
                else

                    dataValues=this.Model.getSignalValue(varInfo.signalID);
                    childData=dataValues.Data;
                end
            end
        end

        function[childData]=getMemberDataFromSignal(this,varInfo)

            if~isempty(varInfo.Children)
                if all([varInfo.Children.isTT])

                    childData=exportToTimetable(this.Engine,varInfo);
                elseif all([varInfo.Children.isMatrix])

                    if varInfo.isExportToTimetable

                        childData=exportToTimetable(this.Engine,varInfo);
                    else

                        for child_idx=1:length(varInfo.Children)
                            dataValues=this.Model.getSignalValue(varInfo.Children(child_idx).signalID);
                            data(:,child_idx)=dataValues.Data;%#ok<AGROW>
                        end
                        childData=data;
                    end
                end
            else

                if varInfo.isExportToTimetable

                    childData=exportToTimetable(this.Engine,varInfo);
                else

                    dataValues=this.Model.getSignalValue(varInfo.signalID);
                    childData=dataValues.Data;
                end
            end
        end
    end

    methods
        function onDirtyStateChange(this,clientID)
            dirtyStateChanged=this.Model.setDirty(false);
            if dirtyStateChanged
                this.changeAppTitle(this.Model.isDirty());
                this.notify('DirtyStateChanged',...
                signal.internal.SAEventData(struct('clientID',str2double(clientID))));
            end
        end

        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
