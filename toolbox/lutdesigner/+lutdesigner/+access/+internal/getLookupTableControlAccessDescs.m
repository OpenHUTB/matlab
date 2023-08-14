function accessDescs=getLookupTableControlAccessDescs(access)
    accessDescs=lutdesigner.access.Access.createDescArray([0,1]);
    if~isempty(Simulink.Mask.get(access.Path))
        lutControls=lutdesigner.lutfinder.LookupTableFinder.getLookupTableControls(access.Path,'Visible','on');
        if~isempty(lutControls)
            accessDescs=arrayfun(@(c)lutdesigner.access.Access.createDesc('lookupTableControl',[access.Path,'/',c.Name],access.Type),lutControls(:));
        end
    end
end
