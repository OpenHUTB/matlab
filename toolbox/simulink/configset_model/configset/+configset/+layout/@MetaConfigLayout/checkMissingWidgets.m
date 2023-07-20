function checkMissingWidgets(obj)







    disp('Verifying all widgets are present in layout model');

    mcs=obj.MetaCS;

    layoutWidgets=obj.WidgetGroupMap.keys;
    dataWidgets=mcs.WidgetNameMap.keys;

    diff=setdiff(dataWidgets,layoutWidgets);


    diff=diff(~contains(diff,':'));
    if~isempty(diff)
        error('MetaConfigSet:WidgetNotInLayoutModel',...
        ['These widgets are not included in the layout model. Please either add these widgets or make the parameters hidden: ',strjoin(diff,', ')]);
    end

