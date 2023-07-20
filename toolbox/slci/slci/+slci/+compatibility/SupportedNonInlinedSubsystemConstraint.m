




classdef SupportedNonInlinedSubsystemConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Supported non inlined subsystem configuration ';
        end


        function obj=SupportedNonInlinedSubsystemConstraint()
            obj.setEnum('SupportedNonInlinedSubsystem');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];

            if aObj.isSimulinkFunctionBlock()
                return
            end

            inlined=slci.internal.isSubsystemInlined(...
            aObj.ParentBlock().getHandle());
            acceptable=inlined...
            ||slci.internal.isSupportedNonInlinedSubsystemConfiguration(...
            aObj.ParentBlock().getSID(),aObj.ParentModel().getName());
            if~acceptable
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
            end
        end

    end
    methods(Access=private)

        function flag=isSimulinkFunctionBlock(aObj)
            blkObj=aObj.getOwner().getParam('Object');
            assert(isa(blkObj,'Simulink.SubSystem'),...
            "Block object is not a SubSystem block")
            flag=strcmpi(blkObj.IsSimulinkFunction,'on');
        end
    end

end
