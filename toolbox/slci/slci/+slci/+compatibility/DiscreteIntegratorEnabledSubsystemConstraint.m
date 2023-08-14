

classdef DiscreteIntegratorEnabledSubsystemConstraint<slci.compatibility.Constraint

    methods(Access=private)


        function status=isInsideEnabledSubsystem(aObj)
            status=false;
            modelName=aObj.ParentModel().getName();
            srcBlk=get_param(aObj.ParentBlock().getSID(),'Parent');
            while(~strcmpi(srcBlk,modelName))
                srcBlkType=get_param(srcBlk,'BlockType');

                if(strcmpi(srcBlkType,'subsystem'))
                    ssType=slci.internal.getSubsystemType(get_param(srcBlk,'Object'));
                    if(strcmpi(ssType,'Trigger')||...
                        strcmpi(ssType,'Function-call')||...
                        strcmpi(ssType,'EnableTrigger')||...
                        strcmpi(ssType,'Enable')||...
                        strcmpi(ssType,'Action')||...
                        strcmpi(ssType,'For')||...
                        strcmpi(ssType,'While'))
                        status=true;
                        return
                    end
                end

                srcBlk=get_param(srcBlk,'Parent');
            end
        end

    end

    methods

        function out=getDescription(aObj)%#ok
            out='A Discrete Integrator block should not be placed inside a conditional subsystem.';
        end

        function obj=DiscreteIntegratorEnabledSubsystemConstraint()
            obj.setEnum('DiscreteIntegratorEnabledSubsystem');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            isEnabled=aObj.isInsideEnabledSubsystem();
            if(isEnabled==true)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'DiscreteIntegratorEnabledSubsystem',...
                aObj.ParentBlock().getName());
            end
        end

    end
end
