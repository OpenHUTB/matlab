



function explicitInstantiations=generateExplicitInstantiations(createFunctionStruct,formalParamTypeList)





    templateActualTypes=createFunctionStruct.templateActuals;
    assert(~isempty(templateActualTypes),'template actual types not found on the createFunctionStruct');

    explicitInstantiations='';
    for i=1:numel(templateActualTypes)
        explicitInstantiations=[explicitInstantiations,iCreateExplicitInstantiation(createFunctionStruct,templateActualTypes{i},formalParamTypeList)];%#ok
    end

    explicitInstantiations=[explicitInstantiations,'\n'];
end







function explicitInstantiation=iCreateExplicitInstantiation(createFunctionStruct,actualTypes,formalParamTypeList)

    actualTypeList='<';
    for i=1:numel(actualTypes)
        actualTypeList=[actualTypeList,actualTypes{i},','];%#ok
    end


    actualTypeList=actualTypeList(1:end-1);

    actualTypeList=[actualTypeList,'>'];

    explicitInstantiation=['template ',createFunctionStruct.layerImplBase,'* ',createFunctionStruct.layerImplFactory,'::',createFunctionStruct.createFunction];
    explicitInstantiation=[explicitInstantiation,actualTypeList];
    explicitInstantiation=[explicitInstantiation,formalParamTypeList,';\n'];
end
