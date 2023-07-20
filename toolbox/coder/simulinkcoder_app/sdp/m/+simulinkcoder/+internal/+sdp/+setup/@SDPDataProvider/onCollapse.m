function onCollapse(obj,id)

    if~isempty(id)
        dm=mdom.DataModel.findDataModel(obj.DataModelID);
        dm.rowChanged(id,0,{});
    end
