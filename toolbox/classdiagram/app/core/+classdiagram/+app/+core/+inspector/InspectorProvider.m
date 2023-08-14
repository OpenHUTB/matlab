classdef InspectorProvider<mdom.BaseDataProvider
    properties(SetObservable=true)
PropertySchema

    end

    properties(Constant)
        RootID="_INVISIBLE_ROOT_";
    end


    methods

        function obj=InspectorProvider()
            obj.PropertySchema=[];
        end

        function updateSource(obj,schema)
            obj.PropertySchema=schema;
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            dm.clearExpandState();
            dm.rowChanged('',0,{});
        end


        function requestData(obj,ev)
            if isempty(obj.PropertySchema)
                return;
            end


            colList=ev.ColumnInfoRequests;
            colInfo=mdom.ColumnInfo(colList);
            for c=1:length(colList)
                meta=mdom.MetaData;
                switch colList(c)
                case 0
                    meta.setProp('label',obj.PropertySchema.getDisplayLabel);
                    meta.setProp('renderer','IconLabelRenderer');

                end


                widthMeta=mdom.MetaData;
                widthMeta.setProp('unit','%');
                widthMeta.setProp('value',50);
                meta.setProp('width',widthMeta);

                colInfo.fillMetaData(colList(c),meta);
            end
            ev.addColumnInfo(colInfo);


            rowList=ev.RowInfoRequests;
            rowInfo=mdom.RowInfo(rowList);
            for r=1:length(rowList)
                rIndex=rowList(r);
                pID=rIndex.ParentID;
                subProps=obj.PropertySchema.subProperties(pID);
                if rIndex.RowIndex+1<=length(subProps)
                    prop=subProps(rIndex.RowIndex+1);
                    rowInfo.setRowID(rIndex,prop);

                    info=obj.PropertySchema.propertyInfo(prop);
                    if isstring(info.Value)&&info.Value==""
                        rowInfo.setGroupRow(rIndex,true);
                    end

                    dm=mdom.DataModel.findDataModel(obj.DataModelID);
                    if dm.isRowExpanded(dm.getIDForIndex(rIndex))
                        rowInfo.setRowExpanded(rIndex,true);
                        rowInfo.setRowHasChild(rIndex,mdom.HasChild.YES);
                    elseif obj.PropertySchema.hasSubProperties(prop)
                        rowInfo.setRowHasChild(rIndex,mdom.HasChild.YES);
                    end
                end
            end
            ev.addRowInfo(rowInfo);


            ranges=ev.RangeRequests;
            for i=1:length(ranges)
                rangeData=mdom.RangeData(ranges(i));
                pID=ranges(i).ParentID;
                subProps=obj.PropertySchema.subProperties(pID);
                len=length(subProps);
                for r=ranges(i).RowStart:ranges(i).RowEnd
                    if r+1<=len
                        prop=subProps(r+1);
                        info=obj.PropertySchema.propertyInfo(prop);
                        for c=ranges(i).ColumnStart:ranges(i).ColumnEnd
                            data=mdom.Data;
                            if(c==0)
                                data.setProp('label',info.Label);
                                rangeData.fillData(r,c,data);
                            elseif(c==1)
                                meta=mdom.MetaData;
                                if info.Renderer=="IconLabelRenderer"
                                    if isa(info.Value,'logical')
                                        logical2disp={'False','True'};
                                        data.setProp('label',logical2disp{info.Value+1});
                                    else
                                        data.setProp('label',info.Value);
                                    end
                                    data.setProp('tooltip',info.Tooltip);
                                    meta.setProp('renderer','IconLabelRenderer');
                                end
                                rangeData.fillData(r,c,data);
                                rangeData.fillMetaData(r,c,meta);
                            end
                        end
                    end
                end
                ev.addRangeData(rangeData);
            end

            ev.send();
        end

        function onExpand(obj,prop)
            if isempty(obj.PropertySchema)
                return;
            end
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            subProps=obj.PropertySchema.subProperties(prop);
            if~isempty(subProps)
                dm.rowChanged(prop,length(subProps),{});
            end
        end

        function onCollapse(obj,prop)
            if isempty(obj.PropertySchema)
                return;
            end
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            dm.rowChanged(prop,0,{});
        end

    end

    methods(Hidden=true)
    end
end

