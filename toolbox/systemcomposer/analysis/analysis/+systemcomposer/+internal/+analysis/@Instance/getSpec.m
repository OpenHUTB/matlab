function spec=getSpec(this)

    try
        if isa(this,'systemcomposer.internal.analysis.NodeInstance')
            if isempty(this.parent)

                spec=this.instanceModel.specification;
            else
                spec=this.specification;
            end
        else
            spec=this.specification;
        end
    catch ex

        spec=[];
    end
end

