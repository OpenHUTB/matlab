classdef ImportDialog<handle




    properties(Hidden)
        Dispatcher;
        ValidExtensions={'.mat'};
        MATFileName;
    end

    properties(Constant)
        ControllerID='importDataDialog';
    end

    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.labeler.controllers.ImportDialog(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end

    methods(Hidden)
        function this=ImportDialog(dispatcherObj)

            this.Dispatcher=dispatcherObj;

            import signal.labeler.controllers.ImportDialog;

            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','browseMATFile'],...
            @(arg)cb_browserMATFileButton(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','get_matFileName'],...
            @(arg)cb_getMATFileName(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','help'],...
            @(arg)cb_HelpButton(this,arg));
        end


        function cb_HelpButton(~,~)

        end


        function cb_browserMATFileButton(this,arg)






            import signal.labeler.controllers.ImportDialog;

            this.MATFileName=[];

            if isfield(arg.data,'filename')
                if isempty(arg.data.filename')
                    status=this.openMatFile();
                else
                    this.MATFileName=arg.data.filename;
                    status=true;
                end
            elseif~isempty(arg.data)
                this.MATFileName=arg.data;
                status=true;
            else
                status=this.openMatFile();
            end


            if status

                this.cb_getMATFileName(arg);
            else

                this.Dispatcher.publishToClient(arg.clientID,...
                ImportDialog.ControllerID,'set_matFileName',[]);
            end
        end


        function cb_getMATFileName(this,arg)




            import signal.labeler.controllers.ImportDialog;
            matFileName=this.MATFileName;
            if isempty(matFileName)
                matFileName=[];
            end
            this.Dispatcher.publishToClient(arg.clientID,...
            ImportDialog.ControllerID,'set_matFileName',matFileName);
        end
    end



    methods(Access=private)
        function outData=getDataFromModel(this,~)
            import signal.labeler.controllers.ImportDialog;
            outData.baseWSOrMAT=false;
            outData.matFileName=this.MATFileName;
        end


        function status=openMatFile(this)

            SD=Simulink.sdi.internal.StringDict;

            dlgFilter='*.mat';
            [LoadFileName,LoadPathName]=uigetfile(dlgFilter,SD.MATLoadTitle);
            status=~isequal(LoadFileName,0);
            if status
                this.MATFileName=fullfile(LoadPathName,LoadFileName);
            end
        end
    end

end


