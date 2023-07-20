function out=isParamSaved(~,cs,pdata)






    out=true;
    dependency=pdata.Dependency;
    if~isempty(dependency)

        n=length(dependency.CustomDepList);
        if n>0
            for i=1:n
                dep=dependency.CustomDepList{i};
                st=dep.getStatus(cs,pdata.Name);
                if st~=0
                    out=false;
                    return;
                end
            end
        end

        n=length(dependency.StatusDepList);
        for i=1:n
            dep=dependency.StatusDepList{i};
            if isa(dep,'configset.internal.dependency.StatusDependency')
                st=dep.getStatus(cs);
                if st~=0
                    out=false;
                    return;
                end
            end
        end

    end

