classdef NetworkModelVisitor<handle




    properties
        visitor=[];
        model=[];
        sortedList=[];
    end

    methods
        function apply(this,model,root,forward)
            this.model=model;
            txn=model.beginTransaction;
            this.applyInternal(root,forward);
            txn.commit;
        end

        function this=NetworkModelVisitor(visitor)
            this.visitor=visitor;
        end
    end

    methods(Access=private)
        function constructForwardList(this,node)
            links=node.getOutgoingLinks();
            if~isempty(links)
                this.sortedList(end+1)=links(1);
                this.constructForwardList(links(1));
            end
        end

        function applyInternal(this,root,forward)
            if isa(root,'systemcomposer.internal.analysis.NodeInstance')
                wrappedRoot=systemcomposer.internal.analysis.AnalysisNodeInstance(root,this.model);
                this.sortedList=wrappedRoot.getOrderedList();

                for li=1:length(this.sortedList)
                    this.applyInternal(this.sortedList(li));
                    this.visitor.updateInternal(this.sortedList(li));
                    this.visitor.compute(this.sortedList(li));
                    this.visitor.visit(this.sortedList(li));
                    this.sortedList(li).clearDirtyFlag;
                end
            end
        end
    end

end

