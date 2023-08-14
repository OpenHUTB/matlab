classdef AnalysisModel<systemcomposer.internal.analysis.AnalysisObject



    properties
        analysisObject=[];
        isTarget=false;
    end
    methods(Static)
        function instance=getInstanceForComponent(parent,component)
            instance=parent.children.getByKey(component.Name);
        end

    end
    methods
        function instance=findInstanceFromPath(obj,pathString)

            path=regexp(pathString,'/','split');

            instance=obj.mfObject.root;
            for s=2:length(path)
                instance=instance.children.getByKey(path{s});
            end
        end

        function updateAllocationsToTarget(obj,targets,sourceRoot)
            for t=1:length(targets)
                target=targets(t);


                targetInstance=obj.findInstanceFromPath(target.fullPath.getNamedFullPath());
                allocs=target.AllocFrom.toArray;

                for a=1:length(allocs)
                    alloc=allocs(a);
                    source=alloc.Source;
                    sourceInstance=sourceRoot.findInstanceFromPath(source.fullPath.getNamedFullPath());

                    if isempty(obj.findAllocationInstance(targetInstance,sourceInstance))
                        obj.createAllocationInstance(targetInstance,sourceInstance,source.Id);
                    end
                end
            end
        end

        function addAllocationsToTarget(obj,targets,sourceRoot)
            for t=1:length(targets)
                target=targets(t);


                targetInstance=obj.findInstanceFromPath(target.fullPath.getNamedFullPath());
                allocs=target.AllocFrom.toArray;

                for a=1:length(allocs)
                    alloc=allocs(a);
                    source=alloc.Source;
                    sourceInstance=sourceRoot.findInstanceFromPath(source.fullPath.getNamedFullPath());

                    obj.createAllocationInstance(targetInstance,sourceInstance,source.Id);
                end
            end
        end
    end
    methods
        function instance=getInstanceForConnector(obj,parent,con)

            if(isempty(con.Source.Component))
                source=parent;
            else
                source=obj.getInstanceForComponent(parent,con.Source.Component);
            end

            if(isempty(con.Destination.Component))
                dest=parent;
            else
                dest=obj.getInstanceForComponent(parent,con.Destination.Component);
            end

            name=[source.Name,'->',dest.Name];
            instance=parent.children.getByKey(name);
        end
        function obj=AnalysisModel(mfObject,model,analysis)


            obj@systemcomposer.internal.analysis.AnalysisObject(model);
            obj.mfObject=mfObject;
            if(nargin>2)
                obj.analysisObject=analysis;
            end
        end

        function createRoot(obj,system,populateConnections,isTarget)
            obj.isTarget=isTarget;

            node=systemcomposer.internal.analysis.NodeInstance(obj.model);
            node.Name=system.Name;


            obj.mfObject.root=node;
            obj.mfObject.instances.add(node);

            obj.populateChildren(node,system,populateConnections);
            obj.addProperties(node,system);
        end

        function updateRoot(obj,populateConnections,system)

            obj.updateChildren(obj.mfObject.root,system,populateConnections);


            proxy=systemcomposer.internal.analysis.AnalysisNodeInstance(obj.mfObject.root,obj.model);
            proxy.layoutChildren();
        end

        function addProperties(obj,node,source)
            if obj.isTarget
                suffix='#Target';
            else
                suffix='';
            end

            if strcmp(node.MetaClass.name,'NodeInstance')
                analysisDefaults=obj.mfObject.ownedPropertySetUsages.getByKey(['sysarchModel.arch.Component',suffix]);
            else
                analysisDefaults=obj.mfObject.ownedPropertySetUsages.getByKey(['sysarchModel.arch.Connector',suffix]);
            end

            propertyDefaults=source.ownedPropertySetUsages.toArray;

            if~isempty(propertyDefaults)


                propDef=propertyDefaults(1).ownedPropertyUsages.toArray;
            elseif isa(source,'sl.sysarchModel.arch.Component')

                propertyDefaults=source.Type.ownedPropertySetUsages.toArray;
                if~isempty(propertyDefaults)
                    propDef=propertyDefaults(1).ownedPropertyUsages.toArray;
                else
                    propDef=analysisDefaults.ownedPropertyUsages.toArray;
                end
            else

                propDef=analysisDefaults.ownedPropertyUsages.toArray;
            end


            for p=1:length(propDef)
                prop=propDef(p);
                pv=systemcomposer.internal.analysis.PropertyValue(obj.model);
                pv.Name=prop.Name;
                usage=analysisDefaults.ownedPropertyUsages.getByKey(pv.Name);
                pv.usage=usage;

                switch prop.propertyDef.computationScope
                case systemcomposer.property.Scope.INDEPENDENT
                    pv.readOnly=false;
                case systemcomposer.property.Scope.DEPENDENT
                    pv.readOnly=true;
                case systemcomposer.property.Scope.COMPUTED
                    pv.readOnly=false;
                end

                if~pv.readOnly
                    pv.value=obj.copyValueSpecification(prop.initialValue);
                end
                node.values.add(pv);
            end

        end

        function updateChildren(obj,parent,architecture,populateConnections)

            ownedBlocks=architecture.ChildComponents.toArray;
            for c=1:length(ownedBlocks)
                comp=ownedBlocks(c);
                i=obj.getInstanceForComponent(parent,comp);

                if isempty(i)
                    i=createInstance(obj,comp,parent,populateConnections);
                end

                obj.updateChildren(i,comp.Type,populateConnections);
            end
            if(populateConnections)
                connectors=architecture.Connectors.toArray;
                for c=1:length(connectors)
                    con=connectors(c);
                    i=obj.getInstanceForConnector(parent,con);

                    if isempty(i)
                        i=systemcomposer.internal.analysis.ConnectorInstance(obj.model);
                        if(isempty(con.Source.Component))
                            i.source=parent;
                        else
                            i.source=obj.getInstanceForComponent(parent,con.Source.Component);
                        end

                        if(isempty(con.Destination.Component))
                            i.dest=parent;
                        else
                            i.dest=obj.getInstanceForComponent(parent,con.Destination.Component);
                        end

                        i.Name=[i.source.Name,'->',i.dest.Name];
                        parent.children.add(i);
                        parent.analysisModel.instances.add(i);
                        obj.addProperties(i,con);
                    end

                end
            end
        end

        function i=createInstance(obj,comp,parent,populateConnections)
            i=systemcomposer.internal.analysis.NodeInstance(obj.model);
            i.Name=comp.Name;

            parent.children.add(i);
            parent.analysisModel.instances.add(i);

            if~isempty(comp.Type)
                obj.populateChildren(i,comp.Type,populateConnections);
            end

            obj.addProperties(i,comp);
        end

        function i=createAllocationInstance(obj,target,source,name)
            i=systemcomposer.internal.analysis.AllocationInstance(obj.model);
            i.from=source;
            i.to=target;
            i.Name=name;

            target.children.add(i);
            target.sourceInstances.add(i.from);
            target.analysisModel.instances.add(i);
        end

        function i=findAllocationInstance(obj,target,source)
            i=[];
            sources=target.sources.toArray;
            for s=1:length(sources)
                if sources(s).from==source
                    i=sources(s);
                    return
                end
            end
        end

        function populateChildren(obj,parent,architecture,populateConnections)

            ownedBlocks=architecture.ChildComponents.toArray;
            for c=1:length(ownedBlocks)
                comp=ownedBlocks(c);
                i=obj.createInstance(comp,parent,populateConnections);
            end
            if(populateConnections)
                connectors=architecture.Connectors.toArray;
                for c=1:length(connectors)
                    con=connectors(c);

                    if(isempty(con.Source.Component))
                        source=parent;
                    else
                        source=obj.getInstanceForComponent(parent,con.Source.Component);
                    end

                    if(isempty(con.Destination.Component))
                        dest=parent;
                    else
                        dest=obj.getInstanceForComponent(parent,con.Destination.Component);
                    end
                    name=[source.Name,'->',dest.Name];
                    if isempty(parent.children.getByKey(name))
                        i=systemcomposer.internal.analysis.ConnectorInstance(obj.model);
                        i.Name=name;
                        i.source=source;
                        i.dest=dest;
                        parent.children.add(i);
                        parent.analysisModel.instances.add(i);
                        obj.addProperties(i,con);
                    else
                        g=1;

                    end
                end
            end
        end

        function addPropertyUsage(obj,metaclass)
            propSetWrapper=obj.analysisObject.findPropertySet(metaclass.qualifiedName);
            if(~isempty(propSetWrapper))
                propSet=propSetWrapper.mfObject;
                obj.mfObject.ownedPropertySetUsages.add(obj.usePropertySet(obj.mfObject,propSet,propSet.Name));
            end

            propSetWrapper=obj.analysisObject.findPropertySet([metaclass.qualifiedName,'#Target']);
            if(~isempty(propSetWrapper))
                propSet=propSetWrapper.mfObject;
                obj.mfObject.ownedPropertySetUsages.add(obj.usePropertySet(obj.mfObject,propSet,propSet.Name));
            end
        end

        function setSource(obj,source)
            obj.mfObject.source=source.mfObject;
        end

        function setupProperties(obj,definition)
            obj.addPropertyUsage(sl.sysarchModel.arch.Architecture.StaticMetaClass);
            obj.addPropertyUsage(sl.sysarchModel.arch.Connector.StaticMetaClass);
            obj.addPropertyUsage(sl.sysarchModel.arch.Component.StaticMetaClass);

            propSetWrapper=obj.analysisObject.findPropertySet('inputs');
            if~isempty(propSetWrapper)
                inputSet=propSetWrapper.mfObject;
                obj.mfObject.inputs=obj.usePropertySet(obj.mfObject,inputSet,inputSet.Name);
                obj.mfObject.ownedPropertySetUsages.add(obj.mfObject.inputs);
            end
            propSetWrapper=obj.analysisObject.findPropertySet('results');
            if~isempty(propSetWrapper)
                resultSet=propSetWrapper.mfObject;
                obj.mfObject.results=obj.usePropertySet(obj.mfObject,resultSet,resultSet.Name);
                obj.mfObject.ownedPropertySetUsages.add(obj.mfObject.results);
            end
        end

        function root=getRoot(obj)
            root=systemcomposer.internal.analysis.AnalysisNodeInstance(obj.mfObject.root,obj.model);
        end

        function setInstanceValue(obj,propertyString,value)


            i=obj.mfObject.root.getPropertyValue(propertyString);

            if isempty(i.value)
                i.defaultValue=obj.convertMxArrayToValueSpecification(value);
            else
                i.value.value=value;
            end
        end

        function value=getInstanceValue(obj,propertyString)

            vs=obj.mfObject.root.getPropVal(propertyString);
            if~isempty(vs)
                value=obj.convertValueSpecificationToMxArray(vs);
            else
                value=[];
            end
        end

        function setDefaultValue(obj,propertyString,value)

            usage=obj.mfObject.defaults.ownedPropertyUsages.getByKey(propertyString);

            if isempty(usage.defaultValue)
                usage.defaultValue=obj.convertMxArrayToValueSpecification(value);
            else
                usage.defaultValue.value=value;
            end
        end

        function value=getDefaultValue(obj,propertyString)

            vs=obj.mfObject.defaults.ownedPropertyUsages.getByKey(propertyString).defaultValue;
            value=obj.convertValueSpecificationToMxArray(vs);
        end

        function setInputValue(obj,propertyString,value)


            usage=obj.mfObject.inputs.ownedPropertyUsages.getByKey(propertyString);
            if isempty(usage.defaultValue)
                usage.defaultValue=obj.convertMxArrayToValueSpecification(value);
            else
                usage.defaultValue.value=value;
            end
        end

        function value=getInputValue(obj,propertyString)


            vs=obj.mfObject.inputs.ownedPropertyUsages.getByKey(propertyString).initialValue;
            value=obj.convertValueSpecificationToMxArray(vs);
        end

        function setResultValue(obj,propertyString,value)


            usage=obj.mfObject.results.ownedPropertyUsages.getByKey(propertyString);
            if isempty(usage.initialValue)
                usage.initialValue=obj.convertMxArrayToValueSpecification(value);
            else
                usage.initialValue.value=value;
            end
        end

        function value=getResultValue(obj,propertyString)


            vs=obj.mfObject.results.ownedPropertyUsages.getByKey(propertyString).defaultValue;
            value=obj.convertValueSpecificationToMxArray(vs);
        end
    end
end

