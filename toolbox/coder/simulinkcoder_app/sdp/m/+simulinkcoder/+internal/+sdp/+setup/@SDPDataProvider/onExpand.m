function onExpand(obj,id)

    if~isempty(id)
        dm=mdom.DataModel.findDataModel(obj.DataModelID);
        node=obj.dataModel.getNode(id);
        refMdls=node.refMdls;
        dm.rowChanged(id,length(refMdls),{});
        loc_expandRefMdls(obj,dm,id);
    end

    function loc_expandRefMdls(obj,dm,id)
        node=obj.dataModel.getNode(id);
        refMdls=node.refMdls;
        for i=1:length(refMdls)
            refId=[id,'/',refMdls{i}];
            refNode=obj.dataModel.getNode(refId);
            expanded=dm.isRowExpanded(refId);
            if expanded
                dm.updateRowID(mdom.RowIndex(id,i-1),refId);
                dm.rowChanged(refId,length(refNode.refMdls),{});
                loc_expandRefMdls(obj,dm,refId)
            end
        end



