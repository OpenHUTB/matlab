classdef(Hidden)LogicalAppWidgetController<datacreation.internal.AppWidgetController




    methods

        function setTableColumnFormatSequence(obj)
            obj.app.UIComponents.UITable.ColumnFormat={'char'};
            obj.app.UIComponents.UITable.ColumnEditable=true;
        end


        function updateTableDataAfterDrawUpdate(obj,inVal)

            if strcmpi(obj.app.UIComponents.DrawDataWidget.XRulerType,'timebased')
                setTableData(obj,combineDataForTable(obj,inVal.NewState.Data.x,formatTableDataValuesForTable(obj,inVal.NewState.Data.y)));
            else
                setTableData(obj,formatTableDataValuesForTable(obj,inVal.NewState.Data.y));
            end

        end


        function outVal=combineDataForTable(app,x,y)
            outVal=[num2cell(x),y];
        end
    end


    methods(Hidden)


        function bindDataTypeCallback(obj)
            obj.app.UIComponents.DataTypeDropDown.ValueChangedFcn=...
            @(src,evt)obj.dataTypeValueChanged(src,evt);
        end


        function updateScopeFromAppState(obj)

            inData=obj.app.getState().Data;
            inData.y=double(boolean(inData.y));
            obj.app.UIComponents.DrawDataWidget.Value=inData;
        end


        function outDataVals=formatTableDataValuesForTable(~,inDataVals)
            outDataVals=cellstr(string(logical(inDataVals)));
        end

    end


    methods(Access=protected)


        function setTableColumnFormatTimeBased(obj)
            obj.app.UIComponents.UITable.ColumnFormat={'numeric','char'};
            obj.app.UIComponents.UITable.ColumnEditable=[true,true];
        end

        function newData=getSortedDataAndUpdateTable(obj,src)

            [sortedTimes,idx]=sort([src.Data{:,1}]');%#ok<TRSRT>
            sortedData=src.Data(idx,2);

            newData.x=sortedTimes;
            newData.y=sortedData;


            obj.app.UIComponents.UITable.Data=[num2cell(newData.x),newData.y];
        end


        function outData=conditionTableFromData(~,newData)
            outData=newData;
            outData.y=cellfun(@double,cellfun(@str2num,outData.y,'UniformOutput',false));
        end


        function onTableCellEdit(obj,src,evt)

            if(evt.Indices(2)==1)&&strcmpi(obj.app.UIComponents.DrawDataWidget.XRulerType,'timebased')
                onTableCellEdit@datacreation.internal.AppWidgetController(obj,src,evt);
                return;
            end
            r=evt.Indices(1);
            c=evt.Indices(2);

            if~isnumeric(evt.EditData)

                try
                    evaledEntry=eval(evt.EditData);

                    if~islogical(evaledEntry)&&isnumeric(evaledEntry)&&(~isreal(evaledEntry)||...
                        (evaledEntry~=0&&evaledEntry~=1))




                        if iscell(src.Data)
                            src.Data{r,c}=evt.PreviousData;
                        else
                            src.Data(r,c)=evt.PreviousData;
                        end
                    end

                    if isnumeric(evaledEntry)&&isreal(evaledEntry)&&...
                        (evaledEntry==0)||(evaledEntry==1)

                        if iscell(src.Data)
                            src.Data{r,c}=char(string(logical(evaledEntry)));
                        else
                            src.Data(r,c)=char(string(logical(evaledEntry)));
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


        function outData=concatDataForTable(~,x,y)
            outData=[num2cell(x),y];
        end
    end

end
