function sourceElem=getSourceElementForRedefinedElement(elem)






    isImpl=false;
    if isa(elem,'mf.zero.ModelElement')
        isImpl=true;
    end

    sourceElem=elem;
    try
        if~isImpl
            elem=elem.getImpl;
        end
        if isprop(elem,'p_Redefines')
            if~isempty(elem.p_Redefines)
                sourceElem=systemcomposer.internal.getSourceElementForRedefinedElement(elem.p_Redefines);
            end
        end
    catch


    end

    if isa(sourceElem,'mf.zero.ModelElement')&&~isImpl
        sourceElem=systemcomposer.internal.getWrapperForImpl(sourceElem);
    end


end


