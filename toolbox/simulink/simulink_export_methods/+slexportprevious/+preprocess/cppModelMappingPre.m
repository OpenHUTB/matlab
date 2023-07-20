function cppModelMappingPre(obj)







    if isR2022aOrEarlier(obj.ver)



        mapping=Simulink.CodeMapping.get(obj.modelName,'CppModelMapping');
        if~isempty(mapping)
            if isequal(mapping.DeploymentType,'Component')||...
                isequal(mapping.DeploymentType,'Subcomponent')
                mapping.DeploymentType='Unset';
            end
        end
    end

    if isR2021bOrEarlier(obj.ver)



        mapping=Simulink.CodeMapping.get(obj.modelName,'CppModelMapping');
        if~isempty(mapping)
            delimiter='::';
            if contains(mapping.CppClassReference.ClassNamespace,delimiter)
                mapping.CppClassReference.ClassNamespace='';
            end
        end
    end

    if isR2020bOrEarlier(obj.ver)

        mapping=Simulink.CodeMapping.get(obj.modelName,'CppModelMapping');
        if~isempty(mapping)


            mapping.unmapInports();
            mapping.unmapOutports();


            mapping.unmapFcnCalls();
        end
    end
