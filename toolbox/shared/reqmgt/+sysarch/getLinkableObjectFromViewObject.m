function linkObj=getLinkableObjectFromViewObject(elem)




    linkObj=[];

    if isempty(elem)
        return;
    end

    if isa(elem,'systemcomposer.architecture.model.views.ComponentGroup')
        linkObj=elem.p_Source;
    elseif isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
        linkObj=systemcomposer.internal.getSourceElementForRedefinedElement(elem);
    elseif isa(elem,'systemcomposer.architecture.model.design.ComponentPort')
        if~isa(elem.getComponent,'systemcomposer.architecture.model.views.ComponentGroup')
            linkObj=systemcomposer.internal.getSourceElementForRedefinedElement(elem);
        end
    elseif isa(elem,'systemcomposer.architecture.model.views.View')
        linkObj=elem;
    elseif isa(elem,'systemcomposer.architecture.model.views.ElementGroup')
        linkObj=elem;
    elseif isa(elem,'systemcomposer.architecture.model.design.Architecture')&&~isempty(elem.p_View)
        linkObj=elem.p_View;
    elseif isa(elem,'systemcomposer.view.ElementGroup')
        linkObj=elem.getImpl;
    end

end


