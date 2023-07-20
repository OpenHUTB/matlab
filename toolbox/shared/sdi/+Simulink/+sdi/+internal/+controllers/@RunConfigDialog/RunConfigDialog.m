


classdef RunConfigDialog<handle



    methods(Static)

        function ret=getController(varargin)

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin==1&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.sdi.internal.controllers.RunConfigDialog(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end


    methods(Hidden)

        function this=RunConfigDialog(dispatcherObj)

            eng=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=Simulink.sdi.internal.models.RunConfigDialog(eng);

            import Simulink.sdi.internal.controllers.RunConfigDialog;
            this.Dispatcher.subscribe(...
            [RunConfigDialog.ControllerID,'/','get_initSetup'],...
            @(arg)cb_GetInitSetup(this,arg));
            this.Dispatcher.subscribe(...
            [RunConfigDialog.ControllerID,'/','get_defaultRunNameTemplate'],...
            @(arg)cb_RestoreDefaultButton(this,arg));
            this.Dispatcher.subscribe(...
            [RunConfigDialog.ControllerID,'/','ok'],...
            @(arg)cb_OKButton(this,arg));
            this.Dispatcher.subscribe(...
            [RunConfigDialog.ControllerID,'/','help'],...
            @(arg)cb_HelpButton(this,arg));
        end


        function cb_GetInitSetup(this,arg)



            import Simulink.sdi.internal.controllers.RunConfigDialog;
            setupData=struct;
            appendRunOrder=this.Model.getAppendRunOrder;
            if appendRunOrder
                setupData.appendRunOrder='top';
            else
                setupData.appendRunOrder='bottom';
            end

            setupData.runNameTemplate=this.Model.getRunNameTemplate;
            if isempty(setupData.runNameTemplate)
                setupData.runNameTemplate=[];
            end

            this.Dispatcher.publishToClient(arg.clientID,...
            RunConfigDialog.ControllerID,'set_initSetup',...
            setupData);
        end


        function cb_RestoreDefaultButton(this,arg)




            import Simulink.sdi.internal.controllers.RunConfigDialog;
            defaultRunNameTemplate=this.Model.getDefaultRunNameTemplate;
            if isempty(defaultRunNameTemplate)
                defaultRunNameTemplate=[];
            end
            this.Dispatcher.publishToClient(arg.clientID,...
            RunConfigDialog.ControllerID,'set_runNameTemplate',...
            defaultRunNameTemplate);
        end


        function cb_OKButton(this,arg)




            this.transferScreenToData(arg);
        end


        function cb_HelpButton(~,~)

            Simulink.sdi.internal.controllers.SDIHelp('runConfigHelp');
        end
    end


    methods(Access=private)

        function transferScreenToData(this,arg)



            info=arg.data;
            appendRunOrder=info.appendRunOrder;
            runNameTemplate=info.runNameTemplate;
            this.Model.setAppendRunOrder(appendRunOrder);
            this.Model.setRunNameTemplate(runNameTemplate);

            eng=Simulink.sdi.Instance.engine;
            savePreferences(eng);
        end
    end


    properties(Hidden)
        Model;
        Dispatcher;
    end


    properties(Constant)
        ControllerID='runConfigOptionsDialog';
    end
end


