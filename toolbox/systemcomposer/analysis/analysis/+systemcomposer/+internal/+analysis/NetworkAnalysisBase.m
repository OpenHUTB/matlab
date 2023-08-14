classdef NetworkAnalysisBase<systemcomposer.internal.analysis.AnalysisBase



    properties

    end

    methods(Static)
        function res=isSource(instance)

            res=instance.incoming.Size==0;
        end
    end
    methods
        function res=populateConnections(obj)
            res=true;
        end
        function compute(this,instance)
            if~instance.isSource


                incoming=instance.getIncomingLinks();
                actual=0;
                for l=1:length(incoming)
                    actual=actual+incoming(l).getValue('actualFlow');
                end

                instance.setValue('actualFlow',round(actual,2));
            else

                actual=instance.getValue('actualFlow');
            end


            if~instance.isSink
                outgoing=instance.getOutgoingLinks();
                totalWeight=0;
                for l=1:length(outgoing)
                    totalWeight=totalWeight+outgoing(l).getValue('weight');
                end
                actualPerLink=actual/totalWeight;
                for l=1:length(outgoing)
                    outgoing(l).setValue('actualFlow',actualPerLink*outgoing(l).getValue('weight'));
                end
            end
        end
        function handleComputedValue(this,value,node)
            if isa(node,'systemcomposer.internal.analysis.NodeInstance')&&this.isSource(node)
                value.readOnly=false;
            else
                value.readOnly=true;
            end
        end
        function model=analyseInternal(obj,model)
            visitor=systemcomposer.internal.analysis.NetworkModelVisitor(obj);
            visitor.apply(obj.model,model.mfObject.root,true);
            txn=obj.model.beginTransaction();
            obj.calculateResults(model);
            txn.commit;
        end
    end
end

