classdef UnifiedPreferencesDialog<handle





    properties(Access=private)
        Engine;
        Dispatcher;
    end

    properties(Constant)
        ControllerID='UnifiedPreferencesDialog';
    end


    methods(Hidden)

        function this=UnifiedPreferencesDialog(dispatcherObj)
            this.Engine=Simulink.sdi.Instance.engine;

            import Simulink.sdi.internal.controllers.UnifiedPreferencesDialog;
            this.Dispatcher=dispatcherObj;

            this.Dispatcher.subscribe(...
            [UnifiedPreferencesDialog.ControllerID,'/','help'],...
            @(arg)UnifiedPreferencesDialog.cb_HelpButton(this,arg));
        end
    end


    methods(Static)

        function ret=getController(varargin)
            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin==1&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.sdi.internal.controllers.UnifiedPreferencesDialog(dispatcherObj);
            end
            ret=ctrlObj;
        end


        function cb_HelpButton(~,arg)
            helpDocKey=arg.data.helpDocKey;
            Simulink.sdi.internal.controllers.SDIHelp(helpDocKey);
        end
    end
end

