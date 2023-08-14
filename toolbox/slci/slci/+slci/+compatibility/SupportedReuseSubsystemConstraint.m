








classdef SupportedReuseSubsystemConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out=['Reusable subsystems must be from library, single rate '...
            ,'Atomic or function-call subsytem, '];
        end


        function obj=SupportedReuseSubsystemConstraint()
            obj.setEnum('SupportedReuseSubsystem');
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
            isSupportedNonInlineSub=...
            slci.internal.isSupportedReusableSubsystem(blkH);


            if isSupportedNonInlineSub

                if~aObj.isFromLib(blkH)

                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum(),aObj.ParentModel().getName());
                    return;
                end


                isSupportedSubType=aObj.isSupportedResueSubsytemType(blkH);
                if~isSupportedSubType
                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum(),aObj.ParentModel().getName());
                    return;
                end


                compiledSampleTime=...
                get_param(blkH,'CompiledSampleTime');
                multi_rate=...
                slci.internal.isMultipleSampleTimes(compiledSampleTime);
                if multi_rate
                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum(),aObj.ParentModel().getName());
                    return;
                end
            end
        end
    end

    methods(Access=private)


        function out=isSupportedResueSubsytemType(~,blkH)
            blkObj=get_param(blkH,'Object');
            subsystem_type=slci.internal.getSubsystemType(blkObj);
            out=strcmpi(subsystem_type,'Atomic')...
            ||strcmpi(subsystem_type,'Function-call');
        end


        function out=isFromLib(~,blkHdl)
            linkStatus=get_param(blkHdl,'LinkStatus');
            out=(strcmpi(linkStatus,'implicit')...
            ||strcmpi(linkStatus,'resolved'));
        end
    end

end
