classdef AnalysisInstance<systemcomposer.internal.analysis.AnalysisObject



    properties

    end

    methods

        function nodes=addNode(obj,nodes,source,geometry)
            if isa(source,'systemcomposer.internal.analysis.NodeInstance')
                proxy=systemcomposer.internal.analysis.AnalysisNodeInstance(source,obj.model);
                if isempty(nodes)
                    nodes=proxy;
                else
                    nodes(end+1)=proxy;
                end
                if(nargin>3)
                    proxy.setGeometry(geometry);
                end
            end
        end
        function setGeometry(obj,geometry)
            txn=obj.model.beginTransaction;
            obj.mfObject.position.x=geometry.Position(1);
            obj.mfObject.position.y=geometry.Position(2);
            obj.mfObject.dimensions.w=geometry.Size(1);
            obj.mfObject.dimensions.h=geometry.Size(2);
            txn.commit;
        end
        function obj=AnalysisInstance(mfObject,model)


            obj=obj@systemcomposer.internal.analysis.AnalysisObject(model);
            obj.mfObject=mfObject;
        end

        function setValue(obj,propertyString,value)


            i=obj.mfObject.getPropertyValue(propertyString);

            if isempty(i.value)
                i.value=obj.convertMxArrayToValueSpecification(value);
            else
                i.value.value=value;
            end
        end

        function value=getValue(obj,propertyString)

            vs=obj.mfObject.getPropVal(propertyString);


            if isempty(vs)
                value=[];
            else
                value=obj.convertValueSpecificationToMxArray(vs);
            end
        end

        function model=getModel(obj)
            model=systemcomposer.internal.analysis.AnalysisModel(obj.mfObject.analysisModel,obj.model);
        end

        function sources=getSources(obj)
            mfSources=obj.mfObject.sourceInstances.toArray;
            sources=[];
            for i=1:length(mfSources)
                sources=obj.addNode(sources,mfSources(i));
            end
        end

        function target=getTarget(obj)
            target=[];
            targets=obj.mfObject.targets.toArray;
            if~isempty(targets)
                mfTarget=targets(1).to;
                target=systemcomposer.internal.analysis.AnalysisNodeInstance(mfTarget,obj.model);
            end
        end
    end
end

