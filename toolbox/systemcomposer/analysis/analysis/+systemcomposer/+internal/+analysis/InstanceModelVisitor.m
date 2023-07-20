classdef InstanceModelVisitor<handle




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

        function this=InstanceModelVisitor(visitor)
            this.visitor=visitor;
        end
    end

    methods(Access=private)
        function applyInternal(this,root)
            if isa(root,'systemcomposer.internal.analysis.NodeInstance')
                children=root.children.toArray;
                for c=1:length(children)
                    this.applyInternal(children(c));
                end

                wrappedRoot=systemcomposer.internal.analysis.AnalysisNodeInstance(root,this.model);
                this.visitor.visit(wrappedRoot,wrappedRoot.getChildren());
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

