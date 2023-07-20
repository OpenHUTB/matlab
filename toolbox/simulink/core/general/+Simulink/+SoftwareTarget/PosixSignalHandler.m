classdef PosixSignalHandler<Simulink.SoftwareTarget.TargetSpecificTriggerBase






    properties(SetObservable=true)
        SignalNumber=2;
    end

    methods(Static=true)
        function typeName=getTypeName()
            typeName='Posix Signal (Linux/VxWorks 6.x)';
        end

        function checkGenericSimulationConstraints(~)
        end

        function checkGenericCodeGenerationConstraints(targetSpecificConfig)
            [a,b]=Simulink.SoftwareTarget.TargetObjectUtils.checkTaskGroupsPropertyIsUnique(targetSpecificConfig,...
            Simulink.SoftwareTarget.PosixSignalHandler.getTypeName(),...
            {'TargetObject','SignalNumber'});
            if(~isempty(a)&&~isempty(b))
                DAStudio.error('Simulink:mds:TaskGroup_PropNotSame',a.Name,b.Name,...
                'SignalNumber',num2str(a.TargetObject.SignalNumber));
            end
        end
    end

    methods
        function set.SignalNumber(obj,value)


            if(~isnumeric(value)||~isscalar(value))
                DAStudio.error('Simulink:mds:TargetObject_NonNumericScalarInput',...
                obj.ParentTaskGroup.Name,'SignalNumber',num2str(value));
            end

            if~ismember(33+value,35:64)
                DAStudio.error('Simulink:mds:TargetObject_InvalidRange',...
                obj.ParentTaskGroup.Name,'SignalNumber',num2str(value),'2-31');
            end




            if ismac&&value==9
                DAStudio.error('Simulink:mds:TargetObject_InvalidValue',...
                obj.ParentTaskGroup.Name,'SignalNumber',num2str(value));
            end
            obj.SignalNumber=value;
        end

        function panel=getSubDialogSchema(~,panel)
            intNo=Simulink.SoftwareTarget.TargetObjectUtils.createWidget(...
            'edit','SignalNumber',[DAStudio.message('Simulink:taskEditor:SignalNumberText'),' ']);
            panel.Items={intNo};
        end
    end
end


