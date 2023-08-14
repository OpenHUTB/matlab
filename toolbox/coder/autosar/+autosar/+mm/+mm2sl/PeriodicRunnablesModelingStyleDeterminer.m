classdef PeriodicRunnablesModelingStyleDeterminer<handle




    properties(Access=private)
        M3iComponent;
        IRTRunnables={};
        SuitableModelingStyles;
        LimitationMsg;
        M3iSwcTiming;
    end

    methods
        function this=PeriodicRunnablesModelingStyleDeterminer(...
            m3iComp,initializationRunnable,resetRunnables,terminateRunnable,m3iSwcTiming)
            this.M3iComponent=m3iComp;


            if~isempty(initializationRunnable)
                this.IRTRunnables{end+1}=initializationRunnable;
            end

            if~isempty(resetRunnables)
                assert(iscellstr(resetRunnables)||isstring(resetRunnables));
                this.IRTRunnables=[this.IRTRunnables,resetRunnables];
            end

            if~isempty(terminateRunnable)
                this.IRTRunnables{end+1}=terminateRunnable;
            end

            this.M3iSwcTiming=m3iSwcTiming;
        end

        function[isSupported,resolvedStyle,LimitationMsg]=...
            isStyleSupported(this,modelPeriodicRunnablesAs)


            this.determine();

            switch(modelPeriodicRunnablesAs)
            case 'Auto'
                resolvedStyle=this.getPreferred();
                isSupported=~isempty(resolvedStyle);
            case this.SuitableModelingStyles
                resolvedStyle=modelPeriodicRunnablesAs;
                isSupported=true;
            otherwise
                isSupported=false;
                resolvedStyle='';

            end
            LimitationMsg=this.LimitationMsg;
        end
    end

    methods(Static)
        function allRunnablePeriods=collectPeriodicRunnableSampleTimes(m3iRunnables)
            allRunnablePeriods=[];
            for runIdx=1:m3iRunnables.size()
                [isPeriodic,m3iTimingEvent]=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(...
                m3iRunnables.at(runIdx),...
                Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
                if isPeriodic
                    allRunnablePeriods=[allRunnablePeriods;m3iTimingEvent.Period];%#ok<AGROW>
                end
            end
        end
    end

    methods(Access=private)
        function determine(this)

            m3iComp=this.M3iComponent;
            m3iBehavior=m3iComp.Behavior;
            swcQName=autosar.api.Utils.getQualifiedName(m3iComp);





            this.SuitableModelingStyles={'FunctionCallSubsystem'};



            if~m3iBehavior.isvalid()||(m3iBehavior.Runnables.size()==0)
                this.SuitableModelingStyles=[this.SuitableModelingStyles,{'AtomicSubsystem'}];
                return;
            end





            m3iRunnables=m3iBehavior.Runnables;
            [hasServerRun,runnableName]=this.containsServerRunnables(m3iRunnables);
            if hasServerRun
                this.LimitationMsg=message('autosarstandard:importer:ContainsServerRunnables',...
                swcQName,runnableName);
                return;
            end





            m3iRunnables=m3iBehavior.Runnables;
            [hasIntTrigRun,runnableName]=this.containsInternallyTriggeredRunnables(m3iRunnables);
            if hasIntTrigRun
                this.LimitationMsg=message('autosarstandard:importer:ContainsInternallyTriggeredRunnables',...
                swcQName,runnableName);
                return;
            end




            periodicRunnablesSampleTimes=this.collectPeriodicRunnableSampleTimes(m3iRunnables);
            if isempty(periodicRunnablesSampleTimes)
                this.LimitationMsg=message('autosarstandard:importer:NoPeriodicRunnables',...
                swcQName);
                return;
            end





            [areMultiple,fastestPeriod,violaterPeriod]=this.areRunnablePeriodsMultiple(periodicRunnablesSampleTimes);
            if~areMultiple
                this.LimitationMsg=message('autosarstandard:importer:RunnablePeriodsNotMultipleOfBaseRate',...
                swcQName,...
                Simulink.metamodel.arplatform.getRealStringCompact(violaterPeriod),...
                Simulink.metamodel.arplatform.getRealStringCompact(fastestPeriod));
                return;
            end





            [hasMultEvents,runnableName]=this.containsPeriodicRunnableWithMultipleEvents(m3iRunnables);
            if hasMultEvents
                this.LimitationMsg=message('autosarstandard:importer:PeriodicRunnableWithMultipleEvents',...
                swcQName,runnableName);
                return;
            end















            [hasSameDataAccess,accessedData,runnables]=this.sameDataAccessByDifferentRunnables(...
            m3iRunnables,this.IRTRunnables);
            if hasSameDataAccess
                this.LimitationMsg=message('autosarstandard:importer:DifferentRunnablesAccessingSameData',...
                swcQName,runnables{1},runnables{2},accessedData);
                return;
            end









            [multiReadWriteIRVDetected,violatingIRV,run1,run2]=...
            this.containsMultiReadWriteIRVs(m3iRunnables,this.IRTRunnables);
            if multiReadWriteIRVDetected
                this.LimitationMsg=message('autosarstandard:importer:ContainsMultiReadWriteIRVs',...
                swcQName,violatingIRV,run1,run2);
                return;
            end



            isViolatingRateMonotonicPolicy=...
            autosar.timing.mm2sl.BaseViewBuilder.isViolatingRateMonotonicPolicy(this.M3iSwcTiming);
            if isViolatingRateMonotonicPolicy
                this.LimitationMsg=message('autosarstandard:importer:ViolateRateMonotonicPolicy',swcQName);
                return;
            end



            this.SuitableModelingStyles=[this.SuitableModelingStyles,{'AtomicSubsystem'}];
        end

        function style=getPreferred(this)
            style='';
            if any(strcmp(this.SuitableModelingStyles,'AtomicSubsystem'))
                style='AtomicSubsystem';
            elseif any(strcmp(this.SuitableModelingStyles,'FunctionCallSubsystem'))
                style='FunctionCallSubsystem';
            end
        end
    end

    methods(Static,Access=private)
        function[hasServerRun,runnableName]=containsServerRunnables(m3iRunnables)
            hasServerRun=false;
            runnableName='';
            for runIdx=1:m3iRunnables.size()
                if autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRunnables.at(runIdx),...
                    Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass)
                    hasServerRun=true;
                    runnableName=m3iRunnables.at(runIdx).Name;
                    return;
                end
            end
        end

        function[hasIntTrigRun,runnableName]=containsInternallyTriggeredRunnables(m3iRunnables)
            hasIntTrigRun=false;
            runnableName='';
            for runIdx=1:m3iRunnables.size()
                if autosar.mm.mm2sl.RunnableHelper.isInternallyTriggeredRunnable(m3iRunnables.at(runIdx))
                    hasIntTrigRun=true;
                    runnableName=m3iRunnables.at(runIdx).Name;
                    return;
                end
            end
        end

        function[areMultiple,fastestPeriod,violaterPeriod]=...
            areRunnablePeriodsMultiple(allRunnablePeriods)
            areMultiple=true;
            violaterPeriod=[];
            fastestPeriod=[];
            if length(allRunnablePeriods)>1
                sortedPeriods=sort(allRunnablePeriods);
                fastestPeriod=sortedPeriods(1);
                for periodIdx=2:length(sortedPeriods)
                    if mod(sortedPeriods(periodIdx),fastestPeriod)~=0
                        violaterPeriod=sortedPeriods(periodIdx);
                        areMultiple=false;
                        return;
                    end
                end
            end
        end

        function[hasMultEvents,runnableName]=...
            containsPeriodicRunnableWithMultipleEvents(m3iRunnables)
            hasMultEvents=false;
            runnableName='';
            for runIdx=1:m3iRunnables.size()
                m3iRun=m3iRunnables.at(runIdx);
                if(m3iRun.Events.size()>1)&&...
                    autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                    Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass)
                    hasMultEvents=true;
                    runnableName=m3iRun.Name;
                    return;
                end
            end
        end

        function[hasSameDataAccess,accessedData,runnables]=...
            sameDataAccessByDifferentRunnables(m3iRunnables,irtRunnables)
            hasSameDataAccess=false;
            accessedData=[];
            runnables={};

            accessToRunnableMap=containers.Map();
            for runIdx=1:m3iRunnables.size()
                m3iRun=m3iRunnables.at(runIdx);

                if ismember(m3iRun.Name,irtRunnables)
                    continue;
                end


                for dIdx=1:m3iRun.dataAccess.size()
                    iRef=m3iRun.dataAccess.at(dIdx).instanceRef;
                    if~isempty(iRef)&&iRef.isvalid()
                        accessName=sprintf('Port = %s, Element = %s',...
                        autosar.api.Utils.getQualifiedName(iRef.Port),...
                        autosar.api.Utils.getQualifiedName(iRef.DataElements));
                        if accessToRunnableMap.isKey(accessName)&&...
                            ~isequal(accessToRunnableMap(accessName),m3iRun.Name)
                            hasSameDataAccess=true;
                            accessedData=accessName;
                            runnables={accessToRunnableMap(accessName),m3iRun.Name};
                            return;
                        else
                            accessToRunnableMap(accessName)=m3iRun.Name;
                        end
                    end
                end


                for dIdx=1:m3iRun.ModeAccessPoint.size()
                    iRef=m3iRun.ModeAccessPoint.at(dIdx).InstanceRef;
                    if~isempty(iRef)&&iRef.isvalid()
                        accessName=sprintf('Port = %s, Element = %s',...
                        autosar.api.Utils.getQualifiedName(iRef.Port),...
                        autosar.api.Utils.getQualifiedName(iRef.groupElement));
                        if accessToRunnableMap.isKey(accessName)&&...
                            ~isequal(accessToRunnableMap(accessName),m3iRun.Name)
                            hasSameDataAccess=true;
                            accessedData=accessName;
                            runnables={accessToRunnableMap(accessName),m3iRun.Name};
                            return;
                        else
                            accessToRunnableMap(accessName)=m3iRun.Name;
                        end
                    end
                end


                for dIdx=1:m3iRun.ModeSwitchPoint.size()
                    iRef=m3iRun.ModeSwitchPoint.at(dIdx).InstanceRef;
                    if~isempty(iRef)&&iRef.isvalid()
                        accessName=sprintf('Port = %s, Element = %s',...
                        autosar.api.Utils.getQualifiedName(iRef.Port),...
                        autosar.api.Utils.getQualifiedName(iRef.groupElement));
                        if accessToRunnableMap.isKey(accessName)&&...
                            ~isequal(accessToRunnableMap(accessName),m3iRun.Name)
                            hasSameDataAccess=true;
                            accessedData=accessName;
                            runnables={accessToRunnableMap(accessName),m3iRun.Name};
                            return;
                        else
                            accessToRunnableMap(accessName)=m3iRun.Name;
                        end
                    end
                end
            end
        end

        function[multiReadWriteIRVDetected,violatingIRV,run1,run2]=...
            containsMultiReadWriteIRVs(m3iRunnables,irtRunnables)
            irvReadToRunnablesMap=containers.Map;
            irvWriteToRunnablesMap=containers.Map;
            multiReadWriteIRVDetected=false;
            violatingIRV='';
            run1='';
            run2='';
            for runIdx=1:m3iRunnables.size()
                m3iRun=m3iRunnables.at(runIdx);

                if ismember(m3iRun.Name,irtRunnables)
                    continue;
                end

                irvReads=m3iRun.irvRead;
                for idx=1:irvReads.size()
                    irvInstanceRef=irvReads.at(idx).instanceRef;
                    if irvInstanceRef.isvalid&&~isempty(irvInstanceRef.DataElements)
                        irvName=irvInstanceRef.DataElements.Name;
                        if isKey(irvReadToRunnablesMap,irvName)&&...
                            ~isequal(irvReadToRunnablesMap(irvName),m3iRun.Name)
                            violatingIRV=irvName;
                            run1=m3iRun.Name;
                            run2=irvReadToRunnablesMap(irvName);
                            multiReadWriteIRVDetected=true;
                            return;
                        else
                            irvReadToRunnablesMap(irvName)=m3iRun.Name;
                        end
                    end
                end

                irvWrites=m3iRun.irvWrite;
                for idx=1:irvWrites.size()
                    irvInstanceRef=irvWrites.at(idx).instanceRef;
                    if irvInstanceRef.isvalid&&~isempty(irvInstanceRef.DataElements)
                        irvName=irvInstanceRef.DataElements.Name;
                        if isKey(irvWriteToRunnablesMap,irvName)&&...
                            ~isequal(irvWriteToRunnablesMap(irvName),m3iRun.Name)
                            violatingIRV=irvName;
                            run1=m3iRun.Name;
                            run2=irvWriteToRunnablesMap(irvName);
                            multiReadWriteIRVDetected=true;
                            return;
                        else
                            irvWriteToRunnablesMap(irvName)=m3iRun.Name;
                        end
                    end
                end
            end
        end
    end
end


