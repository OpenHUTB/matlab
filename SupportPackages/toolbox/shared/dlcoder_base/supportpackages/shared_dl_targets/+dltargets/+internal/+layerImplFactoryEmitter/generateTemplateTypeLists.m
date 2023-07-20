



function[templateTypenameParameterList,templateParameterList]=generateTemplateTypeLists(createFunctionStruct)





    templateActualTypes=createFunctionStruct.templateActuals;
    assert(~isempty(templateActualTypes),'template actual types not found on the createFunctionStruct');


    templateTypenameParameterList='<';
    templateParameterList='<';

    for i=1:numel(templateActualTypes{1})
        templateTypenameParameterList=[templateTypenameParameterList,'typename T',num2str(i),','];%#ok
        templateParameterList=[templateParameterList,'T',num2str(i),','];%#ok
    end


    templateTypenameParameterList=templateTypenameParameterList(1:end-1);
    templateParameterList=templateParameterList(1:end-1);


    templateTypenameParameterList=[templateTypenameParameterList,'>'];
    templateParameterList=[templateParameterList,'>'];
end
