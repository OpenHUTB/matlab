classdef(Hidden,Abstract)BaseViewBuilder<handle




    properties(Transient,SetAccess=protected)
        ModelName;
        M3iModel;
        UpdateMode;
    end

    methods(Abstract)
        findM3iTiming(this)


        assignOrderIndex(this,m3iEOCExecutableEntityRefs);


    end

    methods
        function this=BaseViewBuilder(modelName,updateMode)
            this.ModelName=modelName;
            this.M3iModel=autosar.api.Utils.m3iModel(modelName);
            this.UpdateMode=updateMode;
        end

        function build(this)
            m3iTiming=this.findM3iTiming();
            if isempty(m3iTiming)

                return
            end


            this.honorExecutionOrderConstraints(m3iTiming);
        end
    end

    methods(Access=private)
        function honorExecutionOrderConstraints(this,m3iTiming)

            m3iEOC=autosar.timing.mm2sl.BaseViewBuilder.getM3iEOCForTimingView(m3iTiming);
            if isempty(m3iEOC)
                return
            end


            sortedEOCExecutableEntityRefs=this.sortExecutionOrderConstraints(m3iEOC);
            if isempty(sortedEOCExecutableEntityRefs)
                if this.UpdateMode
                    MSLDiagnostic('autosarstandard:importer:UnableToUpdateExecutionOrderConstraints').reportAsWarning;
                else
                    MSLDiagnostic('autosarstandard:importer:UnableToImportExecutionOrderConstraints').reportAsWarning;
                end
                return
            end


            this.assignOrderIndex(sortedEOCExecutableEntityRefs);
        end
    end

    methods(Static)
        function isViolatingRM=isViolatingRateMonotonicPolicy(m3iTiming)




            isViolatingRM=false;

            m3iEOC=autosar.timing.mm2sl.BaseViewBuilder.getM3iEOCForTimingView(m3iTiming);
            if isempty(m3iEOC)
                return
            end

            EOCExecutableEntityRefs=autosar.timing.mm2sl.BaseViewBuilder.sortExecutionOrderConstraints(m3iEOC);
            for i=1:length(EOCExecutableEntityRefs)
                m3iRunnablePre=EOCExecutableEntityRefs{i}.Executable;
                m3iRunnableSucc=EOCExecutableEntityRefs{i}.Successor.at(1).Executable;
                periodPre=autosar.timing.mm2sl.BaseViewBuilder.findPeriodFromRunnable(m3iRunnablePre);
                periodSucc=autosar.timing.mm2sl.BaseViewBuilder.findPeriodFromRunnable(m3iRunnableSucc);

                if periodPre==-1||periodSucc==-1
                    continue
                end

                if periodPre>periodSucc
                    isViolatingRM=true;
                    return
                end
            end
        end
    end

    methods(Access=protected,Static)
        function sortedOrder=sortExecutionOrderConstraints(m3iEOC)


            m3iEOCExecutableEntityRefs=autosar.timing.mm2sl.BaseViewBuilder.convertM3iEOCToEOCExecutableEntityRefs(m3iEOC);
            sortedOrder=autosar.timing.mm2sl.BaseViewBuilder.sortEOCExecutableEntityRefs(m3iEOCExecutableEntityRefs);
        end
    end

    methods(Access=private,Static)
        function m3iEOC=getM3iEOCForTimingView(m3iTiming)

            m3iEOC={};
            if isempty(m3iTiming)
                return
            end


            timingRequirements=m3iTiming.TimingRequirement;
            for tIndex=1:timingRequirements.size()
                if~isa(timingRequirements.at(tIndex),...
                    'Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint')
                    continue
                end


                m3iEOC{end+1}=timingRequirements.at(tIndex);%#ok<AGROW>
            end
        end

        function m3iEOCExecutableEntityRefs=convertM3iEOCToEOCExecutableEntityRefs(m3iEOC)


            m3iEOCExecutableEntityRefs={};
            for i=1:length(m3iEOC)
                for j=1:m3iEOC{i}.OrderedElement.size()
                    orderedElement=m3iEOC{i}.OrderedElement.at(j);

                    if~isa(orderedElement.Executable,'Simulink.metamodel.arplatform.behavior.Runnable')
                        continue
                    end

                    successors=orderedElement.Successor;
                    if successors.isEmpty()
                        continue
                    end


                    successorExecutable=successors.at(1).Executable;
                    if~isa(successorExecutable,'Simulink.metamodel.arplatform.behavior.Runnable')
                        continue
                    end

                    m3iEOCExecutableEntityRefs{end+1}=orderedElement;%#ok<AGROW>
                end
            end
        end

        function sortedOrder=sortEOCExecutableEntityRefs(m3iEOCExecutableEntityRefs)


            sortedOrder={};
            while~isempty(m3iEOCExecutableEntityRefs)
                EOCExecutableEntityRef=...
                autosar.timing.mm2sl.BaseViewBuilder.EOCExecutableEntityRefNotDependentOnPredecessor(m3iEOCExecutableEntityRefs);
                if isempty(EOCExecutableEntityRef)
                    sortedOrder={};
                    return
                end


                sortedOrder{end+1}=EOCExecutableEntityRef;%#ok<AGROW>



                index=arrayfun(@(x)(...
                strcmp(EOCExecutableEntityRef.Executable.Name,m3iEOCExecutableEntityRefs{x}.Executable.Name)&&...
                isequal(EOCExecutableEntityRef.Component,m3iEOCExecutableEntityRefs{x}.Component)),1:length(m3iEOCExecutableEntityRefs));
                m3iEOCExecutableEntityRefs(index)=[];
            end
        end

        function m3iEOCExecutableEntityRef=EOCExecutableEntityRefNotDependentOnPredecessor(m3iEOCExecutableEntityRefs)


            m3iEOCExecutableEntityRef='';
            for i=1:length(m3iEOCExecutableEntityRefs)


                executableName=m3iEOCExecutableEntityRefs{i}.Executable.Name;
                executableComponent=m3iEOCExecutableEntityRefs{i}.Component;
                isSuccessor=arrayfun(@(x)(...
                strcmp(executableName,m3iEOCExecutableEntityRefs{x}.Successor.at(1).Executable.Name)&&...
                isequaln(executableComponent,m3iEOCExecutableEntityRefs{x}.Successor.at(1).Component)),1:length(m3iEOCExecutableEntityRefs));
                if any(isSuccessor)
                    continue
                end



                m3iEOCExecutableEntityRef=m3iEOCExecutableEntityRefs{i};
                return
            end
        end

        function period=findPeriodFromRunnable(m3iRunnable)


            period=-1;


            [isPeriodic,m3iTimingEvent]=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRunnable,...
            Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
            if~isPeriodic
                return
            end


            period=m3iTimingEvent.Period;
        end
    end
end


