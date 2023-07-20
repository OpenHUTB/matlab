function ret=appendWidget(~,widgetList,widgets)

    ret=widgetList;
    rowIdx=1;

    if~isempty(widgetList)
        lastWidget=widgetList{end};
        rowIdx=lastWidget.RowSpan(1)+1;
    end

    if numel(widgets)==1
        widgets.RowSpan=[rowIdx,rowIdx];
        ret{end+1}=widgets;
    else
        for i=1:numel(widgets)
            prm=widgets{i};
            prm.RowSpan=[rowIdx,rowIdx];
            ret{end+1}=prm;
        end
    end
end
