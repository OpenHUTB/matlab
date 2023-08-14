classdef AnalysisApp<systemcomposer.internal.analysis.iterators.Visitor



    properties
        currentSession=[];
        model=[];
        psNames={};
    end

    methods(Abstract)

        names=getProfileNames(this);


        names=getPropertyNames(this,prototypeName);
        addPropertySets(this);
        prescript(this,iter);
        postscript(this,iter);
        addInputProperties(this,set);
        addResultProperties(this,set);
    end
    methods
        function scope=getComputationScope(this,property)
            scope=systemcomposer.property.Scope.INDEPENDENT;
        end
        function semantics=getComputationSemantics(this,property)
            semantics=systemcomposer.internal.analysis.Semantics.CUSTOM;
        end
        function res=includePorts(this)
            res=false;
        end
        function res=includeConnectors(this)
            res=false;
        end
    end
    methods(Access=private)
        function createSession(this)

            profiles=this.getProfiles();



        end
    end

    methods
        function obj=AnalysisApp(source,model)




            if nargin<1

                obj.model=mf.zero.Model;
            else
                obj.model=model;
            end
            if nargin>=1
                txn=obj.model.beginTransaction;
                obj.currentSession=systemcomposer.internal.analysis.AnalysisSet(obj.model);
                obj.currentSession.definition=systemcomposer.internal.analysis.AnalysisDefinition(obj.model);
                def=obj.currentSession.definition;

                obj.addPropertySets();

                def.resultDefinition=systemcomposer.property.PropertySet(obj.model);
                obj.addResultProperties(def.resultDefinition);

                def.inputDefinition=systemcomposer.property.PropertySet(obj.model);
                obj.addInputProperties(def.inputDefinition);

                if isa(source,'systemcomposer.internal.analysis.InstanceModel')
                    obj.currentSession.referencedModels.add(source);
                else
                    instanceModel=obj.createInstanceModel(source);
                    obj.currentSession.ownedModels.add(instanceModel);
                    obj.addModelValueSet(instanceModel);
                end

                txn.commit;
            end
        end

        function root=getRoot(this)

        end

        function genericVisit(this,iter,element)
            if nargin<3
                element=iter.getElement();
            end
            values=element.values.toArray;

            for vi=1:length(values)
                value=values(vi);
                def=value.usage.propertyDef;

                if this.getComputationScope(def)==systemcomposer.property.Scope.COMPUTED
                    if this.getComputationSemantics(def)==systemcomposer.internal.analysis.Semantics.AGGREGATE


                        childValues=iter.getChildElements();
                        if~isempty(childValues)
                            agg=0;
                            for ci=1:length(childValues)
                                pv=childValues(ci).values.getByKey(value.Name);
                                agg=agg+pv.value.getAsMxArray();
                            end
                            value.value.setAsMxArray(agg);
                        end

                    end
                end
            end

            instance=element.instance;
            if isa(instance,'systemcomposer.internal.analysis.NodeInstance')


                ports=instance.ports.toArray;
                for ci=1:length(ports)

                end

            end

            this.visit(element);

            if isa(instance,'systemcomposer.internal.analysis.NodeInstance')

                connectors=instance.connectors.toArray;
                for ci=1:length(connectors)
                    this.genericVisit(iter,connectors(ci).propertyValues.getByKey(iter.ValueSet.UUID));
                end
            end

        end
    end

    methods
        function session=createAnalysisSessionForSpecification(this,specification)



        end
        function session=createAnalysisSessionForInstanceModel(this,model)




        end
        function session=loadAnalysisSession(this,fileName)



        end
        function saveAnalysisSession(this,fileName)



        end
        function current=getCurrentInstanceModel(this)
            current=this.currentSession.ownedModels.at(1);
        end
        function instanceModel=createInstanceModel(this,source)


            mfModel=mf.zero.getModel(this.currentSession);
            txn=mfModel.beginTransaction;
            instanceModel=systemcomposer.internal.analysis.InstanceModel.newInstanceModel(source,mfModel);
            this.setPropertyUsageForPrototype(instanceModel,'systemcomposer.internal.analysis.ConnectorInstance');
            this.setPropertyUsageForPrototype(instanceModel,'systemcomposer.internal.analysis.PortInstance');
            this.setPropertyUsageForPrototype(instanceModel,'systemcomposer.internal.analysis.NodeInstance');
            instanceModel.specification=source;


            inputs=instanceModel.usePropertySet(this.currentSession.definition.inputDefinition,'inputs');
            instanceModel.inputs=inputs;
            results=instanceModel.usePropertySet(this.currentSession.definition.resultDefinition,'results');
            instanceModel.results=results;
            txn.commit;
        end
        function setPropertyUsageForPrototype(this,instanceModel,name)
            ps=this.getPropertySetsForPrototype(name);
            instanceModel.usePropertySet(ps,name);
        end
        function usages=getPropertyUsageForInstance(this,instance)
            im=this.getCurrentInstanceModel();
            usages=im.getPropertySetUsage(class(instance));
        end

        function profile=loadProfile(this,name)
            import systemcomposer.internal.profile.*;
            profModel=Profile.loadFromFile(name);
            profile=Profile.getProfile(profModel);
        end

        function vs=addModelValueSet(this,model)


            if nargin>=1
                mfmodel=mf.zero.getModel(this.currentSession);
                txn=mfmodel.beginTransaction;
                vs=systemcomposer.internal.analysis.ModelValueSet(mfmodel);
                vs.instanceModel=this.getCurrentInstanceModel();

                this.iter=this.createHierarchyIterator(systemcomposer.IteratorMode.DepthFirst,...
                systemcomposer.IteratorDirection.Forward);

                this.iter.begin(vs.instanceModel);

                while~isempty(this.iter.getElement())


                    pu=this.getPropertyUsageForInstance(this.iter.getElement());
                    vs.addInstanceValueSet(this.iter.getElement(),pu);
                    if(isa(this.iter.getElement(),'systemcomposer.internal.analysis.NodeInstance'))


                        connectors=this.iter.getElement().connectors.toArray;
                        for ci=1:length(connectors)
                            pu=this.getPropertyUsageForInstance(connectors(ci));
                            vs.addInstanceValueSet(connectors(ci),pu);
                        end

                        ports=this.iter.getElement().ports.toArray;
                        for ci=1:length(ports)
                            pu=this.getPropertyUsageForInstance(ports(ci));
                            vs.addInstanceValueSet(ports(ci),pu);
                        end
                    end
                    this.iter.next;
                end
                txn.commit;
            end
        end
    end
    methods
        function i=getInstanceForSpecificationElement(this,specification)
            im=this.getCurrentInstanceModel();
            i=im.instances.getByKey(specification.UUID);
        end
        function ps=addPropertySet(this,name)
            def=this.currentSession.definition;
            ps=def.createPropertySet(name);
            this.psNames{end+1}=name;
        end

        function spec=getCurrentSpecification(this)
            im=this.getCurrentInstanceModel();
            spec=im.specification;
        end

        function prop=addProperty(this,set,propertyName,value,unit)
            switch class(value)
            case 'char'
                type=systemcomposer.property.DataType.STRING;
            case 'logical'
                type=systemcomposer.property.DataType.BOOLEAN;
            otherwise
                type=systemcomposer.property.DataType.NUMERIC;
            end
            prop=set.addProperty(propertyName,type);
            prop.setDefaultPropertyValue(value);
            if nargin>4
                prop.setPropertyUnit(unit);
            end
        end
    end
    methods
        function setInputValue(this,name,value)
            im=this.getCurrentInstanceModel();
            m=mf.zero.getModel(im);
            t=m.beginTransaction;
            usage=im.inputs.getPropertyUsage(name);
            usage.initialValue.setAsMxArray(value);
            t.commit;
        end
        function result=getResultValue(this,name)
            im=this.getCurrentInstanceModel();
            usage=im.results.getPropertyUsage(name);
            result=usage.initialValue.getAsMxArray();
        end
        function setResultValue(this,name,value)
            im=this.getCurrentInstanceModel();
            m=mf.zero.getModel(im);
            t=m.beginTransaction;
            usage=im.results.getPropertyUsage(name);
            usage.initialValue.setAsMxArray(value);
            t.commit;
        end
        function result=getInputValue(this,name)
            im=this.getCurrentInstanceModel();
            usage=im.inputs.getPropertyUsage(name);
            result=usage.initialValue.getAsMxArray();
        end
    end
    methods
        function valueSet=newAnalysis(this,model)
            if nargin>1

                instanceModel=model;
            else

                instanceModel=this.currentSession.referencedModels.at(1);
            end

            valueSet=this.addModelValueSet(instanceModel);


            this.analyse(valueSet);
        end

        function valueSet=reAnalyse(this,valueSet)
        end

        function valueSet=analyse(this,valueSet)
            if nargin<2
                im=this.getCurrentInstanceModel();
                valueSet=im.modelValueSets.at(1);
            end
            txn=this.model.beginTransaction;
            iter=this.createHierarchyIterator(systemcomposer.IteratorMode.DepthFirst,...
            systemcomposer.IteratorDirection.Reverse);
            iter.begin(valueSet);
            this.iter.begin(valueSet);
            this.prescript(iter);

            this.apply(systemcomposer.IteratorMode.DepthFirst,...
            systemcomposer.IteratorDirection.Reverse,valueSet);
            this.postscript(iter);
            txn.commit;
        end
    end
    methods
        function profiles=getProfiles(this)


            profiles=mf.zero.Sequence;
        end

        function properties=getProperties(this,prototype)


            properties=mf.zero.Sequence;
        end
    end
end

