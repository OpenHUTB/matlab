classdef(Sealed)AppLauncher<handle






    properties(SetAccess=private,Hidden)
Model
View
Controller
    end

    methods(Access=private)
        function this=AppLauncher(varargin)

            mlock;


            this.Controller=evolutions.internal.app.AppController(varargin{:});
            if isvalid(this.Controller)

                this.View=this.Controller.AppView;
                this.Model=this.Controller.AppModel;
                addlistener(this.Controller,'ObjectBeingDestroyed',@(~,~)delete(this));
            else
                delete(this);
            end
            show(this);
        end
    end

    methods(Static,Access=private)
        function app=changeAppState(state,varargin)
            persistent appHandle;
            switch state
            case 'Launch'
                if isempty(appHandle)||~isvalid(appHandle)
                    appHandle=evolutions.internal.app.AppLauncher(varargin{:});
                end
            otherwise
                assert(isequal(state,'Close'))
                if~isempty(appHandle)&&isvalid(appHandle)
                    appHandle.Controller.closeApp;
                end
            end
            app=appHandle;
        end
    end

    methods(Static)
        function app=launchApp(varargin)

            if~builtin('license','test','simulink')
                exception=MException('evolutions:ui:noSLLicense',...
                message('evolutions:ui:noSLLicense'));
                throw(exception);
            end

            if~builtin('license','checkout','simulink')
                exception=MException('evolutions:ui:unavailableSLLicense',...
                message('evolutions:ui:unavailableSLLicense'));
                throw(exception);
            end
            app=evolutions.internal.app.AppLauncher.changeAppState('Launch',varargin{:});
        end

        function closeApp
            app=evolutions.internal.app.AppLauncher.changeAppState('Close');
            delete(app);
        end
    end

    methods
        function delete(this)


            if~isempty(this.Controller)&&isvalid(this.Controller)
                delete(this.Controller);
            end
            delete(this.Model);

            munlock;
        end

        function show(this)
            if isvalid(this)&&isvalid(this.View)
                this.View.show();
            end
        end
    end
end


