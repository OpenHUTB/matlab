function validateProperty(dataModel,element,propertyName,oldValue)


    switch propertyName
    case "Workspace"

        if~strcmp(element.Workspace,"global-workspace")&&~isvarname(element.Workspace)
            txn=dataModel.beginTransaction();
            element.Workspace=oldValue;
            txn.commit()
        end
    end
end