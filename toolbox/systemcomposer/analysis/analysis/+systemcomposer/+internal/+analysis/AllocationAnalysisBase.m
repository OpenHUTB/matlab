classdef AllocationAnalysisBase<systemcomposer.internal.analysis.AnalysisBase



    properties
        sourceSet=[];
    end

    methods(Static)
        function res=isSource(instance)

            res=instance.incoming.Size==0;
        end
    end
    methods
        function setSource(obj,source)
            obj.sourceSet=source;
            obj.currentArchitecture=source;
        end
        function res=isAllocation(obj)
            res=true;
        end
        function res=populateConnections(obj)
            res=true;
        end

        function compute(this,instance)
            if~instance.isSource


                incoming=instance.getIncomingLinks();
                actual=0;
                for l=1:length(incoming)
                    actual=actual+incoming(l).getValue('MaterialCost');
                end

                if~isempty(actual)
                    instance.setValue('InboundMaterialCost',round(actual,2));
                end
            else


            end

            this.update(instance);

            actual=instance.getValue('OutboundMaterialCost');

            if~instance.isSink
                outgoing=instance.getOutgoingLinks();
                totalWeight=0;
                for l=1:length(outgoing)
                    totalWeight=totalWeight+outgoing(l).getValue('Weight');
                end

                if~isempty(actual)&&~isempty(totalWeight)
                    actualPerLink=actual/totalWeight;
                    for l=1:length(outgoing)
                        outgoing(l).setValue('MaterialCost',actualPerLink*outgoing(l).getValue('Weight'));
                    end
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
            visitor=systemcomposer.internal.analysis.AllocationModelVisitor(obj);
            visitor.apply(obj.model,model.mfObject.root);
            txn=obj.model.beginTransaction();
            obj.calculateResults(model);
            txn.commit;
        end

        function model=refreshInternal(obj,model)
            txn=obj.model.beginTransaction();
            obj.getSourceModel().updateRoot(true,obj.sourceArchitecture);
            model.updateRoot(true,obj.currentArchitecture);
            obj.updateAllocations();
            txn.commit;
        end

        function model=getSourceModel(obj)
            m1=obj.mfObject.models.toArray;
            model=systemcomposer.internal.analysis.AnalysisModel(m1.source,obj.model,obj);
        end

        function model=getTargetModel(obj)
            m1=obj.mfObject.models.toArray;
            model=systemcomposer.internal.analysis.AnalysisModel(m1,obj.model,obj);
        end

        function updateAllocations(obj)
            instance=obj.getTargetModel();
            sourceModel=obj.getSourceModel();
            root=obj.sourceSet.TargetRoots.toArray;
            instance.updateAllocationsToTarget(root.Targets.toArray,sourceModel);
        end

        function instance=instantiateInternal(obj)


            sources=obj.sourceSet.Sources.toArray;
            root=sources(1).Root;
            sourceModel=obj.instantiate(root,false,false);



            root=obj.sourceSet.TargetRoots.toArray;
            instance=obj.instantiate(root.Architecture,true,true);
            instance.setSource(sourceModel);
            instance.addAllocationsToTarget(root.Targets.toArray,sourceModel);
        end

    end
end

