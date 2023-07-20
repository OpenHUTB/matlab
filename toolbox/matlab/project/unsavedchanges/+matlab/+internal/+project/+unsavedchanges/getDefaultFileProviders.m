function providers=getDefaultFileProviders




    persistent instances;

    if isempty(instances)
        instances=createProviders();
    end

    providers=instances;

end

function providers=createProviders()
    providersPackage=meta.package.fromName("matlab.internal.project.unsavedchanges.providers");
    classList=providersPackage.ClassList;

    providers=matlab.internal.project.unsavedchanges.LoadedFileProvider.empty;
    baseClass=?matlab.internal.project.unsavedchanges.LoadedFileProvider;

    for idx=find(classList<baseClass)'
        providers(end+1)=feval(classList(idx).Name);%#ok<AGROW>
    end
end
