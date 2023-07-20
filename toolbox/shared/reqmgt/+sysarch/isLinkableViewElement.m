function tf=isLinkableViewElement(elem)

    if isa(elem,'systemcomposer.architecture.model.views.ComponentGroup')||...
        isa(elem,'systemcomposer.architecture.model.views.ElementGroup')||...
        isa(elem,'systemcomposer.architecture.model.views.View')||...
        isa(elem,'systemcomposer.view.ElementGroup')
        tf=true;
    elseif isa(elem,'systemcomposer.architecture.model.design.Architecture')&&~isempty(elem.p_View)
        tf=true;
    else
        tf=false;
    end

end