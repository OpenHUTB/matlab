function err=validate(node,target)
























    if~isempty(node.resources)
        fields=node.resources.get;

        fields_c=struct2cell(fields);
        idx=find(cellfun('isclass',fields_c,'RTWConfiguration.Resource'));
        for i=idx(:)'
            clear_allocations(fields_c{i});
        end
    end


    if isempty(node.data)


        DAStudio.error('TargetSupportPackage:target:TargetConfigClassesNotLoaded');
    else
        err=node.data.validate(node,target);
    end
