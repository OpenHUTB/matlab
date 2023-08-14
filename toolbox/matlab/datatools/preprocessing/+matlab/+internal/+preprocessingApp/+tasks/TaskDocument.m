classdef TaskDocument<matlab.internal.preprocessingApp.base.PreprocessingDocument




    properties
TaskChangedFcn
    end

    properties(Access=private)
LiveAppStateChangedEventListener
EnabledChildren
    end

    methods
        function obj=TaskDocument(varargin)
            obj@matlab.internal.preprocessingApp.base.PreprocessingDocument(varargin{:});
            obj.Figure.Color='white';
        end

        function startup(obj,taskUI)

            obj.setupAppStateListeners(taskUI);


            obj.setupScrollability;
        end

        function disableUpdateInteractions(obj)
            obj.EnabledChildren=findobj(obj.Figure,'Enable',true);
            set(obj.EnabledChildren,'Enable',false);
        end

        function enableUpdateInteractions(obj)
            if~isempty(obj.EnabledChildren)
                set(obj.EnabledChildren,'Enable',true);
            else
                disabledChildren=findobj(obj.Figure,'Enable',false);
                set(disabledChildren,'Enable',true);
            end
            obj.EnabledChildren=[];
        end

        function delete(obj)
            if~isempty(obj.LiveAppStateChangedEventListener)
                obj.LiveAppStateChangedEventListener.delete();
            end
        end
    end

    methods(Access={?matlab.internal.preprocessingApp.tasks.TaskDocument,?matlab.unittest.TestCase})
        function setupAppStateListeners(obj,taskUI)
            import matlab.internal.editor.LiveAppContainer;

            obj.LiveAppStateChangedEventListener=LiveAppContainer(taskUI);
            obj.LiveAppStateChangedEventListener.registerChangedListener(...
            @(e,d)obj.fireStateChange,...
            obj.Figure);
        end

        function fireStateChange(obj)
            if~isempty(obj.TaskChangedFcn)
                try
                    obj.TaskChangedFcn();
                catch e
                    disp(e);
                end
            end
        end

        function setupScrollability(obj)

            if length(obj.Figure.Children)==1...
                &&isa(obj.Figure.Children,'matlab.ui.container.GridLayout')
                obj.Figure.Children.Scrollable=true;
            end
        end
    end
end

