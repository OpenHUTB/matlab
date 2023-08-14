function out=getStatusDependsOn(obj)













    import configset.internal.data.ParamStatus

    dependency=obj.Dependency;
    if~isempty(obj.WidgetList)

        widgetList=obj.WidgetList;

        widgetList=widgetList(cellfun(@(x)true...
        &&~isempty(x.Dependency),widgetList));
        dependency=[dependency,cellfun(@(x)x.Dependency,widgetList)];
    end


    parentList={};
    for d=dependency
        statusDependency=d.StatusDepList;


        statusDependency=statusDependency(...
        cellfun(@(x)x.StatusLimit<ParamStatus.InAccessible...
        &&~isempty(x.ParentList),statusDependency));
        s=cellfun(@(x)x.ParentList,statusDependency,'UniformOutput',false);
        parentList=[parentList,s{:}];%#ok<AGROW>
    end


    parentList=unique(cellfun(@(x)x.Name,parentList,'UniformOutput',false),'stable');
    if isempty(parentList)

        out={};
    else
        out=parentList;
    end


