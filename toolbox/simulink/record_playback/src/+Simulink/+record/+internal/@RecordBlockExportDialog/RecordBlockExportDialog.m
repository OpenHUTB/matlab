classdef RecordBlockExportDialog<handle




    methods(Static)

        function ret=getRecordBlockExportDialogInstance(varargin)

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin<=2&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.record.internal.RecordBlockExportDialog(dispatcherObj);
            end

            ret=ctrlObj;
        end
    end

    methods
        function this=RecordBlockExportDialog(dispatcherObj)
            import Simulink.record.internal.RecordBlockExportDialog;
            this.Dispatcher=dispatcherObj;
            this.Dispatcher.subscribe(...
            [RecordBlockExportDialog.ControllerID,'/','browseFolderDialogRequest'],...
            @(arg)cb_BrowseFolderDialogRequest(this,arg));
        end


        function cb_BrowseFolderDialogRequest(this,arg)



            fileName='';
            fileFilter={'*.mat';'*.xlsx';'*.mldatx'};

            try
                [filename,pathname]=uiputfile(fileFilter,...
                Simulink.sdi.internal.StringDict.mgExportMatFolderUIBrowseTitle);
            catch me
                error_stage=sldiagviewer.createStage('Error','ModelName',gcs);
                error_stage.reportError(me.message);
            end

            if ischar(filename)&&ischar(pathname)
                fileName=fullfile(pathname,filename);
            else
                fileName=[];
            end

            import Simulink.record.internal.RecordBlockExportDialog;
            this.Dispatcher.publishToClient(arg.clientID,...
            RecordBlockExportDialog.ControllerID,'setfileName',...
            fileName);
        end
    end


    properties(Access=private)
        Dispatcher;
    end


    properties(Constant)
        ControllerID='recordBlockExportDialog';
    end
end

