classdef WindowsEventHandler<Simulink.SoftwareTarget.TargetSpecificTriggerBase






    properties(SetObservable=true)
        EventName='ERTDefaultEvent';
    end

    methods(Static=true)
        function typeName=getTypeName()
            typeName='Event (Windows)';
        end

        function checkGenericSimulationConstraints(~)
        end

        function checkGenericCodeGenerationConstraints(targetSpecificConfig)
            [a,b]=Simulink.SoftwareTarget.TargetObjectUtils.checkTaskGroupsPropertyIsUnique(targetSpecificConfig,...
            Simulink.SoftwareTarget.WindowsEventHandler.getTypeName(),...
            {'TargetObject','EventName'});
            if(~isempty(a)&&~isempty(b))
                DAStudio.error('Simulink:mds:TaskGroup_PropNotSame',a.Name,b.Name,...
                'EventName',a.TargetObject.EventName);
            end
        end

    end

    methods

        function set.EventName(obj,value)
            if(~ischar(value)||~isrow(value)||ismember('\',value))
                DAStudio.error('Simulink:mds:TargetObject_InvalidWindowsEventName',...
                obj.ParentTaskGroup.Name,'EventName',value);
            end
            obj.EventName=value;
        end

        function panel=getSubDialogSchema(~,panel)
            intNo=Simulink.SoftwareTarget.TargetObjectUtils.createWidget(...
            'edit','EventName',[DAStudio.message('Simulink:taskEditor:EventNameText'),' ']);
            panel.Items={intNo};
        end

    end
end


