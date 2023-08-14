classdef InspectorTaskPanel<matlab.internal.preprocessingApp.base.PreprocessingPanel




    properties
TaskChangedFcn
    end

    properties(Access=private)
AppStateChangedEventListener
AppStateChangeEventAggregator
EnabledChildren
    end

    methods
        function obj=InspectorTaskPanel(varargin)
            obj@matlab.internal.preprocessingApp.base.PreprocessingPanel(varargin{:});

            panelWidth=300;
            obj.PreferredWidth=panelWidth;
        end

        function startup(obj)

            obj.setupAppStateListeners();


            obj.setupScrollability;
        end

        function disableUpdateInteractions(obj)

            obj.EnabledChildren=findobj(obj.Figure,'Enable',true);
            set(obj.EnabledChildren,'Enable',false);
        end

        function enableUpdateInteractions(obj)

            if~isempty(obj.EnabledChildren)
                set(obj.EnabledChildren,'Enable',true);
            end
            obj.EnabledChildren=[];
        end

        function delete(obj)
            if~isempty(obj.AppStateChangeEventAggregator)
                obj.AppStateChangedEventListener.delete();
                obj.AppStateChangeEventAggregator.delete();
            end
        end
    end

    methods(Access={?matlab.internal.preprocessingApp.tasks.TaskDocument,?matlab.unittest.TestCase})
        function setupAppStateListeners(obj)
            aggregator=matlab.ui.internal.AppStateChangeEventAggregator();
            aggregator.attach(obj.Figure);
            obj.AppStateChangedEventListener=addlistener(aggregator,'AppStateChanged',@(e,d)obj.fireStateChange);
            obj.AppStateChangeEventAggregator=aggregator;
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

