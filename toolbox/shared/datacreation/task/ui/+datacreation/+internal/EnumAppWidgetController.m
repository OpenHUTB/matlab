classdef(Hidden)EnumAppWidgetController<datacreation.internal.AppWidgetController





    methods(Hidden)


        function bindDataTypeCallback(obj)
            obj.app.UIComponents.EnumEditField.ValueChangedFcn=...
            @(src,evt)obj.dataTypeValueChanged(src,evt);
        end


        function dataTypeValueChanged(obj,~,evt)


            [enumObject,~]=...
            datacreation.internal.DataTypeHelper.getEnumerationDefinitionByName(evt.Value);
            newDataValues=[];
            if isempty(enumObject)||isempty(fieldnames(enumObject))
                setEditFieldErrorState(obj,obj.app.UIComponents.EnumEditField,message('datacreation:datacreation:enumEditFieldErrorTip',evt.Value).getString);
                return;
            else

                try

                    fcnH=str2func(evt.Value);
                    newDataValues=fcnH(obj.app.getState.Data.y);
                catch ME_CAST_FAIL
                    setEditFieldErrorState(obj,obj.app.UIComponents.EnumEditField,message('datacreation:datacreation:enumDataDefMisMatch',evt.Value).getString);
                    return;
                end

                obj.app.UIComponents.EnumEditField.BackgroundColor='white';
                obj.app.UIComponents.EnumEditField.Tooltip=message('datacreation:datacreation:enumEditFieldTip').getString;

                theFields=fieldnames(enumObject);

                N=length(theFields);
                theEnumVals=cell(1,N);
                for kField=1:N
                    theEnumVals{kField}=num2str(double(enumObject.(theFields{kField})));
                end
                updateTableColumnFormat(obj.app,theEnumVals);
            end


            obj.app.setStateDataType(evt.Value);
            if~isempty(newDataValues)
                tempState=obj.app.getState;
                tempState.Data.y=double(newDataValues);
                obj.app.setState(tempState);
            end

            msg.isEnum=true;

            msg.enumerationDef=enumObject;
            msg.enumerationName=evt.Value;
            obj.app.UIComponents.DrawDataWidget.setYRulerType(msg);
            obj.app.UIComponents.DrawDataWidget.Value.y=double(newDataValues);
            appNotifyChanged(obj.app);
        end


        function updateTableDataAfterDrawUpdate(obj,inVal)

            if strcmpi(obj.app.UIComponents.DrawDataWidget.XRulerType,'timebased')
                setTableData(obj,[num2cell(inVal.NewState.Data.x),formatTableDataValuesForTable(obj,inVal.NewState.Data.y)]);
            else
                setTableData(obj,formatTableDataValuesForTable(obj,inVal.NewState.Data.y));
            end

        end


        function setTableColumnFormatSequence(obj)
            enumVals=getEnumStrings(obj);
            obj.app.UIComponents.UITable.ColumnFormat={enumVals};
            obj.app.UIComponents.UITable.ColumnEditable=true;
        end


        function outDataVals=formatTableDataValuesForTable(obj,inDataVals)

            fcnH=str2func(obj.app.getState.DataType);
            outDataVals=cellstr(string(fcnH(inDataVals)));
        end


        function updateScopeFromAppState(obj)

            fcnH=str2func(obj.app.getState().DataType);
            lineData.y=double(fcnH(obj.app.getState().Data.y));
            lineData.x=obj.app.getState().Data.x;

            obj.app.UIComponents.DrawDataWidget.Value=lineData;
        end


        function setTableColumnFormatByState(obj,inState)

            if datacreation.contributor.NumericalContributor.isTimeBasedType(inState.StorageType)
                setTableColumnFormatTimeBased(obj);
            else
                setTableColumnFormatSequence(obj);
            end
        end
    end


    methods(Access=protected)

        function setTableColumnFormatTimeBased(obj)
            enumVals=getEnumStrings(obj);
            obj.app.UIComponents.UITable.ColumnFormat={'numeric',enumVals};
            obj.app.UIComponents.UITable.ColumnEditable=[true,true];
        end


        function enumVals=getEnumStrings(obj)
            enumVals=cellstr(string(enumeration(obj.app.getState.DataType)))';
        end


        function outData=conditionTableFromData(obj,newData)
            fcnH=str2func(obj.app.getState.DataType);
            outData.x=newData.x;
            outData.y=fcnH(newData.y);
        end


        function outData=concatDataForTable(obj,x,y)
            outData=[num2cell(x),y];
        end


        function onTableCellEdit(obj,src,evt)
            if(evt.Indices(2)==1)&&strcmpi(obj.app.UIComponents.DrawDataWidget.XRulerType,'timebased')
                onTableCellEdit@datacreation.internal.AppWidgetController(obj,src,evt);
                return;
            end
            r=evt.Indices(1);
            c=evt.Indices(2);
            if c==1
                columnFormat=evt.Source.ColumnFormat{1};
            else
                columnFormat=evt.Source.ColumnFormat{2};
            end



            if~any(strcmp(columnFormat,evt.EditData))

                if iscell(src.Data)
                    src.Data{r,c}=evt.PreviousData;
                else
                    src.Data(r,c)=evt.PreviousData;
                end
            end
        end


        function onTableDataChange(obj,src,evt)

            [M,N]=size(src.Data);
            if N==1

                newData.x=obj.app.getState().Data.x;
                newData.y=src.Data;

            else


                [sortedTimes,idx]=sort(vertcat(src.Data{:,1}));
                sortedData={src.Data{idx,2}}';

                newData.x=sortedTimes;
                newData.y=sortedData;

                numPts=length(newData.x);
                result=cell(numPts,2);
                for k=1:numPts
                    result{k,1}=newData.x(k);
                    result{k,2}=newData.y{k};

                end


                obj.app.UIComponents.UITable.Data=result;
            end

            newData=conditionTableFromData(obj,newData);

            obj.app.setStateData(newData);

            obj.updateScopeFromAppState();
            appNotifyChanged(obj.app);
        end
    end

end
