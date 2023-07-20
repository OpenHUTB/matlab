function exists=instanceExists(this,spec)
    exists=false;

    if isa(spec,'systemcomposer.architecture.model.design.Component')||...
        isa(spec,'systemcomposer.architecture.model.design.Architecture')
        collection=this.children.toArray;
    elseif isa(spec,'systemcomposer.architecture.model.design.BaseConnector')
        collection=this.connectors.toArray;
    else
        collection=this.ports.toArray;
    end

    for item=collection
        try
            connSpec=item.specification;
        catch ex
            connSpec=systemcomposer.architecture.model.design.BaseConnector.empty;
        end
        if~isempty(connSpec)&&connSpec==spec
            exists=true;
            return;
        end
    end
end
