classdef AllocationModelVisitor<handle




    properties
        visitor=[];
        model=[];
    end

    methods
        function apply(this,model,root)
            this.model=model;
            txn=model.beginTransaction;
            this.applyInternal(root);
            txn.commit;
        end

        function refresh(this,model,root)
            this.model=model;
            txn=model.beginTransaction;
            this.refreshInternal(root);
            txn.commit;
        end

        function this=AllocationModelVisitor(visitor)
            this.visitor=visitor;
        end
    end

    methods(Access=private)
        function applyInternal(this,root)
            if isa(root,'systemcomposer.internal.analysis.NodeInstance')
                wrappedRoot=systemcomposer.internal.analysis.AnalysisNodeInstance(root,this.model);
                sortedList=wrappedRoot.getOrderedList();

                for li=1:length(sortedList)
                    this.applyInternal(sortedList(li));
                    this.visitor.updateInternal(sortedList(li));
                    this.visitor.compute(sortedList(li));
                    this.visitor.visit(sortedList(li));
                    sortedList(li).clearDirtyFlag;
                end

                sources=root.sources.toArray;
                for c=1:length(sources)
                    this.applyInternal(sources(c));
                end
            end
        end

        function refreshInternal(this,root)
            if isa(root,'systemcomposer.internal.analysis.NodeInstance')
                children=root.children.toArray;
                for c=1:length(children)
                    this.refreshInternal(children(c));
                end

                wrappedRoot=systemcomposer.internal.analysis.AnalysisNodeInstance(root,this.model);
                this.visitor.visit(wrappedRoot,wrappedRoot.getChildren());
            end
        end
    end

end

