classdef App<simscape.internal.variablescaling.Base




    properties(Access=private)
        View;
        Control;
        Model;
        Listener;
    end

    methods(Access=private)
        function obj=App(modelName)

            mlock;

            if nargin>0
                obj.Model=simscape.internal.variablescaling.Model(modelName);
            else
                obj.Model=simscape.internal.variablescaling.Model();
            end
            obj.View=simscape.internal.variablescaling.View;
            obj.Control=simscape.internal.variablescaling.Control(obj.Model,obj.View);
            obj.Listener=listener(obj.View,'StateChanged',@(source,event)obj.appCloser);
        end

        function appCloser(obj)
            if obj.View.State==matlab.ui.container.internal.appcontainer.AppState.TERMINATED


                munlock;


                delete(obj);
            end
        end
    end

    methods
        function delete(obj)
            delete(obj.Listener);
            delete(obj.Model);
            delete(obj.View);
            delete(obj.Control);
        end
    end

    methods(Static)
        function showInstance(modelName)
            persistent instance;

            if nargin>0
                simscape.internal.variablescaling.Base.mustBeSimulinkModelName(modelName);
            end

            if isempty(instance)||~isvalid(instance)...
                ||~isvalid(instance.View)...
                ||~isvalid(instance.Model)...
                ||instance.View.State~=matlab.ui.container.internal.appcontainer.AppState.RUNNING
                delete(instance);
                if nargin>0
                    instance=simscape.internal.variablescaling.App(modelName);
                else
                    instance=simscape.internal.variablescaling.App;
                end
            else
                if nargin>0
                    instance.Model.open(modelName);
                end
            end
            instance.View.bringToFront;
        end
    end
end
