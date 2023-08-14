function validateProperty(dataModel,element,propertyName,oldValue)


    switch propertyName
    case "Label"
        if element.Label==""
            txn=dataModel.beginTransaction();
            element.Label=oldValue;
            txn.commit()
        end
    end
end