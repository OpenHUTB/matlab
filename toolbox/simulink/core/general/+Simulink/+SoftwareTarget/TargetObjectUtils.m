


classdef TargetObjectUtils<handle
    methods(Static=true)
        function checkInvalidAccess(obj)
            bases=superclasses(obj);
            if isa(obj,'Simulink.SoftwareTarget.TargetSpecificTriggerConfigurationBase')&&...
                length(bases)==1
                DAStudio.error('Simulink:mds:InvalidTargetCustomization',class(obj));
            end
        end

        function checkInvalidTaskMapping(obj)
            mappings=obj.ParentTaskConfiguration.BlockToTaskMapping;
            numMappings=length(mappings);
            for ii=1:numMappings
                mapping=mappings(ii);
                block=mapping.Block;
                mappedElements=mapping.Tasks;
                numMappedElements=length(mappedElements);
                for jj=1:numMappedElements
                    mappedElement=mappedElements(jj);
                    if isa(mappedElement,'Simulink.SoftwareTarget.Task')
                        task=mappedElement;
                        eventHandler=task.ParentTaskGroup;
                        if(isa(eventHandler,'Simulink.SoftwareTarget.PeriodicTrigger'))
                            continue;
                        end
                        targetObject=eventHandler.TargetObject;
                        if isempty(targetObject)
                            targetObjectType='<empty>';
                        else
                            targetObjectType=class(targetObject);
                        end
                        DAStudio.error('Simulink:mds:TaskNotMappable',...
                        block,task.Name,eventHandler.Name,targetObjectType);
                    end
                end
            end
        end

        function checkInvalidMappings(obj)
            mappings=obj.ParentTaskConfiguration.BlockToTaskMapping;
            mappedAperiodicMappedElems={};
            mappedAperiodicTrigger={};
            mappedPeriodicMappedElems={};
            mappedPeriodicTrigger={};
            numMappings=length(mappings);

            for ii=1:numMappings
                mapping=mappings(ii);
                mappedElements=mapping.Tasks;
                for jj=1:length(mappedElements)
                    mappedElement=mappedElements(jj);
                    if isa(mappedElement,'Simulink.SoftwareTarget.Task')
                        trigger=mappedElement.ParentTaskGroup;
                    else
                        trigger=mappedElement;
                    end

                    if isa(trigger,'Simulink.SoftwareTarget.PeriodicTrigger')

                        for i=1:length(mappedPeriodicTrigger)



                            if(trigger==mappedPeriodicTrigger{i})&&...
                                ((isequal(mappedPeriodicMappedElems{i},trigger)&&...
                                isa(mappedElement,'Simulink.SoftwareTarget.Task'))||...
                                (isequal(mappedElement,trigger)&&...
                                isa(mappedPeriodicMappedElems{i},'Simulink.SoftwareTarget.Task')))
                                DAStudio.error('Simulink:mds:PeriodicTaskAndTriggerNotMappable',...
                                trigger.Name,mappedPeriodicMappedElems{i}.Name);
                            end
                        end
                        mappedPeriodicMappedElems{end+1}=mappedElement;%#ok<AGROW>
                        mappedPeriodicTrigger{end+1}=trigger;%#ok<AGROW>

                    else
                        assert(isa(trigger,'Simulink.SoftwareTarget.AperiodicTrigger'));
                        if~isprop(trigger,'TargetObject')||...
                            (isprop(trigger,'TargetObject')&&...
                            isempty(trigger.TargetObject))
                            continue;
                        end

                        targetObject=trigger.TargetObject;



                        for i=1:length(mappedAperiodicTrigger)
                            if trigger==mappedAperiodicTrigger{i}
                                DAStudio.error('Simulink:mds:TaskAndHandlerNotMappable',...
                                trigger.Name,class(targetObject),...
                                mappedAperiodicMappedElems{i}.Name);
                            end
                        end
                        mappedAperiodicMappedElems{end+1}=mappedElement;%#ok<AGROW>
                        mappedAperiodicTrigger{end+1}=trigger;%#ok<AGROW>
                    end
                end
            end
        end

        function checkInvalidCombinationOfTaskGroups(obj)
            numTaskGroups=length(obj.ParentTaskConfiguration.TaskGroups);
            triggerType='';
            taskGroup=[];%#ok
            taskGroups=obj.ParentTaskConfiguration.TaskGroups;
            for ii=1:numTaskGroups
                taskGroup=taskGroups(ii);
                if isa(taskGroup,'Simulink.SoftwareTarget.PeriodicTrigger')
                    continue;
                end
                if isempty(triggerType)
                    triggerType=taskGroups(ii).EventHandlerType;
                    continue;
                end
                if~isequal(triggerType,taskGroups(ii).EventHandlerType)
                    DAStudio.error('Simulink:mds:InvalidAperiodicTaskGroupCombination',...
                    triggerType,taskGroup.Name,...
                    taskGroups(ii).EventHandlerType,taskGroups(ii).Name,...
                    taskGroup.Name,taskGroups(ii).Name);
                end
            end
        end

        function[atg1,atg2]=checkTaskGroupsPropertyIsUnique(obj,ATGEvent,ATGProp)
            [atg1,atg2]=Simulink.SoftwareTarget.TargetObjectUtils.checkTaskGroupsPropertyIsUniqueOrSame(obj,ATGEvent,ATGProp,false);
        end

        function[atg1,atg2]=checkTaskGroupsPropertyIsSame(obj,ATGEvent,ATGProp)
            [atg1,atg2]=Simulink.SoftwareTarget.TargetObjectUtils.checkTaskGroupsPropertyIsUniqueOrSame(obj,ATGEvent,ATGProp,true);
        end

        function[atg1,atg2]=checkTaskGroupsPropertyIsUniqueOrSame(obj,ATGEvent,ATGProp,equal)
            atg1=[];
            atg2=[];

            prop2ATG=[];

            ATGs=obj.ParentTaskConfiguration.TaskGroups;
            for i=1:length(ATGs)
                ATG=ATGs(i);
                if(isequal(ATG.EventHandlerType,ATGEvent))


                    if isempty(ATG.MappedComponents)
                        continue;
                    end

                    if(ischar(ATGProp))
                        propValue=ATG.(ATGProp);
                    elseif(iscell(ATGProp))
                        propValue=ATG;
                        for j=1:length(ATGProp)
                            propValue=propValue.(ATGProp{j});
                        end
                    else

                        propValue='';
                    end

                    propValueStr=num2str(propValue);



                    if(isempty(prop2ATG))
                        prop2ATG=containers.Map('KeyType','char','ValueType','any');
                    elseif(prop2ATG.isKey(propValueStr)~=equal)

                        if(equal)
                            values=prop2ATG.values;
                            atg1=values{1};
                        else
                            atg1=prop2ATG(propValueStr);
                        end
                        atg2=ATG;
                        return;
                    end

                    prop2ATG(propValueStr)=ATG;%#ok
                end
            end
        end

        function os=osname
            arch=computer('arch');
            switch arch
            case{'win32','win64'}
                os='Microsoft Windows';
            case{'glnx86','glnxa64'}
                os='Linux';
            case 'maci64'
                os='Apple Mac OS X';
            otherwise
                os=arch;
            end
        end

        function checkIncompatibleAperiodicTrigger(obj)
            cs=getActiveConfigSet(obj.ParentTaskConfiguration.ParentDiagram);
            isNotCoderTarget=~cs.isValidParam('CoderTargetData');

            if ispc&&isNotCoderTarget
                validTriggerType=Simulink.SoftwareTarget.WindowsEventHandler.getTypeName();
            else
                validTriggerType=Simulink.SoftwareTarget.PosixSignalHandler.getTypeName();
            end

            aperiodicTriggers=obj.ParentTaskConfiguration.TaskGroups;
            for i=1:length(aperiodicTriggers)
                aperiodictrigger=aperiodicTriggers(i);
                if isa(aperiodictrigger,'Simulink.SoftwareTarget.PeriodicTrigger')
                    continue;
                end
                if~strcmp(aperiodictrigger.EventHandlerType,validTriggerType)
                    DAStudio.error('Simulink:mds:IncompatibleAperiodicTrigger',aperiodictrigger.Name,...
                    aperiodictrigger.EventHandlerType,Simulink.SoftwareTarget.TargetObjectUtils.osname(),...
                    aperiodictrigger.Name,validTriggerType);
                end
            end
        end



        function editBox=createWidget(widgetType,propertyName,propertyLabel)
            editBox.Name=propertyLabel;
            if(strcmp(widgetType,'edit')||strcmp(widgetType,'editarea')||strcmp(widgetType,'checkbox')...
                ||strcmp(widgetType,'listbox')||strcmp(widgetType,'combobox'))
                editBox.ObjectProperty=propertyName;
            end
            editBox.Type=widgetType;
            editBox.Tag=[propertyName,'_tag'];
            editBox.WidgetId=[propertyName,'_tag'];
        end
    end
end


