classdef SignalTreeTableDataProvider<mdom.BaseDataProvider
    properties(Hidden)
        Model;
        AppClientID;
        lastTableAction='';
        lastActionRowID='';
    end
    properties(SetObservable=true)
        FlatData=true;
        ColumnHeaders=[getString(message('SDI:labeler:NameColumn'));
        getString(message('SDI:labeler:CheckBoxColumn'));
        getString(message('SDI:labeler:ValueColumn'));
        getString(message('SDI:labeler:LocationColumn'))+"("+getString(message('SDI:labeler:LocationColumnMin'))+")";
        getString(message('SDI:labeler:LocationColumn'))+"("+getString(message('SDI:labeler:LocationColumnMax'))+")";
        getString(message('SDI:labeler:TimeColumn'))];
    end
    events
CheckboxEdit
    end
    methods
        function requestData(this,ev)




            if this.Model.getAppName()~="labeler"
                return;
            end
            colList=ev.ColumnInfoRequests;
            colInfo=mdom.ColumnInfo(colList);
            meta=mdom.MetaData;


            for colIdx=1:length(colList)
                meta.clear();
                if(colList(colIdx)==0)

                    meta.setProp('label',this.ColumnHeaders(colIdx));

                    meta.setProp('renderer','IconLabelRenderer');

                    widthMeta=mdom.MetaData;

                    widthMeta.setProp('unit','%');

                    widthMeta.setProp('value',39);
                    meta.setProp('width',widthMeta);
                elseif(colList(colIdx)==1)

                    meta.setProp('label',this.ColumnHeaders(colIdx));




                    meta.setProp('renderer','IconLabelRenderer');

                    widthMeta=mdom.MetaData;

                    widthMeta.setProp('unit','px');

                    widthMeta.setProp('value',37);
                    meta.setProp('width',widthMeta);
                elseif(colList(colIdx)==2)

                    meta.setProp('label',this.ColumnHeaders(colIdx));

                    meta.setProp('renderer','IconLabelRenderer');

                    widthMeta=mdom.MetaData;

                    widthMeta.setProp('unit','%');

                    widthMeta.setProp('value',30);
                    meta.setProp('width',widthMeta);
                elseif(colList(colIdx)==3)

                    meta.setProp('label',this.ColumnHeaders(colIdx));

                    meta.setProp('renderer','IconLabelRenderer');

                    widthMeta=mdom.MetaData;

                    widthMeta.setProp('unit','%');

                    widthMeta.setProp('value',20);
                    meta.setProp('width',widthMeta);
                elseif(colList(colIdx)==4)

                    meta.setProp('label',this.ColumnHeaders(colIdx));

                    meta.setProp('renderer','IconLabelRenderer');

                    widthMeta=mdom.MetaData;

                    widthMeta.setProp('unit','%');

                    widthMeta.setProp('value',20);
                    meta.setProp('width',widthMeta);
                elseif(colList(colIdx)==5)

                    meta.setProp('label',this.ColumnHeaders(colIdx));

                    meta.setProp('renderer','IconLabelRenderer');

                    widthMeta=mdom.MetaData;

                    widthMeta.setProp('unit','%');

                    widthMeta.setProp('value',20);
                    meta.setProp('width',widthMeta);

                end
                colInfo.fillMetaData(colList(colIdx),meta);
            end
            ev.addColumnInfo(colInfo);


            ranges=ev.RangeRequests;
            rowList=ev.RowInfoRequests;
            rowInfo=mdom.RowInfo(rowList);
            rowListIdx=1;
            for dataIdx=1:length(ranges)
                rangeData=mdom.RangeData(ranges(dataIdx));
                data=mdom.Data;

                data.registerDataType('checked',mdom.DataType.BOOL);
                data.registerDataType('color',mdom.DataType.STRING);
                data.registerDataType('rowDataType',mdom.DataType.STRING);
                data.registerDataType('memberID',mdom.DataType.STRING);

                for rowIdx=ranges(dataIdx).RowStart:ranges(dataIdx).RowEnd
                    rowAndColData=this.Model.getTreeTableDataByRowIdx(rowIdx,ranges(dataIdx).ParentID,this.lastTableAction,this.lastActionRowID);
                    dm=mdom.DataModel.findDataModel(this.DataModelID);



                    if rowAndColData.parentID~=""&&dm.isRowExpanded(rowAndColData.parentID)
                        dm.updateRowID(mdom.RowIndex(rowAndColData.parentID,rowIdx),rowAndColData.rowID);
                    end
                    if rowAndColData.isExpanded&&rowAndColData.totalChildrenRows>0&&~dm.isRowExpanded(rowAndColData.rowID)



                        dm.rowChanged(rowAndColData.rowID,rowAndColData.totalChildrenRows,{});
                        return;
                    end
                    if dm.isRowExpanded(rowAndColData.rowID)&&rowAndColData.isExpanded&&rowAndColData.totalNewChildrenAdded>0



                        dm.appendRows(rowAndColData.rowID,rowAndColData.totalNewChildrenAdded,{});
                        return;
                    end
                    for colIdx=ranges(dataIdx).ColumnStart:ranges(dataIdx).ColumnEnd
                        data.clear();
                        data.setProp('rowDataType',rowAndColData.rowDataType);
                        data.setProp('memberID',rowAndColData.memberID);
                        if(colIdx==0)


                            data.setProp('label',rowAndColData.nameCol);
                            data.setProp('tooltip',rowAndColData.nameColTooltip);
                        elseif(colIdx==1)

                            if rowAndColData.rowDataType=="attributeLabelInstance"||...
                                rowAndColData.rowDataType=="labelHeader"
                                data.setProp('label','');
                                data.setProp('checked',rowAndColData.isChecked);
                            else

                                rowMeta=mdom.MetaData;
                                rowMeta.clear();
                                rowMeta.setProp('interactiveRenderer','CheckboxRenderer');
                                rangeData.fillMetaData(rowIdx,colIdx,rowMeta);
                                data.setProp('checked',rowAndColData.isChecked);
                            end
                        elseif(colIdx==2)



                            if(rowAndColData.rowDataType=="signal")




                                if(this.Model.isMemberIDs(str2double(rowAndColData.rowID))||~this.Model.isHasChildrenSignal(str2double(rowAndColData.rowID)))
                                    rowMeta=mdom.MetaData;
                                    rowMeta.clear();
                                    rowMeta.setProp('renderer','ColorRenderer');
                                    rangeData.fillMetaData(rowIdx,colIdx,rowMeta);
                                    data.setProp('color',rowAndColData.valueCol);
                                else


                                    data.setProp('label',"");
                                end
                            else
                                data.setProp('label',rowAndColData.valueCol);
                            end
                        elseif(colIdx==3)


                            data.setProp('label',rowAndColData.tMinCol);
                        elseif(colIdx==4)


                            data.setProp('label',rowAndColData.tMaxCol);
                        elseif(colIdx==5)


                            data.setProp('label',rowAndColData.timeCol);
                        end
                        rangeData.fillData(rowIdx,colIdx,data);
                    end





                    if~isempty(rowList)
                        rowIndex=rowList(rowListIdx);

                        rowInfo.setRowID(rowIndex,rowAndColData.rowID);

                        rowInfo.setRowExpanded(rowIndex,rowAndColData.isExpanded);

                        if rowAndColData.hasChildren
                            rowInfo.setRowHasChild(rowIndex,mdom.HasChild.YES)
                        else
                            rowInfo.setRowHasChild(rowIndex,mdom.HasChild.NO)
                        end
                        rowListIdx=rowListIdx+1;
                    end
                end
                ev.addRangeData(rangeData);
            end
            ev.addRowInfo(rowInfo);

            ev.send();
            this.lastTableAction='';
            this.lastActionRowID='';
        end

        function onExpand(this,rowid)
            if~isempty(rowid)
                dm=mdom.DataModel.findDataModel(this.DataModelID);
                rowIndex=dm.getIndexForID(rowid);
                info=this.Model.updateTreeTableDataOnExpandCollapse(rowIndex.RowIndex,rowIndex.ParentID,true);
                dm.rowChanged(rowid,info.numOfRows,{});
                this.lastTableAction='expand';
                this.lastActionRowID=rowid;
            end
        end

        function onCollapse(this,rowid)
            if~isempty(rowid)
                dm=mdom.DataModel.findDataModel(this.DataModelID);
                rowIndex=dm.getIndexForID(rowid);
                this.Model.updateTreeTableDataOnExpandCollapse(rowIndex.RowIndex,rowIndex.ParentID,false);
                dm.rowChanged(rowid,0,{});
                this.lastTableAction='collapse';
                this.lastActionRowID=rowid;
            end
        end

        function onExpandAll(this)
            this.Model.updateAllTreeTableRowsExpandAllFlag(true);
            dm=mdom.DataModel.findDataModel(this.DataModelID);
            dm.refreshView();
            this.lastTableAction='expandAll';
        end

        function onCollapseAll(this)

            this.Model.updateAllTreeTableRowsExpandAllFlag(false);
            memberIDs=string(this.Model.getMemberIDs());
            for idx=1:numel(memberIDs)
                onCollapse(this,memberIDs(idx));
            end
            this.lastTableAction='collapseAll';
        end

        function onEditComplete(this,rowid,col,data)
            dm=mdom.DataModel.findDataModel(this.DataModelID);
            if~isempty(dm)

                value=jsondecode(data);
                rowIndex=dm.getIndexForID(rowid);

                switch col
                case 1

                    parentID="";
                    if rowIndex.ParentID~="_INVISIBLE_ROOT_"
                        parentID=rowIndex.ParentID;
                    end
                    value.rowID=rowid;
                    value.parentID=parentID;
                    this.notify('CheckboxEdit',signal.internal.SAEventData(struct('clientID',this.AppClientID,...
                    'messageID','checkbox','data',value)));
                otherwise
                end
            end

        end


        function handleExpandWhenScrolling(this,rowid,childrenIDs)
            if~isempty(rowid)
                dm=mdom.DataModel.findDataModel(this.DataModelID);
                rowIndex=dm.getIndexForID(rowid);
                info=this.Model.updateTreeTableDataOnExpandCollapse(rowIndex.RowIndex,rowIndex.ParentID,true);
                dm.rowChanged(rowid,info.numOfRows,childrenIDs);
            end
        end
    end
end

