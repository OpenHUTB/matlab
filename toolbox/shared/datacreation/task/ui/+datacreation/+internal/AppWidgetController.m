classdef(Hidden)AppWidgetController<handle








    properties
app
    end


    properties(Access=protected)
ScopeDataListener
ScopeStartListener
    end


    methods(Access=public)


        function obj=AppWidgetController(appToControl)
            obj.app=appToControl;

            obj.app.UIComponents.StorageDropDown.ValueChangedFcn=@(src,evt)obj.storeSelectionChanged(src,evt);
            bindDataTypeCallback(obj);
            obj.app.UIComponents.VectorTypeDropDown.ValueChangedFcn=@(src,evt)obj.vectorTypeValueChanged(src,evt);

            obj.app.UIComponents.ColumnNameField.ValueChangedFcn=@(src,evt)obj.columnNameValueChanged(src,evt);
            obj.app.UIComponents.DurationDropDown.ValueChangedFcn=@(src,evt)obj.durationValueChanged(src,evt);


            obj.app.UIComponents.DrawDataWidget.ValueChangedFcn=@obj.onDataFromClient;
            obj.app.UIComponents.DrawDataWidget.SelectionChangedFcn=@obj.onSelectionFromClient;
            obj.ScopeStartListener=addlistener(obj.app.UIComponents.DrawDataWidget,'StartUpComplete',@obj.onStartupMessage);


            obj.app.UIComponents.UITable.DisplayDataChangedFcn=@obj.onTableDataChange;

            obj.app.UIComponents.UITable.CellEditCallback=@obj.onTableCellEdit;
            obj.app.UIComponents.UITable.CellSelectionCallback=@obj.onCellSelectionCallback;
            obj.app.UIComponents.UITable.KeyPressFcn=@obj.onKeyPressFcn;

            obj.app.UIComponents.DisplayPlotCheck.ValueChangedFcn=@(src,evt)obj.displayPlotValueChanged(src,evt);


            setVectorTypeDropDownEnable(obj,matlab.lang.OnOffSwitchState.off);

        end


        function bindDataTypeCallback(obj)
            obj.app.UIComponents.DataTypeDropDown.ValueChangedFcn=@(src,evt)obj.dataTypeValueChanged(src,evt);
        end


        function delete(obj)


            delete(obj.ScopeDataListener);
            delete(obj.ScopeStartListener);
        end


        function onStartupMessage(obj,~,~)
            obj.app.onStartupMessage();
        end


        function onDataFromClient(obj,~,inVal)

            updateTableDataAfterDrawUpdate(obj,inVal);
            obj.app.setStateData(inVal.NewState.Data);
            appNotifyChanged(obj.app);

        end




        function onSelectionFromClient(obj,~,inVal)


            if isempty(inVal.NewState.selectedIndex)
                obj.app.UIComponents.UITable.Selection=[];
            else


                tmpselection=zeros(length(inVal.NewState.selectedIndex)*2,2);


                count=1;
                for k=1:length(inVal.NewState.selectedIndex)

                    tmpselection(count,1)=inVal.NewState.selectedIndex(k)+1;
                    tmpselection(count,2)=1;


                    count=count+1;
                    tmpselection(count,1)=inVal.NewState.selectedIndex(k)+1;
                    tmpselection(count,2)=2;


                    count=count+1;
                end


                obj.app.UIComponents.UITable.Selection=tmpselection;
            end



        end


        function updateTableDataAfterDrawUpdate(obj,inVal)

            if strcmpi(obj.app.UIComponents.DrawDataWidget.XRulerType,'timebased')
                setTableData(obj,combineDataForTable(obj,inVal.NewState.Data.x,inVal.NewState.Data.y));
            else
                setTableData(obj,formatTableDataValuesForTable(obj,inVal.NewState.Data.y));
            end

        end


        function outVal=combineDataForTable(obj,x,y)
            outVal=[x,formatTableDataValuesForTable(obj,y)];
        end


        function setTableData(obj,inData)
            if isvalid(obj.app.UIComponents.UITable)
                obj.app.UIComponents.UITable.Data=inData;
            end
        end


        function storeSelectionChanged(obj,~,e)

            type='vector';

            switch e.Value

            case message('datacreation:datacreation:tableButtonLabel').getString
                storageType='table';
                setColumnNameWidgetsVisible(obj,true);
                setDurationWidgetsVisible(obj,false);
                setVectorTypeDropDownEnable(obj,matlab.lang.OnOffSwitchState.on);
                setDataTypeWidgetEnabled(obj,matlab.lang.OnOffSwitchState.on);
                setColumnNameAndDescription(obj);

                setDataCreationToolsXLabel(obj,'');
                obj.app.UIComponents.StoragePropGrid.RowHeight{2}='fit';
            case message('datacreation:datacreation:timeTableButtonLabel').getString
                storageType='timetable';
                type='timebased';
                setColumnNameWidgetsVisible(obj,true);
                setDurationWidgetsVisible(obj,true);
                setVectorTypeDropDownEnable(obj,matlab.lang.OnOffSwitchState.off);
                setDataTypeWidgetEnabled(obj,matlab.lang.OnOffSwitchState.on);
                setVariableNameAndDescription(obj);

                setDataCreationToolsXLabel(obj,obj.app.UIComponents.DurationDropDown.Value);
                obj.app.UIComponents.StoragePropGrid.RowHeight{2}='fit';

            case message('datacreation:datacreation:timeseriesButtonLabel').getString
                storageType='timeseries';
                type='timebased';
                setColumnNameWidgetsVisible(obj,false);
                setDurationWidgetsVisible(obj,false);
                setVectorTypeDropDownEnable(obj,matlab.lang.OnOffSwitchState.off);
                setDataTypeWidgetEnabled(obj,matlab.lang.OnOffSwitchState.on);

                setDataCreationToolsXLabel(obj,'');


                obj.app.UIComponents.StoragePropGrid.RowHeight{2}=0;
            case message('datacreation:datacreation:dataArrayButtonLabel').getString
                storageType='dataarray';
                type='timebased';
                setColumnNameWidgetsVisible(obj,false);
                setDurationWidgetsVisible(obj,false);
                setVectorTypeDropDownEnable(obj,matlab.lang.OnOffSwitchState.off);
                setDataTypeWidgetEnabled(obj,matlab.lang.OnOffSwitchState.off);

                setDataCreationToolsXLabel(obj,'');

                obj.app.UIComponents.StoragePropGrid.RowHeight{2}=0;
            case message('datacreation:datacreation:vectorButtonLabel').getString
                storageType='vector';
                setColumnNameWidgetsVisible(obj,false);
                setDurationWidgetsVisible(obj,false);
                setVectorTypeDropDownEnable(obj,matlab.lang.OnOffSwitchState.on);
                setDataTypeWidgetEnabled(obj,matlab.lang.OnOffSwitchState.on);

                setDataCreationToolsXLabel(obj,'');
                obj.app.UIComponents.StoragePropGrid.RowHeight{2}=0;
            end

            obj.app.setStateStorageType(storageType);


            onStorageSelectionChanged(obj,type);

        end


        function dataTypeValueChanged(obj,~,evt)

            valueToSet=evt.Value;
            switch(valueToSet)
            case message('datacreation:datacreation:doubleDataType').getString
                valueToSet='double';
            case message('datacreation:datacreation:singleDataType').getString
                valueToSet='single';
            case message('datacreation:datacreation:uint8DataType').getString
                valueToSet='uint8';
            case message('datacreation:datacreation:int8DataType').getString
                valueToSet='int8';
            case message('datacreation:datacreation:uint16DataType').getString
                valueToSet='uint16';
            case message('datacreation:datacreation:int16DataType').getString
                valueToSet='int16';
            case message('datacreation:datacreation:uint32DataType').getString
                valueToSet='uint32';
            case message('datacreation:datacreation:int32DataType').getString
                valueToSet='int32';
            case message('datacreation:datacreation:uint64DataType').getString
                valueToSet='uint64';
            case message('datacreation:datacreation:int64DataType').getString
                valueToSet='int64';
            case message('datacreation:datacreation:halfDataType').getString
                valueToSet='half';
            end


            obj.app.setStateDataType(valueToSet);
            appNotifyChanged(obj.app);
        end


        function vectorTypeValueChanged(obj,~,evt)

            switch evt.Value
            case message('datacreation:datacreation:vectorTypeRow').getString
                obj.app.setVectorType('Row');
            otherwise
                obj.app.setVectorType('Column');
            end
            appNotifyChanged(obj.app);
        end


        function columnNameValueChanged(obj,~,evt)

            varName=matlab.lang.makeValidName(evt.Value);

            if~strcmp(varName,evt.Value)
                obj.app.UIComponents.ColumnNameField.Value=varName;
            end


            try

                x=timetable(seconds(1),1);
                x.Properties.VariableNames{1}=varName;
                obj.app.UIComponents.ColumnNameField.BackgroundColor='white';
                obj.app.UIComponents.ColumnNameField.Tooltip='';
            catch ME_TimeTableName

                setEditFieldErrorState(obj,obj.app.UIComponents.ColumnNameField,...
                ME_TimeTableName.message);
                return;
            end

            obj.app.setColumnName(varName);
            isTimeBased=strcmp(obj.app.getState().StorageType,'timetable')||...
            strcmp(obj.app.getState().StorageType,'timeseries')||...
            strcmp(obj.app.getState().StorageType,'dataarray');
            appStateData.isTimeBased=isTimeBased;
            appStateData.StorageType=obj.app.getState().StorageType;
            appStateData.ColumnName=varName;
            datacreation.internal.UIDecorator.decorateUITableHeaders(appStateData,obj.app.UIComponents.UITable);
            appNotifyChanged(obj.app);
        end


        function durationValueChanged(obj,~,evt)

            switch evt.Value
            case message('datacreation:datacreation:secondsDurationType').getString
                durationToUse='seconds';
            case message('datacreation:datacreation:minutesDurationType').getString
                durationToUse='minutes';
            case message('datacreation:datacreation:hoursDurationType').getString
                durationToUse='hours';
            case message('datacreation:datacreation:daysDurationType').getString
                durationToUse='days';
            case message('datacreation:datacreation:yearsDurationType').getString
                durationToUse='years';
            end

            obj.app.setDuration(durationToUse);
            setDataCreationToolsXLabel(obj,obj.app.UIComponents.DurationDropDown.Value);
            appNotifyChanged(obj.app);
        end


        function displayPlotValueChanged(obj,~,evt)
            obj.app.setPlotOutput(evt.Value);
            appNotifyChanged(obj.app);
        end


        function setColumnNameWidgetsVisible(obj,isVisible)
            obj.app.UIComponents.ColumnNameLabel.Visible=isVisible;
            obj.app.UIComponents.ColumnNameField.Visible=isVisible;
        end


        function setDurationWidgetsVisible(obj,isVisible)
            obj.app.UIComponents.TimeDurationLabel.Visible=isVisible;
            obj.app.UIComponents.DurationDropDown.Visible=isVisible;
        end


        function setTableColumnFormatSequence(obj)
            obj.app.UIComponents.UITable.ColumnFormat={'numeric'};
            obj.app.UIComponents.UITable.ColumnEditable=[true];
        end


        function setDataCreationToolsXLabel(obj,labelIn)
            obj.app.UIComponents.DrawDataWidget.XLabel=labelIn;
        end


        function setEditFieldErrorState(obj,editField,tooltip)
            editField.BackgroundColor='red';
            editField.Tooltip=tooltip;
        end

    end


    methods(Hidden)

        function setDataTypeWidgetEnabled(obj,inVal)
            obj.app.UIComponents.DataTypeDropDown.Enable=inVal;
        end


        function setVectorTypeDropDownEnable(obj,inVal)

            obj.app.UIComponents.VectorTypeDropDown.Enable=inVal;

        end


        function setColumnNameAndDescription(obj)

            obj.app.UIComponents.ColumnNameLabel.Text=...
            message('datacreation:datacreation:tableVarName').getString;
            obj.app.UIComponents.ColumnNameField.Tooltip=...
            message('datacreation:datacreation:tableVarNameEditTip').getString;

        end


        function setVariableNameAndDescription(obj)

            obj.app.UIComponents.ColumnNameLabel.Text=...
            message('datacreation:datacreation:timetableVarName').getString;
            obj.app.UIComponents.ColumnNameField.Tooltip=...
            message('datacreation:datacreation:timetableVarNameEditTip').getString;

        end


        function outDataVals=formatTableDataValuesForTable(~,inDataVals)
            outDataVals=inDataVals;
        end


        function updateScopeFromAppState(obj)
            obj.app.UIComponents.DrawDataWidget.Value=obj.app.getState().Data;
        end

    end


    methods(Access=protected)


        function onStorageSelectionChanged(obj,newType)

            obj.app.UIComponents.DrawDataWidget.XRulerType=newType;

            dataXYValues=obj.app.getState().Data;
            if strcmpi(newType,'timebased')

                if strcmp(obj.app.getState().StorageType,'timetable')

                    obj.app.UIComponents.UITable.ColumnName={...
                    message('datacreation:datacreation:tableTimeColumn').getString...
                    ,obj.app.getState().ColumnName...
                    };
                else

                    obj.app.UIComponents.UITable.ColumnName={...
                    message('datacreation:datacreation:tableTimeColumn').getString...
                    ,message('datacreation:datacreation:tableDataColumn').getString...
                    };
                end

                if~isempty(dataXYValues)
                    obj.app.UIComponents.UITable.Data=concatDataForTable(obj,...
                    dataXYValues.x,formatTableDataValuesForTable(obj,dataXYValues.y));

                end
                setTableColumnFormatTimeBased(obj);
            else

                obj.app.UIComponents.UITable.ColumnName={...
                message('datacreation:datacreation:tableDataColumn').getString...
                };
                if~isempty(dataXYValues)
                    obj.app.UIComponents.UITable.Data=formatTableDataValuesForTable(obj,dataXYValues.y);

                end
                setTableColumnFormatSequence(obj);
            end
            appNotifyChanged(obj.app);
        end


        function outData=concatDataForTable(~,x,y)
            outData=[x,y];
        end




        function setTableColumnFormatTimeBased(obj)
            obj.app.UIComponents.UITable.ColumnFormat={'numeric','numeric'};
            obj.app.UIComponents.UITable.ColumnEditable=[true,true];
        end


        function onTableDataChange(obj,src,evt)%#ok<INUSD>

            [M,N]=size(src.Data);%#ok<ASGLU>
            if N==1

                newData.x=obj.app.getState().Data.x;
                newData.y=src.Data;

            else

                newData=getSortedDataAndUpdateTable(obj,src);

            end

            newData=conditionTableFromData(obj,newData);

            obj.app.setStateData(newData);

            obj.updateScopeFromAppState();
            appNotifyChanged(obj.app);
        end

        function newData=getSortedDataAndUpdateTable(obj,src)

            [sortedTimes,idx]=sort(src.Data(:,1));
            sortedData=src.Data(idx,2);

            newData.x=sortedTimes;
            newData.y=sortedData;


            obj.app.UIComponents.UITable.Data=[newData.x,newData.y];
        end


        function outData=conditionTableFromData(~,newData)
            outData=newData;
        end




        function onTableCellEdit(~,src,evt)

            r=evt.Indices(1);
            c=evt.Indices(2);
            if~isnumeric(evt.EditData)

                try
                    evaledEntry=eval(evt.EditData);

                    if isnumeric(evaledEntry)&&~isreal(evaledEntry)

                        if iscell(src.Data)
                            src.Data{r,c}=evt.PreviousData;
                        else
                            src.Data(r,c)=evt.PreviousData;
                        end
                    end

                catch
                    if iscell(src.Data)
                        src.Data{r,c}=evt.PreviousData;
                    else
                        src.Data(r,c)=evt.PreviousData;
                    end
                end

            end

        end


        function onKeyPressFcn(obj,src,evt)


        end





        function onCellSelectionCallback(obj,src,evt)



            if~isempty(evt.Indices)


                selectedIndices=unique(evt.Indices(:,1));
                obj.app.UIComponents.DrawDataWidget.setAndPublishSelectedIndices(selectedIndices);
            else
                obj.app.UIComponents.DrawDataWidget.setAndPublishSelectedIndices([]);
            end
        end

    end
end
