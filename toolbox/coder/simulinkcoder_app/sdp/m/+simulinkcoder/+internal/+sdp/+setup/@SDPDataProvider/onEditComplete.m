function onEditComplete(obj,rowid,col,data)

    if slfeature('FCPlatform')==0
        if col==2
            col=4;
        end
    end

    dm=mdom.DataModel.findDataModel(obj.DataModelID);
    if~isempty(dm)
        value=jsondecode(data);
        if col==1

            obj.dataModel.setNodeProp(rowid,'CodeGen',value.checked);
        elseif col==2

            ecd=strtrim(value.label);
            obj.dataModel.setNodeProp(rowid,'CoderDictionary',ecd);
            if isempty(ecd)
                obj.dataModel.setNodeProp(rowid,'Platform','-');
            end
        elseif col==3

            obj.dataModel.setNodeProp(rowid,'Platform',value);
        elseif col==4

            obj.dataModel.setNodeProp(rowid,'DeploymentType',value);
        end

        dm.refreshView;

    end
