classdef(Hidden)LogicalContributor<datacreation.contributor.NumericalContributor







    methods(Access=protected)


        function summary=getDefaultSummary(app)
            summary=message(...
            'datacreation:datacreation:dataCreationLogicalPurpose').getString;
        end


        function createUIBuilder(app)

            app.UIBuilder=datacreation.internal.LogicalTaskUIBuilder(app);

        end


        function createWidgetController(app)
            app.WidgetController=datacreation.internal.LogicalAppWidgetController(app);
        end


        function updateUIDataType(app)

        end


        function createCodeGenerator(app)
            app.TaskCodeGenerator=datacreation.internal.LogicalTaskDataCreationCoder(app);
        end

    end

    methods


        function setState(app,inState)
            app.State=inState;

            app.State.DataType='boolean';
            updateUIState(app);
        end


        function reset(app)
            state=app.DefaultState;


            state.DataType='boolean';
            app.setState(state);
        end

    end


    methods(Access=public,Hidden)


        function onStartupMessage(app,~,~)

            setContainerVisible(app.UIBuilder,'on');

            if app.SET_DATA_ON_START_UP
                app.UIComponents.DrawDataWidget.Value=app.State.Data;
            end

            app.UIComponents.DrawDataWidget.setDataType('boolean');
            app.setStateDataType('boolean');
            app.MainGrid.Visible='on';


            if~isempty(app.State.Data.x)
                app.UIComponents.DrawDataWidget.fitToView();
            end
            app.UIComponents.DrawDataWidget.setYLim([-.5,2]);


            app.DID_START_UP=true;
        end

    end

end
