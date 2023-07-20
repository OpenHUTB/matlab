function names=getNamesForAllExistingComponents(components)







    function names=work(component,names)
        try
            names{end+1}=component.DesignTimeProperties.CodeName;
        catch
        end
        try
            for j=1:length(component.Children)
                names=work(component.Children(j),names);
            end
        catch
        end
    end

    fnames=fieldnames(components);
    for i=1:length(fnames)
        names=work(components.(fnames{i}),{});
    end
end

