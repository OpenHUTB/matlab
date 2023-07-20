classdef AnalysisBase<systemcomposer.internal.analysis.AnalysisObject



    properties
        instance=[];
        currentArchitecture=[];
        currentArchitectureModel=[];
        sourceArchitecture=[];
        sourceArchitectureModel=[];
        currentRunId=0;
        propertySets={};
    end
    methods(Abstract)
        handleComputedValue(this,value,node);
        set=assignPropertySet(obj,metaclass,isTarget);
    end
    methods(Static)

    end
    methods
        function res=isAllocation(obj)
            res=false;
        end
        function show=showTargetProperties(obj)
            show=false;
        end

        function psu=usePropertySet(obj,model,dest,set,name)
            psu=systemcomposer.property.PropertySetUsage(model);
            psu.Name=name;
            psu.propertySet=set;

            props=set.ownedPropertyDefinitions.toArray;

            for p=1:length(props)
                prop=props(p);
                pu=systemcomposer.property.PropertyUsage(model);
                psu.ownedPropertyUsages.add(pu);
                pu.Name=prop.Name;
                pu.propertyDef=prop;
                pu.initialValue=systemcomposer.internal.analysis.AnalysisService.copyValueSpecification(model,prop.defaultValue);
            end

            dest.ownedPropertySetUsages.add(psu);
        end

        function setInitialValue(obj,pathString,value)
            path=regexp(pathString,'\.','split');
            componentName=path{1};
            propertyName=path{2};

            isTarget=true;
            component=obj.currentArchitecture.ChildComponents.getByKey(componentName);
            catalog=obj.currentArchitecture.Catalog;

            if isempty(component)&&~isempty(obj.sourceArchitecture)
                component=obj.sourceArchitecture.ChildComponents.getByKey(componentName);
                isTarget=false;
                catalog=obj.sourceArchitecture.Catalog;
            end

            if~isempty(component)

                propSetName=obj.getAnalysisName();

                if isempty(component.ownedPropertySetUsages.getByKey(propSetName))

                    ps=obj.getPropertySetForComponent(catalog,component,isTarget);

                    if isTarget
                        model=obj.currentArchitectureModel;
                    else
                        model=obj.sourceArchitectureModel;
                    end

                    usage=obj.usePropertySet(model,component,ps,propSetName);

                end

                component.setPropVal(propSetName,propertyName,value);
            end
        end

        function ps=getPropertySetForComponent(obj,catalog,component,isTarget)
            name=component.StaticMetaClass.qualifiedName;
            if(isTarget)
                name=[name,'#Target'];
            end
            ps=catalog.PropertySetManager.ownedPropertySets.getByKey(name);
        end

        function v=getInitialValue(obj,componentName,propertyName)

            component=obj.currentArchitecture.ChildComponents.getByKey(componentName);

            if isempty(component)&&~isempty(obj.sourceArchitecture)
                component=obj.sourceArchitecture.ChildComponents.getByKey(componentName);
            end

            if~isempty(component)

                propSetName=obj.getAnalysisName();


                v=component.getPropVal(propSetName,propertyName);
            end
        end
        function obj=AnalysisBase()

            model=mf.zero.Model;
            obj=obj@systemcomposer.internal.analysis.AnalysisObject(model);
            txn=obj.model.beginTransaction();


            obj.mfObject=systemcomposer.internal.analysis.AnalysisSet(obj.model);
            obj.mfObject.Name=obj.getAnalysisName();
            definition=systemcomposer.internal.analysis.AnalysisDefinition(obj.model);
            obj.mfObject.definition=definition;
            definition.Name=obj.mfObject.Name;
            obj.addPropertySets(model,definition);
            txn.commit;
            systemcomposer.internal.analysis.AnalysisService.addAnalysisSet(obj);
        end

        function defineAnalysisInputs(obj,set)

        end

        function defineAnalysisResults(obj,set)

        end

        function calculateResults(obj,model)
        end

        function updated=update(obj,instance)
            updated=false;
        end

        function setDefaultValue(obj,propertyString,value)

            prop=obj.mfObject.definition.instanceDefinition.ownedPropertyDefinitions.getByKey(propertyString);
            prop.defaultValue.value=value;
        end

        function setUsageDefaultValue(obj,uuid,propertyString,value)

            modelElement=obj.currentArchitectureModel.findElement(uuid);
            if isempty(modelElement)
                set=obj.model.findElement(uuid);
                txn=obj.model.beginTransaction;
            else
                set=modelElement.ownedPropertySetUsages.getByKey(obj.getAnalysisName());
                txn=obj.currentArchitectureModel.beginTransaction;
            end

            prop=set.ownedPropertyUsages.getByKey(propertyString);
            prop.initialValue.value=str2num(value);
            txn.commit;
        end

        function value=getDefaultValue(obj,propertyString)

            prop=obj.mfObject.definition.instanceDefinition.ownedPropertyDefinitions.getByKey(propertyString);
            value=prop.defaultValue.value;
        end

        function uuid=getUUID(obj)
            uuid=obj.mfObject.UUID;
        end

        function setPropertyValue(obj,uuid,propertyName,propertyValue)
            txn=obj.model.beginTransaction;
            o=obj.model.findElement(uuid);
            i=o.getPropertyValue(propertyName);

            if isempty(i.value)
                i.value=obj.convertMxArrayToValueSpecification(str2num(propertyValue));
            else
                i.value.value=str2num(propertyValue);
            end
            wrappedInstance=systemcomposer.internal.analysis.AnalysisInstance(o,obj.model);
            obj.updateInternal(wrappedInstance);
            txn.commit;
        end

        function analyseModelWithUUID(obj,ModelUUID)
            mod=obj.model.findElement(ModelUUID);
            m=systemcomposer.internal.analysis.AnalysisModel(mod,obj.model);


            obj.analyseInternal(m);


            sourceMod=obj.findSource(mod);
            s=systemcomposer.internal.analysis.AnalysisModel(sourceMod,obj.model);
            obj.analyseInternal(s);
        end

        function source=findSource(obj,target)
            source=target.source;
        end

        function updateModelWithUUID(obj,ModelUUID)
            mod=obj.model.findElement(ModelUUID);
            m=systemcomposer.internal.analysis.AnalysisModel(mod,obj.model,obj);
            obj.refreshInternal(m);
        end

        function mod=createNewModel(obj)
            mod=obj.instantiateInternal();
        end

        function mod=instantiateInternal(obj)
            mod=obj.instantiate(obj.currentArchitecture,true,false);
        end

        function set=createAnalysisSet(obj,arch,archModel)

        end


        function setSourceArchitecture(obj,architecture,model)
            obj.sourceArchitecture=architecture;
            obj.sourceArchitectureModel=model;
            txn=model.beginTransaction;


            tl=model.topLevelElements();
            for t=1:length(tl)
                if isa(tl(t),'sl.sysarchModel.arch.ModelCatalog')
                    definition=tl(t).PropertySetManager;
                    break;
                end
            end








            definition.Name=obj.mfObject.Name;
            obj.copyPropertySets(definition,model);

            txn.commit;
        end

        function setArchitecture(obj,architecture,model)
            obj.currentArchitecture=architecture;
            obj.currentArchitectureModel=model;
            txn=model.beginTransaction;


            tl=model.topLevelElements();
            for t=1:length(tl)
                if isa(tl(t),'sl.sysarchModel.arch.ModelCatalog')
                    definition=tl(t).PropertySetManager;
                    break;
                end
            end








            definition.Name=obj.mfObject.Name;
            obj.copyPropertySets(definition,model);

            txn.commit;
        end

        function updateInternal(this,instance)


            name=instance.mfObject.MetaClass.name;

            if(strcmp(name,'NodeInstance'))
                metaclassName=sl.sysarchModel.arch.Component.StaticMetaClass.qualifiedName;
            else
                metaclassName=sl.sysarchModel.arch.Connector.StaticMetaClass.qualifiedName;
            end

            propertySet=this.findPropertySet(metaclassName);
            if~propertySet.update(instance)
                this.update(instance);
            end
        end

        function ps=findPropertySet(this,name)
            ps=[];
            for p=1:length(this.propertySets)
                if strcmp(this.propertySets{p}.name,name)
                    ps=this.propertySets{p};
                    return;
                end
            end
        end

        function copyPropertySets(obj,definition,model)
            for p=1:length(obj.propertySets)
                psWrapper=obj.propertySets{p};
                newWrapper=psWrapper.clone(model);
                newWrapper.processProperties(definition,model);
            end
        end

        function addPropertySet(obj,model,definition,metaclass)
            psWrapper=obj.assignPropertySet(metaclass,true);
            psWrapper.setName([metaclass.qualifiedName,'#Target']);
            psWrapper.processProperties(definition,model);
            obj.propertySets{end+1}=psWrapper;
            psWrapper=obj.assignPropertySet(metaclass,false);
            psWrapper.setName(metaclass.qualifiedName);
            psWrapper.processProperties(definition,model);
            obj.propertySets{end+1}=psWrapper;
        end

        function addPropertySets(obj,model,definition)
            obj.addPropertySet(model,definition,sl.sysarchModel.arch.Architecture.StaticMetaClass);
            obj.addPropertySet(model,definition,sl.sysarchModel.arch.Component.StaticMetaClass);
            obj.addPropertySet(model,definition,sl.sysarchModel.arch.Connector.StaticMetaClass);

            psWrapper=systemcomposer.internal.analysis.AnalysisPropertySet(model);
            psWrapper.setName('inputs');
            obj.defineAnalysisInputs(psWrapper);
            psWrapper.processProperties(definition,model);
            if~psWrapper.empty()
                obj.propertySets{end+1}=psWrapper;
            end

            psWrapper=systemcomposer.internal.analysis.AnalysisPropertySet(model);
            obj.defineAnalysisResults(psWrapper);
            psWrapper.setName('results');
            psWrapper.processProperties(definition,model);
            if~psWrapper.empty()
                obj.propertySets{end+1}=psWrapper;
            end
        end

        function model=analyse(obj,model)
            obj.analyseInternal(model);
        end

        function handleComputedValues(obj,modObj,processRoot)


            instances=modObj.mfObject.instances.toArray;

            for i=1:length(instances)
                instance=instances(i);

                propertyValues=instance.values.toArray;
                if instance~=modObj.mfObject.root||processRoot
                    for p=1:length(propertyValues)
                        value=propertyValues(p);
                        cs=value.usage.propertyDef.computationScope;

                        if cs==systemcomposer.property.Scope.COMPUTED
                            obj.handleComputedValue(value,instance);
                            if~value.readOnly


                            else
                                value.value.destroy;
                            end
                        end
                    end
                else
                    for p=1:length(propertyValues)
                        value=propertyValues(p);
                        if~isempty(value)&&~isempty(value.value)
                            value.value.destroy;
                        end
                    end
                end
            end
        end

        function res=populateConnections(obj)
            res=false;
        end

        function res=computeRootValues(obj)
            res=true;
        end

        function model=refreshInternal(obj,model)
            txn=obj.model.beginTransaction();
            model.updateRoot(true);
            txn.commit;
        end

        function modObj=instantiate(obj,system,addToSet,isTarget)

            if(nargin<2)


                system=obj.currentArchitecture;
            end


            txn=obj.model.beginTransaction();


            mod=systemcomposer.internal.analysis.InstanceModel(obj.model);
            obj.currentRunId=obj.currentRunId+1;
            mod.Name=['analysis: ',num2str(obj.currentRunId)];

            if addToSet
                obj.mfObject.models.add(mod);
            end


            modObj=systemcomposer.internal.analysis.AnalysisModel(mod,obj.model,obj);
            modObj.setupProperties(obj.mfObject.definition);
            modObj.createRoot(system,obj.populateConnections(),isTarget);
            obj.handleComputedValues(modObj,obj.computeRootValues());
            txn.commit;
        end

    end
end

