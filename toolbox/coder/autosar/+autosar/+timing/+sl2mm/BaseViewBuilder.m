classdef(Hidden,Abstract)BaseViewBuilder<handle




    properties(Transient,SetAccess=protected)
        ModelName;
        M3iModel;
    end

    methods(Abstract)
        findM3iTiming(this)


        createM3iTiming(this)


        updateOrCreateM3iExecutableEntityRefAttributes(this,m3iExecutableEntityRef,m3iRunnable,swcName)


        findM3iRunnableForRootSlEntryPointFunction(this,swcName,rootSlEntryPointFunction)


        getSortedListOfRootSlEntryPointFunctions(this)

    end

    methods
        function this=BaseViewBuilder(modelName)
            this.ModelName=modelName;
            this.M3iModel=autosar.api.Utils.m3iModel(modelName);
        end

        function build(this)







            [rootSlEntryPointFunctions,swcNames]=this.getSortedListOfRootSlEntryPointFunctions();
            m3iTiming=this.findM3iTiming();
            if isempty(m3iTiming)&&length(rootSlEntryPointFunctions)<2


                return
            end


            t=M3I.Transaction(this.M3iModel);

            if~isempty(m3iTiming)&&length(rootSlEntryPointFunctions)<2





                this.updateOrCreateM3iEOC(m3iTiming,rootSlEntryPointFunctions,swcNames);
            elseif isempty(m3iTiming)&&length(rootSlEntryPointFunctions)>=2




                m3iTiming=this.createM3iTiming();



                this.updateOrCreateM3iEOC(m3iTiming,rootSlEntryPointFunctions,swcNames);
            elseif~isempty(m3iTiming)&&length(rootSlEntryPointFunctions)>=2





                this.updateOrCreateM3iEOC(m3iTiming,rootSlEntryPointFunctions,swcNames);
            end


            t.commit();
        end
    end

    methods(Access=protected)
        function pkgTiming=getOrAddTimingPackage(this)

            m3iRoot=this.M3iModel.RootPackage.front();
            timingPackage=autosar.mm.util.XmlOptionsAdapter.get(m3iRoot,'TimingPackage');
            if isempty(timingPackage)
                timingPackage=autosar.mm.util.XmlOptionsDefaultPackages.TimingPackage;
                autosar.mm.util.XmlOptionsAdapter.set(m3iRoot,'TimingPackage',timingPackage);
            end

            pkgTiming=autosar.mm.Model.getOrAddARPackage(this.M3iModel,timingPackage);
        end

        function m3iEOConstraint=getOrAddM3iEOConstraintForTimingModel(this,m3iTiming)

            timingRequirements=m3iTiming.TimingRequirement;
            for tIndex=1:size(timingRequirements)
                if isa(timingRequirements.at(tIndex),'Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint')
                    m3iEOConstraint=timingRequirements.at(tIndex);
                    return
                end
            end


            m3iEOConstraint=Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint(this.M3iModel);
            m3iEOConstraint.Name='EOC';
            m3iTiming.TimingRequirement.append(m3iEOConstraint);
        end

        function newName=createUniqueTimingName(this,defaultName)
            m3iRoot=this.M3iModel.RootPackage.front();
            path=autosar.mm.util.XmlOptionsAdapter.get(m3iRoot,'TimingPackage');
            newName=autosar.api.Utils.createUniqueNameInSeq(this.ModelName,defaultName,path);
        end
    end

    methods(Access=private)
        function updateOrCreateM3iEOC(this,m3iTiming,rootSlEntryPointFunctions,swcNames)






            if length(rootSlEntryPointFunctions)<2

                this.clearEOConstraints(m3iTiming);
                return
            end



            this.ensureOneM3iEOConstraint(m3iTiming);


            m3iEOConstraint=this.getOrAddM3iEOConstraintForTimingModel(m3iTiming);
            orderedElements=m3iEOConstraint.OrderedElement;



            predecessorExecutableEntityRef='';
            for i=1:length(rootSlEntryPointFunctions)

                m3iRunnable=this.findM3iRunnableForRootSlEntryPointFunction(swcNames{i},rootSlEntryPointFunctions{i});
                if isempty(m3iRunnable)

                    this.clearEOConstraints(m3iTiming);
                    return
                end


                m3iExecutableEntityRef=this.getOrAddM3iExecutableEntityRef(orderedElements,i);


                this.updateOrCreateM3iExecutableEntityRefAttributes(m3iExecutableEntityRef,m3iRunnable,swcNames{i});

                if~isempty(m3iExecutableEntityRef.Successor)

                    m3iExecutableEntityRef.Successor.clear();
                end

                if~isempty(predecessorExecutableEntityRef)

                    predecessorExecutableEntityRef.Successor.append(m3iExecutableEntityRef);
                end

                predecessorExecutableEntityRef=m3iExecutableEntityRef;
            end



            for i=size(orderedElements):-1:length(rootSlEntryPointFunctions)+1
                orderedElements.at(i).destroy();
            end
        end

        function m3iExecutableEntityRef=getOrAddM3iExecutableEntityRef(this,orderedElements,index)

            if size(orderedElements)>=index
                m3iExecutableEntityRef=orderedElements.at(index);
                return
            end


            m3iExecutableEntityRef=Simulink.metamodel.arplatform.timingExtension.EOCExecutableEntityRef(this.M3iModel);
            orderedElements.append(m3iExecutableEntityRef);
        end
    end

    methods(Access=private,Static)
        function clearEOConstraints(m3iTiming)

            timingRequirements=m3iTiming.TimingRequirement;
            m3iEOConstraint='';
            for tIndex=1:size(timingRequirements)
                if isa(timingRequirements.at(tIndex),'Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint')
                    m3iEOConstraint=timingRequirements.at(tIndex);
                    break
                end
            end

            if isempty(m3iEOConstraint)

                return
            end


            orderedElements=m3iEOConstraint.OrderedElement;
            for i=size(orderedElements):-1:1
                orderedElements.at(i).destroy();
            end


            m3iEOConstraint.destroy();
        end

        function ensureOneM3iEOConstraint(m3iTiming)




            timingRequirements=m3iTiming.TimingRequirement;
            foundOneEOC=false;
            for tIndex=size(timingRequirements):-1:1
                if~isa(timingRequirements.at(tIndex),'Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint')
                    continue
                end

                if~foundOneEOC
                    foundOneEOC=true;
                else

                    m3iEOConstraint=timingRequirements.at(tIndex);


                    orderedElements=m3iEOConstraint.OrderedElement;
                    for i=size(orderedElements):-1:1
                        orderedElements.at(i).destroy();
                    end


                    m3iEOConstraint.destroy();
                end
            end
        end
    end
end


