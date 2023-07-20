

classdef BooleanTriggerPortConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The signal entering a trigger port of a subsystem must have datatype ''boolean''';
        end

        function obj=BooleanTriggerPortConstraint()
            obj.setEnum('BooleanTriggerPort');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            assert(isa(aObj.ParentBlock(),'slci.simulink.TriggerPortBlock'));
            blkSID=aObj.ParentBlock().getSID();
            parentSS=get_param(blkSID,'Parent');
            portDt=[];
            if strcmpi(parentSS,aObj.ParentModel().getName())
                portDt=get_param(blkSID,'OutDataTypeStr');
            else
                parentObj=get_param(parentSS,'Object');
                if~strcmpi(slci.internal.getSubsystemType(parentObj),'MessageTrigger')
                    portDts=get_param(parentSS,'CompiledPortDataTypes');
                    portDt=portDts.Trigger{1};
                else





                    triggerTime=aObj.ParentBlock().getParam('TriggerTime');
                    if strcmp(triggerTime,'on sample time hit')
                        portDts=get_param(parentSS,'CompiledPortDataTypes');
                        portDt=portDts.Trigger{1};
                    end
                end
            end
            if~isempty(portDt)&&~strcmpi(portDt,'boolean')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'BooleanTriggerPort',...
                parentSS);
            end
        end

    end
end