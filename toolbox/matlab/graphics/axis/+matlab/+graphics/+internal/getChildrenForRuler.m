function ch=getChildrenForRuler(h)









    ch=[];
    ax=ancestor(h,{'axes','polaraxes'},'node');
    if isempty(ax)
        return;
    end
    if isprop(ax,'TargetManager')
        tm=ax.TargetManager;
    else
        tm=[];
    end
    if isempty(tm)
        ch=ax.Children;
    else
        targets=tm.Children;
        ch=cell(size(targets));
        for k=1:length(targets)
            t=targets(k);



            if(h==t.AxisA)||...
                (h==t.AxisB)||...
                (h==t.AxisC)
                ch{k}=t.ChildContainer.Children;
            end
        end
        ch=vertcat(ch{:});
    end
end
