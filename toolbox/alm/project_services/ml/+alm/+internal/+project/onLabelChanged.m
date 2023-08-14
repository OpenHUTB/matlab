function onLabelChanged(absoluteProjectRoot)





    if~alm.internal.ProjectServicePlatform.isPlatform(char(absoluteProjectRoot))
        return;
    end


    ps=alm.internal.ProjectService.get(char(absoluteProjectRoot));
    if~isempty(ps)
        observer=ps.getObserver();
        if~isempty(observer)
            observer.emitLabelChanged();
        end
    end
end
