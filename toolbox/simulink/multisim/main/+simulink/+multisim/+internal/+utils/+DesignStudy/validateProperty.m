function validateProperty(dataModel,element,propertyName,oldValue)


    switch propertyName
    case "Label"
        designSuite=element.Container;
        designStudyArray=designSuite.DesignStudies.toArray();
        existingLabels={designStudyArray.Label};
        indicesWithDuplicateLabels=strcmp(element.Label,existingLabels);

        if element.Label==""||nnz(indicesWithDuplicateLabels)>1
            txn=dataModel.beginTransaction();
            element.Label=oldValue;
            txn.commit()
        end
    end
end