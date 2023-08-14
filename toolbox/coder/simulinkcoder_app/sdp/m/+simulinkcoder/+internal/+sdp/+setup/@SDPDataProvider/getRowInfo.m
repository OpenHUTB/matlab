function rowInfo=getRowInfo(obj,rowList)

    rowInfo=mdom.RowInfo(rowList);
    for r=1:length(rowList)
        rIndex=rowList(r);

        if strcmp(rIndex.ParentID,'_INVISIBLE_ROOT_')
            id=obj.dataModel.topModel;
        else
            pID=rIndex.ParentID;
            pNode=obj.dataModel.getNode(pID);
            mdlNames=pNode.refMdls;
            mdlName=mdlNames{rIndex.RowIndex+1};
            id=[pID,'/',mdlName];
        end

        rowInfo.setRowID(rIndex,id);
        mdlNode=obj.dataModel.getNode(id);
        refMdls=mdlNode.refMdls;

        if isempty(refMdls)
            rowInfo.setRowHasChild(rIndex,mdom.HasChild.NO);
        else
            rowInfo.setRowHasChild(rIndex,mdom.HasChild.YES);
        end

        dm=mdom.DataModel.findDataModel(obj.DataModelID);
        expanded=dm.isRowExpanded(dm.getIDForIndex(rIndex));
        if expanded
            rowInfo.setRowExpanded(rIndex,true);
        end

    end

