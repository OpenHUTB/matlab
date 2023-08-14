function isFieldResult=isFieldPresentInStruct(modelName,inStruct,fieldName)





    isFieldResult=0;
    fieldsInStruct=Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(modelName,['fieldnames(',inStruct,')']);
    for index=1:length(fieldsInStruct)
        if(strcmp(fieldsInStruct{index},strtrim(fieldName)))
            isFieldResult=1;
            return;
        elseif Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(modelName,['isstruct(',inStruct,'.',(fieldsInStruct{index}),')'])
            isFieldResult=Simulink.variant.utils.isFieldPresentInStruct(modelName,[inStruct,'.',(fieldsInStruct{index})],fieldName);
            if isFieldResult
                return;
            end
        end
    end
end
