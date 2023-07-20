classdef(Hidden)EnumContributor<datacreation.contributor.NumericalContributor








    methods(Access=protected)


        function summary=getDefaultSummary(app)
            summary=message(...
            'datacreation:datacreation:dataCreationEnumPurpose').getString;
        end


        function createUIBuilder(app)

            app.UIBuilder=datacreation.internal.EnumTaskUIBuilder(app);

        end


        function createWidgetController(app)
            app.WidgetController=datacreation.internal.EnumAppWidgetController(app);
        end


        function createCodeGenerator(app)
            app.TaskCodeGenerator=datacreation.internal.EnumTaskDataCreationCoder(app);
        end

        function updateUIDataType(app)
            msg.isEnum=true;
            [enumObject,~]=datacreation.internal.DataTypeHelper.getEnumerationDefinitionByName(app.State.DataType);
            msg.enumerationDef=enumObject;
            msg.enumerationName=app.State.DataType;
            app.UIComponents.DrawDataWidget.setYRulerType(msg);
        end


        function tableDataValue=combineDataForTable(app,x,y)
            numPts=length(x);
            result=cell(numPts,2);
            for k=1:numPts
                result{k,1}=x(k);
                result{k,2}=y{k};

            end

            tableDataValue=result;
        end

    end

    methods


        function setState(app,inState)
            app.State=inState;

            updateUIState(app);
        end


        function reset(app)
            state=app.DefaultState;


            state.DataType='matlab.lang.OnOffSwitchState';
            app.setState(state);
        end


        function updateTableColumnFormat(app,inFormat)
            app.UIComponents.UITable.ColumnFormat={inFormat};
        end

    end


    methods(Access=public,Hidden)


        function onStartupMessage(app,~,~)

            setContainerVisible(app.UIBuilder,'on');

            app.setStateDataType(app.State.DataType);
            app.UIComponents.DrawDataWidget.setDataType(app.State.DataType);
            msg.isEnum=true;
            [enumObject,~]=datacreation.internal.DataTypeHelper.getEnumerationDefinitionByName(app.State.DataType);
            msg.enumerationDef=enumObject;
            msg.enumerationName=app.State.DataType;
            app.UIComponents.DrawDataWidget.setYRulerType(msg);
            if app.SET_DATA_ON_START_UP
                app.UIComponents.DrawDataWidget.Value=app.State.Data;
            end
            app.UIComponents.EnumEditField.Value=app.State.DataType;




            setTableColumnFormatByState(app.WidgetController,app.State);

            app.MainGrid.Visible='on';


            if~isempty(app.State.Data.x)
                app.UIComponents.DrawDataWidget.fitToView();
            end
            app.DID_START_UP=true;
        end

    end
end
