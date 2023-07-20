classdef HierarchicalAnalysisBase<systemcomposer.internal.analysis.AnalysisBase



    properties

    end

    methods
        function handleComputedValue(obj,value,node)
            if isa(node,'systemcomposer.internal.analysis.ConnectorInstance')||node.children.Size==0
                value.readOnly=false;
            else
                value.readOnly=true;
            end
        end
        function model=analyseInternal(obj,model)
            visitor=systemcomposer.internal.analysis.InstanceModelVisitor(obj);
            visitor.apply(obj.model,model.mfObject.root);
            txn=obj.model.beginTransaction();
            obj.calculateResults(model);
            txn.commit;
        end

    end
end

