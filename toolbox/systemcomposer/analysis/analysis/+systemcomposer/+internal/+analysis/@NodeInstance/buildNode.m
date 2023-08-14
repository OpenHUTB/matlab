function buildNode(this,source,parent)

    if~isa(source,'systemcomposer.arch.Architecture')&&...
        (isempty(parent.specification)||parent.specification~=source.getImpl)




        impl=source.Architecture.getImpl.getParentComponent;
        if isempty(impl)
            impl=source.getImpl;
        end
        node=this.instanceModel.addInstanceForSpecification(impl);
        node.setName(source.Name);
        parent.children.add(node);

        source.Architecture.iterate('preorder',@this.buildNode,...
        'Recurse',false,"IncludePorts",false,node);
    end
end

