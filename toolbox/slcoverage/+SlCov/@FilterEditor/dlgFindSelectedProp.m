function newProp=dlgFindSelectedProp(this)






    tag=this.widgetTag;
    idxp=this.m_dlg.getWidgetValue([tag,'filterValues'])+1;
    [~,propValues]=this.getFilterPropertyValues;
    propValue=propValues{idxp};
    newProp=[];
    allPropMap=SlCov.FilterEditor.getPropertyDB;
    values=allPropMap.values;
    for idx=1:numel(values)
        newProp=values{idx};
        if~isempty(strfind(propValue,newProp.valueDesc))
            break;
        end
    end

