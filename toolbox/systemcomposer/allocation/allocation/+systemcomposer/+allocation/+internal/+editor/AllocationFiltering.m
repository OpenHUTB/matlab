classdef AllocationFiltering<handle









    methods(Static)
        function list=getStereotypes(modelName)
            list=[];
            da=systemcomposer.internal.DependencyAnalyzer.getDependencies([modelName,'.slx']);
            models=da.models;
            for i=1:numel(models)
                if contains(models{i},'.slxp')

                    continue;
                end
                stereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(models{i},false);
                for j=1:numel(stereotypes)
                    list{end+1}=stereotypes(j).fullyQualifiedName;%#ok<AGROW>
                end
            end
            list=unique(list);
        end
    end
end