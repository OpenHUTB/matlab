classdef(Hidden)NumericalContributor<livetask.internal.RegisteredTaskTemplate



    methods(Static)
        function isTimeBased=isTimeBasedType(StorageType)
            isTimeBased=strcmpi(StorageType,'timetable')||...
            strcmpi(StorageType,'timeseries')||...
            strcmpi(StorageType,'dataarray');
        end
    end

    properties(Access=public,Hidden)





UIComponents

        VarName=''

UIBuilder
TaskCodeGenerator
WidgetController
        MainGrid matlab.ui.container.GridLayout

        SET_DATA_ON_START_UP=false
        DID_START_UP=false
    end

    properties(Access=protected)

        State=struct;
    end


    properties(Constant)
        DefaultState=struct(...
        'DataType','double',...
        'StorageType','timeseries',...
        'Dimensions',1,...
        'Data',[],...
        'VectorType','Column',...
        'ColumnName','Var1',...
        'TimeDuration','seconds',...
        'PlotOutput',false);
    end


    methods


        function obj=NumericalContributor(inParent)



            obj.MainGrid=uigridlayout(inParent,'Padding',0,'RowHeight',{'fit'},'ColumnWidth',{'fit'});
            obj.MainGrid.Visible='off';

            initialize(obj);
            reset(obj);




        end


        function delete(obj)
            if isvalid(obj.MainGrid)
                obj.MainGrid.Visible='off';
            end

            if isvalid(obj.WidgetController)
                delete(obj.WidgetController);
            end

            if isvalid(obj.UIComponents.DrawDataWidget)
                delete(obj.UIComponents.DrawDataWidget);
            end

            if isvalid(obj.MainGrid)

                delete(obj.MainGrid);
            end

        end



        function update(app,~)
            app.updateUIState();
        end
    end


    methods(Access=protected)

        function initialize(obj)

            createUIBuilder(obj);
            createCodeGenerator(obj);


            buildUI(obj);
            createWidgetController(obj);
        end


        function createCodeGenerator(obj)
            obj.TaskCodeGenerator=datacreation.internal.TaskDataCreationCoder(obj);
        end


        function createUIBuilder(obj)

            obj.UIBuilder=datacreation.internal.TaskUIBuilder(obj);

        end


        function createWidgetController(obj)
            obj.WidgetController=datacreation.internal.AppWidgetController(obj);
        end


        function buildUI(obj)



            buildUI(obj.UIBuilder,obj.MainGrid);
        end


        function outVal=formatDataValuesForTable(app,inDataVals)

            outVal=formatTableDataValuesForTable(app.WidgetController,inDataVals);

        end


        function updateUIState(app)
            isTimeBased=false;

            if datacreation.contributor.NumericalContributor.isTimeBasedType(app.State.StorageType)
                isTimeBased=true;
            end

            updateUIStorageTypeAndDurationType(app);


            if~isempty(app.State.Data)&&~isempty(app.State.Data.x)


                updateScopeFromAppState(app.WidgetController);


                app.SET_DATA_ON_START_UP=true;



                appStateData.isTimeBased=isTimeBased;
                appStateData.StorageType=app.State.StorageType;
                appStateData.ColumnName=app.State.ColumnName;
                datacreation.internal.UIDecorator.decorateUITableHeaders(appStateData,app.UIComponents.UITable);

                if isTimeBased
                    app.UIComponents.UITable.Data=combineDataForTable(app,app.State.Data.x,...
                    formatDataValuesForTable(app,app.State.Data.y));
                else
                    app.UIComponents.UITable.Data=formatDataValuesForTable(app,app.State.Data.y);
                end



            else
                app.State.Data.x=[];
                app.State.Data.y=[];
                app.UIComponents.DrawDataWidget.Value=app.State.Data;
                app.SET_DATA_ON_START_UP=true;

                app.UIComponents.UITable.Data=[];
                appStateData.isTimeBased=isTimeBased;
                appStateData.StorageType=app.State.StorageType;
                appStateData.ColumnName=app.State.ColumnName;
                datacreation.internal.UIDecorator.decorateUITableHeaders(appStateData,app.UIComponents.UITable);
            end


            updateUIAdvancedProperties(app);

            if app.State.PlotOutput
                app.UIComponents.DisplayPlotCheck.Value=1;
            else
                app.UIComponents.DisplayPlotCheck.Value=0;
            end

        end


        function tableDataValue=combineDataForTable(app,x,y)
            tableDataValue=app.WidgetController.combineDataForTable(x,y);
        end


        function updateUIAdvancedProperties(app)

            switch app.State.VectorType
            case 'Column'

                app.UIComponents.VectorTypeDropDown.Value=message('datacreation:datacreation:vectorTypeColumn').getString;
            case 'Row'
                app.UIComponents.VectorTypeDropDown.Value=message('datacreation:datacreation:vectorTypeRow').getString;
            end


            updateUIDataType(app);

            app.UIComponents.ColumnNameField.Value=app.State.ColumnName;

        end


        function updateUIStorageTypeAndDurationType(app)

            switch lower(app.State.StorageType)
            case 'vector'

                app.UIComponents.StorageDropDown.Value=message('datacreation:datacreation:vectorButtonLabel').getString;


                setColumnNameWidgetsVisible(app.WidgetController,false);
                setDurationWidgetsVisible(app.WidgetController,false);
                app.UIComponents.StoragePropGrid.RowHeight{2}=0;

                app.UIComponents.DrawDataWidget.XRulerType='vector';
            case 'table'

                app.UIComponents.StorageDropDown.Value=message('datacreation:datacreation:tableButtonLabel').getString;



                setColumnNameWidgetsVisible(app.WidgetController,true);
                setDurationWidgetsVisible(app.WidgetController,false);
                app.UIComponents.StoragePropGrid.RowHeight{2}='fit';

                app.UIComponents.DrawDataWidget.XRulerType='vector';
            case 'timeseries'

                app.UIComponents.StorageDropDown.Value=message('datacreation:datacreation:timeseriesButtonLabel').getString;
                setColumnNameWidgetsVisible(app.WidgetController,false);
                setDurationWidgetsVisible(app.WidgetController,false);

                app.UIComponents.StoragePropGrid.RowHeight{2}=0;
                app.UIComponents.DrawDataWidget.XRulerType='timebased';

            case 'dataarray'

                app.UIComponents.StorageDropDown.Value=message('datacreation:datacreation:dataArrayButtonLabel').getString;
                setColumnNameWidgetsVisible(app.WidgetController,false);
                setDurationWidgetsVisible(app.WidgetController,false);

                app.UIComponents.StoragePropGrid.RowHeight{2}=0;
                app.UIComponents.DrawDataWidget.XRulerType='timebased';
            case 'timetable'

                app.UIComponents.StorageDropDown.Value=message('datacreation:datacreation:timeTableButtonLabel').getString;
                setColumnNameWidgetsVisible(app.WidgetController,true);
                setDurationWidgetsVisible(app.WidgetController,true);

                app.UIComponents.StoragePropGrid.RowHeight{2}='fit';
                switch app.State.TimeDuration
                case 'seconds'

                    app.UIComponents.DurationDropDown.Value=message('datacreation:datacreation:secondsDurationType').getString;

                case 'minutes'

                    app.UIComponents.DurationDropDown.Value=message('datacreation:datacreation:minutesDurationType').getString;

                case 'hours'

                    app.UIComponents.DurationDropDown.Value=message('datacreation:datacreation:hoursDurationType').getString;

                case 'days'

                    app.UIComponents.DurationDropDown.Value=message('datacreation:datacreation:daysDurationType').getString;

                case 'years'

                    app.UIComponents.DurationDropDown.Value=message('datacreation:datacreation:yearsDurationType').getString;
                end

                app.UIComponents.DrawDataWidget.XRulerType='timebased';
            end

        end


        function updateUIDataType(app)
            if~strcmpi(app.UIComponents.DataTypeDropDown,app.State.DataType)
                valueToSet=app.State.DataType;

                switch(valueToSet)

                case 'double'

                    valueToSet=message('datacreation:datacreation:doubleDataType').getString;

                case 'single'

                    valueToSet=message('datacreation:datacreation:singleDataType').getString;

                case 'uint8'

                    valueToSet=message('datacreation:datacreation:uint8DataType').getString;

                case 'int8'

                    valueToSet=message('datacreation:datacreation:int8DataType').getString;

                case 'uint16'

                    valueToSet=message('datacreation:datacreation:uint16DataType').getString;

                case 'int16'

                    valueToSet=message('datacreation:datacreation:int16DataType').getString;

                case 'uint32'

                    valueToSet=message('datacreation:datacreation:uint32DataType').getString;

                case 'int32'

                    valueToSet=message('datacreation:datacreation:int32DataType').getString;

                case 'uint64'

                    valueToSet=message('datacreation:datacreation:uint64DataType').getString;

                case 'int64'

                    valueToSet=message('datacreation:datacreation:int64DataType').getString;

                case 'half'

                    valueToSet=message('datacreation:datacreation:halfDataType').getString;

                end

                app.UIComponents.DataTypeDropDown.Value=valueToSet;
            end
        end


        function summary=getDefaultSummary(~)
            summary=message(...
            'datacreation:datacreation:dataCreationNumericPurpose').getString;
        end

    end



    methods(Access=public)


        function[code,outputs]=generateScript(app)
            code='';
            outputs={};



            if canGenerateCode(app.TaskCodeGenerator)
                [code,outputs]=generateScript(app.TaskCodeGenerator);
            end

        end


        function code=generateVisualizationScript(obj)

            code=generateVisualizationScript(obj.TaskCodeGenerator);

        end


        function summary=generateSummary(app)

            if~isstruct(app.State.Data)||isempty(app.State.Data.x)
                summary=getDefaultSummary(app);
                return;
            end

            durationDataType=app.State.TimeDuration;

            dtToReport=app.State.DataType;

            if strcmpi(dtToReport,'boolean')
                dtToReport='logical';
            end

            switch lower(app.State.StorageType)
            case 'timetable'

                summary=message(...
                'datacreation:datacreation:timetableSummary',...
                app.State.StorageType,dtToReport,...
                durationDataType).getString;

            otherwise

                summary=message(...
                'datacreation:datacreation:taskSummary',...
                app.State.StorageType,dtToReport).getString;

            end
        end


        function state=getState(app)
            state=app.State;
        end


        function setState(app,inState)
            app.State=inState;

            updateUIState(app);
        end


        function reset(app)
            state=app.DefaultState;



            app.setState(state);
        end
    end


    methods(Access=public,Hidden)


        function appNotifyChanged(app)
            notify(app,'StateChanged');
        end


        function onStartupMessage(app,~,~)


            if app.SET_DATA_ON_START_UP
                app.UIComponents.DrawDataWidget.Value=app.State.Data;
            end


            setTableColumnFormatSequence(app.WidgetController);

            app.MainGrid.Visible='on';
            app.DID_START_UP=true;


            if~isempty(app.State.Data.x)
                app.UIComponents.DrawDataWidget.fitToView();
            end
        end
    end


    methods(Access=public,Hidden)


        function outFlag=getSET_DATA_ON_START_UP(app)
            outFlag=app.SET_DATA_ON_START_UP;
        end


        function outFlag=getDID_START_UP(app)
            outFlag=app.DID_START_UP;
        end


        function setStateData(app,inData)
            app.State.Data=inData;
        end


        function setStateStorageType(app,inType)
            app.State.StorageType=inType;
        end


        function setStateDataType(app,inDataType)
            app.State.DataType=inDataType;
        end


        function setVectorType(app,inVectorType)
            app.State.VectorType=inVectorType;
        end


        function setColumnName(app,colName)
            app.State.ColumnName=colName;
        end


        function setDuration(app,inDuration)
            app.State.TimeDuration=inDuration;
        end


        function setPlotOutput(app,shouldPlot)
            app.State.PlotOutput=shouldPlot;
        end


        function setDataCreationToolDataType(app,inValue)
            app.UIComponents.DrawDataWidget.setDataType(inValue);
        end

    end
end
