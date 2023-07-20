





classdef SupportedNonReuseSubsystemConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out=['NonReusable subsystems must not be inside a '...
            ,'Reusable Subsystem '];
        end


        function obj=SupportedNonReuseSubsystemConstraint()
            obj.setEnum('SupportedNonReuseSubsystem');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            sub=aObj.getOwner;
            assert(isa(sub,'slci.simulink.SubSystemBlock')...
            ||isa(sub,'slci.simulink.MatlabFunctionBlock')...
            ||isa(sub,'slci.simulink.StateflowBlock')...
            );
            blkH=sub.getHandle();

            if aObj.isNonReuseSubsystem(blkH)...
                &&aObj.hasReusableParentSS(blkH)
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum(),aObj.ParentModel().getName());
            end

        end
    end

    methods(Access=private)

        function out=isNonReuseSubsystem(~,blkH)

            RTWSystemCode=get_param(blkH,'RTWSystemCode');

            out=strcmpi(RTWSystemCode,'Nonreusable function');
        end



        function out=hasReusableParentSS(aObj,blkH)
            out=false;

            try
                blkParent=get_param(blkH,'Parent');
                blkParentHdl=get_param(blkParent,'Handle');
            catch

                return;
            end

            if~strcmp(get_param(blkParentHdl,'Type'),'block')
                return;
            end

            if slci.internal.isSupportedReusableSubsystem(blkParentHdl)
                out=true;
            else
                out=aObj.hasReusableParentSS(blkParentHdl);
            end
        end
    end

end
