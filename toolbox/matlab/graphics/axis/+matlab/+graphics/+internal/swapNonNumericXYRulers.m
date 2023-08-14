function[swapped,err]=swapNonNumericXYRulers(obj)

















    narginchk(1,1)
    swapped=false;
    err='';

    ax=ancestor(obj,'axes','node');
    if isempty(ax)
        return;
    end
    [xr,yr]=matlab.graphics.internal.getRulersForChild(obj);
    okX=isempty(xr)||isa(xr,'matlab.graphics.axis.decorator.NumericRuler');
    okY=isempty(yr)||isa(yr,'matlab.graphics.axis.decorator.NumericRuler');

    if okX&&okY
        return;
    end
    if isprop(ax,'TargetManager')
        tm=ax.TargetManager;
    else
        tm=[];
    end
    if~isempty(tm)&&length(tm.Children)>1
        err='YYAxis';
        return;
    end

    ch=reshape(ax.Children,1,[]);
    objType=obj.Type;
    types=get(ch,'Type');
    if~all(strcmp(types,objType))
        err='Type';
        return;
    end


    for obj=ch
        reactToXYRulerSwap(obj);
    end

    swapXYRulers(ax);
    swapped=true;
