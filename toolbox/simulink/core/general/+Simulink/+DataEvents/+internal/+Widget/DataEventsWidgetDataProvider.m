classdef DataEventsWidgetDataProvider<mdom.BaseDataProvider %#ok<*ST2NM>

    properties(SetObservable=true)
        DataArray={}
BlockHandle
ModelHandle
deadlineTimeErrorID
        deadlineTimeErrorEntry;
        errorID='';
    end

    properties(Hidden,Constant)
        NumColumns=3
    end

    methods

        function this=DataEventsWidgetDataProvider(blockHandle,modelHandle)
            this.BlockHandle=blockHandle;
            this.ModelHandle=modelHandle;
            this.updateInfo;
        end


        function updateInfo(obj)

            inputEvents=get_param(obj.BlockHandle,'EventTriggers');
            numInputEvents=length(inputEvents);
            obj.DataArray=cell(numInputEvents,1);
            for i=1:length(obj.DataArray)
                cellData=cell(1,obj.NumColumns);
                ev=inputEvents{i};


                switch(class(ev))
                case 'simulink.event.InputWrite'
                    cellData{1}=message('SimulinkPartitioning:DataEvents:InputWrite').getString();
                case 'simulink.event.InputWriteLost'
                    cellData{1}=message('SimulinkPartitioning:DataEvents:InputWriteLost').getString();
                case 'simulink.event.InputWriteTimeout'
                    cellData{1}=message('SimulinkPartitioning:DataEvents:InputWriteTimeout').getString();
                otherwise
                    error('Invalid Input Event');
                end





                if(strcmp(ev.EventName,'Auto'))
                    cellData{2}=message('SimulinkPartitioning:DataEvents:AutoOption').getString();
                else
                    cellData{2}=ev.EventName;
                end
                obj.DataArray{i}=cellData;


                if(isa(ev,'simulink.event.InputWriteTimeout'))
                    if(isempty(obj.errorID))
                        cellData{3}=num2str(ev.Timeout);
                    else
                        cellData{3}=obj.deadlineTimeErrorEntry;
                    end
                else
                    cellData{3}='';
                end
                obj.DataArray{i}=cellData;
            end
        end


        function requestData(obj,event)

            colList=event.ColumnInfoRequests;
            colInfo=mdom.ColumnInfo(colList);
            for col=1:length(colList)
                meta=mdom.MetaData;

                widthMeta=mdom.MetaData;
                widthMeta.setProp('unit','%');
                switch colList(col)
                case 0
                    meta.setProp('sortType','StringSort');
                    inputEventLabel=message('SimulinkPartitioning:DataEvents:EventTrigger').getString();
                    meta.setProp('label',inputEventLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    widthMeta.setProp('value',40);

                case 1
                    sltpEventLabel=message('SimulinkPartitioning:DataEvents:ScheduleEvent').getString();
                    meta.setProp('label',sltpEventLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','ComboboxEditor');
                    item=mdom.MetaData;
                    item.registerDataType('value',...
                    mdom.MetaDataType.STRING);


                    try
                        sltpEvents=get_param(obj.ModelHandle,'Schedule');
                        sltpEvents=sltpEvents.Events;
                    catch
                        sltpEvents=[];
                    end




                    sltpEvents=sltpEvents(arrayfun(@(x)logical(x.Scope()=='Scoped')...
                    &&~contains(x.Name,'.'),sltpEvents));



                    len=length(sltpEvents)+1;
                    items=mdom.MetaData.empty(0,len);


                    auto_setting=message('SimulinkPartitioning:DataEvents:AutoOption').getString();
                    item.setProp('value',auto_setting);
                    item.setProp('label',auto_setting);
                    items(1)=item;
                    item.clear();



                    for idx=1:numel(sltpEvents)
                        item.setProp('value',sltpEvents(idx).Name);
                        item.setProp('label',sltpEvents(idx).Name);
                        items(idx+1)=item;
                        item.clear();
                    end
                    meta.setProp('items',items);
                    widthMeta.setProp('value',30);
                case 2
                    deadlineTimeLabel=message('SimulinkPartitioning:DataEvents:Timeout').getString();
                    meta.setProp('label',deadlineTimeLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    widthMeta.setProp('value',30);

                end

                meta.setProp('width',widthMeta);
                colInfo.fillMetaData(colList(col),meta);
            end
            event.addColumnInfo(colInfo);


            ranges=event.RangeRequests;
            for idx=1:length(ranges)
                rangeData=mdom.RangeData(ranges(idx));
                data=mdom.Data;

                for row=ranges(idx).RowStart:ranges(idx).RowEnd
                    for col=ranges(idx).ColumnStart:ranges(idx).ColumnEnd
                        data.clear();

                        data.setProp('label',obj.getCellData(row,col));




                        if(col==0&&strcmp(obj.getCellData(row,col),...
                            message('SimulinkPartitioning:DataEvents:InputWrite').getString()))


                            pc=get_param(obj.BlockHandle,'PortConnectivity');
                            destBlock=pc.DstBlock;

                            if(~isempty(destBlock))

                                orig_state=warning;
                                warning('off','Simulink:Commands:FindSystemDefaultVariantsOptionWithVariantModel');
                                oc=onCleanup(@()warning(orig_state));
                                triggerPort=find_system(destBlock,'BlockType','TriggerPort');

                                if(~isempty(triggerPort))
                                    if(strcmp(get_param(triggerPort,'TriggerType'),'message'))
                                        meta=mdom.MetaData;
                                        meta.setProp('renderer','IconLabelRenderer');
                                        meta.setProp('editor','none');
                                        rangeData.fillMetaData(row,1,meta);
                                    end
                                end
                            end
                        end



                        if(col==0&&strcmp(obj.getCellData(row,col),...
                            message('SimulinkPartitioning:DataEvents:InputWriteTimeout').getString()))
                            meta=mdom.MetaData;
                            meta.setProp('editor','DefaultEditor');
                            if(~isempty(obj.errorID))

                                rendererConfig=mdom.MetaData;
                                rendererConfig.setProp('notification',obj.errorID);
                                meta.setProp('rendererConfig',rendererConfig);
                            end
                            rangeData.fillMetaData(row,2,meta);
                        end


                        rangeData.fillData(row,col,data);
                    end
                end
                event.addRangeData(rangeData);
            end


            rowList=event.RowInfoRequests;
            rowInfo=mdom.RowInfo(rowList);
            for row=1:length(rowList)
                rowIndex=rowList(row);


                rowInfo.setRowID(rowIndex,int2str(rowIndex.RowIndex));

                rowInfo.setRowExpanded(rowIndex,false);

                rowInfo.setRowHasChild(rowIndex,mdom.HasChild.NO);
            end

            event.addRowInfo(rowInfo);


            event.send();
        end


        function onEditComplete(obj,rowid,col,data)
            try
                if strcmp(get_param(obj.BlockHandle,'BlockType'),...
                    'Inport')
                    dm=mdom.DataModel.findDataModel(obj.DataModelID);
                    if~isempty(dm)
                        value=jsondecode(data);

                        row=str2double(rowid);

                        switch col
                        case 1
                            inputEvents=get_param(obj.BlockHandle,'EventTriggers');
                            inputEventTrigger=inputEvents{row+1};



                            auto_setting=message('SimulinkPartitioning:DataEvents:AutoOption').getString();
                            if(strcmp(value,auto_setting))
                                value='Auto';
                            end
                            inputEventTrigger.EventName=value;
                            inputEvents{row+1}=inputEventTrigger;
                            set_param(obj.BlockHandle,'EventTriggers',inputEvents);

                        case 2
                            inputEvents=get_param(obj.BlockHandle,'EventTriggers');
                            inputEventTrigger=inputEvents{row+1};
                            if(isa(inputEventTrigger,'simulink.event.InputWriteTimeout'))
                                if(~isempty(str2num(value.label))&&...
                                    numel(str2num(value.label))==1&&...
                                    str2num(value.label)>0&&...
                                    isreal(str2num(value.label)))


                                    inputEventTrigger.Timeout=num2str(str2num(value.label));
                                    inputEvents{row+1}=inputEventTrigger;
                                    set_param(obj.BlockHandle,'EventTriggers',inputEvents);


                                    if~isempty(obj.errorID)
                                        obj.errorID='';
                                        obj.deadlineTimeErrorEntry='';
                                    end
                                else

                                    obj.errorID=obj.deadlineTimeErrorID;
                                    obj.deadlineTimeErrorEntry=value.label;
                                end
                            end
                        end


                        obj.updateInfo;
                        dm.refreshView;
                    end
                end
            catch me
                sldiagviewer.reportError(me);
            end
        end


        function onSortRequest(obj,sortOptions)
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            if~isempty(dm)
                sortOption=jsondecode(sortOptions);
                sortOrder='ascend';
                if strcmp(sortOption.order,'DESC')
                    sortOrder='descend';
                end

                switch sortOption.columnIndex
                case 0
                    colIdx=sortOption.columnIndex+1;
                    col=cellfun(@(a)a(1,colIdx),obj.DataArray,...
                    'UniformOutput',1);
                    [~,sortedIndex]=sortrows(lower(col),1,sortOrder);
                    obj.DataArray=obj.DataArray(sortedIndex);
                end


                dm.refreshView();
            end
        end


        function data=getCellData(obj,row,col)

            data=obj.DataArray{row+1}{col+1};
        end


        function setCellData(obj,row,col,value)

            obj.DataArray{row+1}{col+1}=value;
        end


    end

end