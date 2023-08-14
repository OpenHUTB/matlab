classdef PortsEditorDataProvider<mdom.BaseDataProvider %#ok<*ST2NM>

    properties(SetObservable=true)
        DataArray={}
BlockHandle
        CustomDataTypes=string.empty(0,1)
        CustomSampleTimes=string.empty(0,1)
        FilterIndex=[]
        FilterValue=''
        SortInfo=[]
    end

    properties(Hidden,Constant)
        ComplexityDefaults=["auto","real","complex"]
        DataTypeDefaults=["Inherit: auto","double","single","half",...
        "int8","uint8","int16","uint16","int32","uint32","int64",...
        "uint64","string","boolean","fixdt(1,16,0)","fixdt(1,16,2^0,0)"]
        DimModeDefaults=["auto","Fixed","Variable"]
        NumColumns=8
        SampleTimeDefaults=["-1","0","inf"]
    end

    methods

        function this=PortsEditorDataProvider(blockHandle)
            this.BlockHandle=blockHandle;
            this.updateInfo;
        end


        function updateInfo(obj)

            numPorts=get_param(obj.BlockHandle,'NumPorts');
            signalIds=str2num(get_param(obj.BlockHandle,'SignalIds'));
            dataType=get_param(obj.BlockHandle,'OutDataTypeStr');
            complexity=get_param(obj.BlockHandle,'PortComplexity');
            units=get_param(obj.BlockHandle,'PortUnits');
            sampleTimes=get_param(obj.BlockHandle,'PortSampleTimes');
            dimensions=get_param(obj.BlockHandle,'PortDimensions');
            dimModes=get_param(obj.BlockHandle,'PortDimsModes');
            obj.DataArray=cell(numPorts,1);
            for i=1:length(obj.DataArray)
                cellData=cell(1,obj.NumColumns);

                cellData{1}=num2str(i);

                if i<=length(signalIds)&&signalIds(i)>0
                    cellData{2}=Simulink.sdi.getSignal(signalIds(i)).Name;
                else
                    cellData{2}='';
                end

                cellData{3}=char(dataType(i));

                if~any(strcmpi(obj.DataTypeDefaults,cellData{3}))
                    obj.CustomDataTypes(i)=cellData{3};
                else
                    obj.CustomDataTypes(i)="";
                end

                cellData{4}=char(complexity(i));

                cellData{5}=char(units(i));

                cellData{6}=char(sampleTimes(i));

                if~any(strcmpi(obj.SampleTimeDefaults,cellData{6}))
                    obj.CustomSampleTimes(i)=cellData{6};
                else
                    obj.CustomSampleTimes(i)="";
                end

                dims=strjoin(arrayfun(@(x)num2str(x),dimensions{i},...
                'UniformOutput',false),', ');
                if~isempty(dims)
                    cellData{7}=['[',dims,']'];
                else
                    cellData{7}=num2str(dimensions{i});
                end

                cellData{8}=char(dimModes(i));
                obj.DataArray{i}=cellData;
            end
        end


        function requestData(obj,ev)

            colList=ev.ColumnInfoRequests;
            colInfo=mdom.ColumnInfo(colList);
            for c=1:length(colList)
                meta=mdom.MetaData;

                widthMeta=mdom.MetaData;
                widthMeta.setProp('unit','%');
                switch colList(c)
                case 0
                    meta.setProp('sortType','IntSort');
                    portLabel=DAStudio.message(...
                    'record_playback:dialogs:PortLabel');
                    meta.setProp('label',portLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    widthMeta.setProp('value',8);

                case 1
                    meta.setProp('sortType','StringSort');
                    sigSrcLabel=DAStudio.message(...
                    'record_playback:dialogs:SignalSourceLabel');
                    meta.setProp('label',sigSrcLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    widthMeta.setProp('value',16);

                case 2
                    meta.setProp('sortType','StringSort');
                    dataTypeLabel=DAStudio.message(...
                    'record_playback:dialogs:DataTypeLabel');
                    meta.setProp('label',dataTypeLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','ComboboxEditor');
                    meta.setProp('editable','true');
                    item=mdom.MetaData;
                    item.registerDataType('value',...
                    mdom.MetaDataType.STRING);

                    dataTypes=obj.DataTypeDefaults;
                    if~isempty(obj.CustomDataTypes)
                        nonEmptyCustomValues=obj.CustomDataTypes(...
                        ~strcmp(obj.CustomDataTypes,""));
                        if length(nonEmptyCustomValues)>1
                            dataTypes=[obj.DataTypeDefaults,...
                            unique(nonEmptyCustomValues)];
                        else
                            dataTypes=[obj.DataTypeDefaults,...
                            nonEmptyCustomValues];
                        end
                    end
                    len=length(dataTypes);
                    items=mdom.MetaData.empty(0,len);
                    for idx=1:len
                        item.setProp('value',dataTypes(idx));
                        item.setProp('label',dataTypes(idx));
                        items(idx)=item;
                        item.clear();
                    end
                    meta.setProp('items',items);
                    widthMeta.setProp('value',12);

                case 3
                    meta.setProp('sortType','StringSort');
                    complexityLabel=DAStudio.message(...
                    'record_playback:dialogs:ComplexityLabel');
                    meta.setProp('label',complexityLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','ComboboxEditor');
                    item=mdom.MetaData;
                    item.registerDataType('value',...
                    mdom.MetaDataType.STRING);
                    len=length(obj.ComplexityDefaults);
                    items=mdom.MetaData.empty(0,len);
                    for idx=1:len
                        item.setProp('value',obj.ComplexityDefaults(idx));
                        item.setProp('label',obj.ComplexityDefaults(idx));
                        items(idx)=item;
                        item.clear();
                    end
                    meta.setProp('items',items);
                    widthMeta.setProp('value',12);

                case 4
                    meta.setProp('sortType','StringSort');
                    unitsLabel=DAStudio.message(...
                    'record_playback:dialogs:UnitsLabel');
                    meta.setProp('label',unitsLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','DefaultEditor');
                    widthMeta.setProp('value',12);

                case 5
                    meta.setProp('sortType','StringSort');
                    stLabel=DAStudio.message(...
                    'record_playback:dialogs:SampleTimeLabel');
                    meta.setProp('label',stLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','ComboboxEditor');
                    meta.setProp('editable','true');
                    item=mdom.MetaData;
                    item.registerDataType('value',...
                    mdom.MetaDataType.STRING);

                    sampleTimeTypes=obj.SampleTimeDefaults;
                    if~isempty(obj.CustomSampleTimes)
                        nonEmptyCustomValues=obj.CustomSampleTimes(...
                        ~strcmp(obj.CustomSampleTimes,""));
                        if length(nonEmptyCustomValues)>1
                            sampleTimeTypes=[obj.SampleTimeDefaults,...
                            unique(nonEmptyCustomValues)];
                        else
                            sampleTimeTypes=[obj.SampleTimeDefaults,...
                            nonEmptyCustomValues];
                        end
                    end
                    len=length(sampleTimeTypes);
                    items=mdom.MetaData.empty(0,len);
                    for idx=1:len
                        item.setProp('value',sampleTimeTypes(idx));
                        item.setProp('label',sampleTimeTypes(idx));
                        items(idx)=item;
                        item.clear();
                    end
                    meta.setProp('items',items);
                    widthMeta.setProp('value',12);

                case 6
                    meta.setProp('sortType','StringSort');
                    dimensionsLabel=DAStudio.message(...
                    'record_playback:dialogs:DimensionsLabel');
                    meta.setProp('label',dimensionsLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','DefaultEditor');
                    widthMeta.setProp('value',12);

                case 7
                    meta.setProp('sortType','StringSort');
                    dimModeLabel=DAStudio.message(...
                    'record_playback:dialogs:DimensionModeLabel');
                    meta.setProp('label',dimModeLabel);
                    meta.setProp('renderer','IconLabelRenderer');
                    meta.setProp('editor','ComboboxEditor');
                    item=mdom.MetaData;
                    item.registerDataType('value',...
                    mdom.MetaDataType.STRING);
                    len=length(obj.DimModeDefaults);
                    items=mdom.MetaData.empty(0,len);
                    for idx=1:len
                        item.setProp('value',obj.DimModeDefaults(idx));
                        item.setProp('label',obj.DimModeDefaults(idx));
                        items(idx)=item;
                        item.clear();
                    end

                    meta.setProp('items',items);
                    widthMeta.setProp('value',16);
                end

                meta.setProp('width',widthMeta);
                colInfo.fillMetaData(colList(c),meta);
            end




            if~isempty(obj.SortInfo)
                colInfo.sortedColumn(obj.SortInfo.column,obj.SortInfo.order);
            end
            ev.addColumnInfo(colInfo);


            ranges=ev.RangeRequests;
            for i=1:length(ranges)
                rangeData=mdom.RangeData(ranges(i));
                data=mdom.Data;

                for r=ranges(i).RowStart:ranges(i).RowEnd
                    for c=ranges(i).ColumnStart:ranges(i).ColumnEnd
                        data.clear();

                        if~isempty(obj.FilterIndex)
                            row=obj.FilterIndex(r+1)-1;
                        else
                            row=r;
                        end
                        data.setProp('label',obj.getCellData(row,c));
                        rangeData.fillData(r,c,data);
                    end
                end
                ev.addRangeData(rangeData);
            end


            rowList=ev.RowInfoRequests;
            rowInfo=mdom.RowInfo(rowList);
            for r=1:length(rowList)
                rowIndex=rowList(r);


                rowInfo.setRowID(rowIndex,int2str(rowIndex.RowIndex));

                rowInfo.setRowExpanded(rowIndex,false);

                rowInfo.setRowHasChild(rowIndex,mdom.HasChild.NO);
            end

            ev.addRowInfo(rowInfo);


            ev.send();
        end


        function onEditComplete(obj,rowid,col,data)
            try
                if strcmp(get_param(obj.BlockHandle,'BlockType'),...
                    'Playback')
                    dm=mdom.DataModel.findDataModel(obj.DataModelID);
                    if~isempty(dm)
                        value=jsondecode(data);
                        row=str2double(rowid);

                        if~isempty(obj.FilterIndex)
                            row=obj.FilterIndex(row+1)-1;
                        end

                        switch col
                        case 2
                            dType=obj.getColumnData(row,col,value);
                            set_param(obj.BlockHandle,...
                            'OutDataTypeStr',dType);

                        case 3
                            comp=obj.getColumnData(row,col,value);
                            set_param(obj.BlockHandle,...
                            'PortComplexity',comp);

                        case 4
                            units=obj.getColumnData(row,col,...
                            value.label);
                            set_param(obj.BlockHandle,...
                            'PortUnits',units);

                        case 5
                            sTimes=obj.getColumnData(row,col,value);
                            set_param(obj.BlockHandle,...
                            'PortSampleTimes',sTimes);

                        case 6
                            dims=obj.getColumnData(row,col,...
                            value.label);
                            dim=cellfun(@str2num,dims,...
                            'UniformOutput',false);
                            set_param(obj.BlockHandle,...
                            'PortDimensions',dim);

                        case 7
                            dModes=obj.getColumnData(row,col,value);
                            set_param(obj.BlockHandle,...
                            'PortDimsModes',dModes);
                        end
                    end
                end
            catch me
                sldiagviewer.reportError(me);
            end
        end


        function data=getCellData(obj,row,col)

            data=obj.DataArray{row+1}{col+1};
        end


        function setCellData(obj,row,col,value)

            obj.DataArray{row+1}{col+1}=value;
        end


        function onSortRequest(obj,sortOptions)
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            if~isempty(dm)
                sortOption=jsondecode(sortOptions);
                if~isempty(obj.SortInfo)
                    obj.SortInfo=struct;
                end
                obj.SortInfo.column=sortOption.columnIndex;
                sortOrder='ascend';
                obj.SortInfo.order='asc';
                if strcmp(sortOption.order,'DESC')
                    sortOrder='descend';
                    obj.SortInfo.order='desc';
                end

                switch sortOption.columnIndex
                case 0
                    colIdx=sortOption.columnIndex+1;


                    col=cellfun(@(a)str2double(a(1,colIdx)),...
                    obj.DataArray,'UniformOutput',1);
                    [~,sortedIndex]=sortrows(col,1,sortOrder);
                    obj.DataArray=obj.DataArray(sortedIndex);

                case{1,2,3,4,5,6,7}
                    colIdx=sortOption.columnIndex+1;
                    col=cellfun(@(a)a(1,colIdx),obj.DataArray,...
                    'UniformOutput',1);
                    [~,sortedIndex]=sortrows(lower(col),1,sortOrder);
                    obj.DataArray=obj.DataArray(sortedIndex);
                end


                if~isempty(obj.FilterValue)
                    obj.updateFilterIndex();
                end


                dm.refreshView();
            end
        end


        function onFilterRequest(obj,criteria)
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            if~isempty(dm)
                c=jsondecode(criteria);
                numPorts=get_param(obj.BlockHandle,'NumPorts');
                obj.FilterValue=c.value;
                if isempty(obj.FilterValue)

                    obj.FilterIndex=[];


                    dm.rowChanged('',numPorts,{});


                    dm.clearSearch();
                else

                    sCriteria=mdom.MetaData;
                    sCriteria.setProp('searchValue',c.value);


                    obj.updateFilterIndex();


                    dm.rowChanged('',length(obj.FilterIndex),{});


                    dm.search(sCriteria);
                end
            end
        end

    end

    methods(Access=private)

        function updateFilterIndex(obj)
            numPorts=get_param(obj.BlockHandle,'NumPorts');
            i=false(numPorts,1);
            for idx=1:obj.NumColumns
                col=cellfun(@(a)a(1,idx),obj.DataArray);
                iN=cellfun(@(x)contains(x,obj.FilterValue,...
                'IgnoreCase',true),col,'UniformOutput',1);
                i=or(i,iN);
            end

            index=1:numPorts;
            obj.FilterIndex=index(i);
        end


        function colData=getColumnData(obj,row,col,value)

            tempData=obj.DataArray;
            tempData{row+1}{col+1}=value;


            firstCol=cellfun(@(a)str2double(a(1,1)),tempData,...
            'UniformOutput',1);
            [~,sortedIdx]=sortrows(firstCol,1);
            sortedData=tempData(sortedIdx);
            colData=cellfun(@(a)a(1,col+1),sortedData,...
            'UniformOutput',1);
        end
    end

end

