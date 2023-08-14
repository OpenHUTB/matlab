classdef sldvanalyzable






    methods(Access=private)
        function obj=sldvanalyzable()

        end
    end

    methods(Static)
        function[state,msg]=issubsystemsldvanalyzable(sys,cbinfo)


            import Sldv.ui.toolstrip.internal.sldvanalyzable.*
            import Sldv.ui.toolstrip.utils.ToolstripConstants;

            States=ToolstripConstants.SELECTOR_STATES;
            state=States.NonSupported;
            msg='';
            if isSLDVHarness(sys)
                if isHarnessModelRefUnit(sys)
                    state=States.SupportedAddMissing;
                else
                    state=States.NonSupportedAddMissing;
                    msg=getString(message('Sldv:toolstrip:NoMdlRefHarness'));
                end
            elseif isValidTopModel(sys,cbinfo)


                state=States.Supported;
            elseif isModelReference(sys,cbinfo)


                if slavteng('feature','ExtractModelReference')>0
                    state=States.Supported;
                else
                    state=States.NonSupported;
                    msg=getString(message('Sldv:toolstrip:ReferencedModelInStudioReuse'));
                end
            elseif isSubsystemReference(sys)
                state=States.NonSupported;
                msg=getString(message('Sldv:toolstrip:ReferencedSubsystemInStudioReuse'));
            elseif isValidSubsystem(sys)
                if needsConversion(sys,ToolstripConstants.CONVERSION_SUBSYSTEM)
                    state=States.Convertible;
                else
                    state=States.Supported;
                end
            elseif isValidSFSubchart(sys)
                if needsConversion(sys,ToolstripConstants.CONVERSION_STATEFLOW)
                    state=States.Convertible;
                else
                    state=States.Supported;
                end
            end

            if strcmp(state,States.NonSupported)&&isempty(msg)

                msg=getString(message('Sldv:toolstrip:IncompatibleWithSLDV'));
            end
        end

        function res=isValidTopModel(system,cbinfo)

            res=isa(system,'Simulink.BlockDiagram')&&(cbinfo.model.Handle==system.Handle);
        end

        function res=isModelReference(system,~)





            res=isa(system,'Simulink.ModelReference');
        end

        function res=isSubsystemReference(system)



            res=isa(system,'Simulink.SubSystem');
            if~res
                return
            else
                res=~isempty(get_param(system.Handle,'ReferencedSubsystem'));
            end
        end

        function res=isValidSubsystem(subsystem)

            res=true;
            if~subsystem.isa('Simulink.Block')||~strcmp(subsystem.BlockType,'SubSystem')
                res=false;
                return;
            end





            if~strcmp(get_param(subsystem.handle,'StaticLinkStatus'),'none')
                res=false;
                return;
            end






            ssType=Simulink.SubsystemType(subsystem.handle);
            if ssType.isInitTermOrResetSubsystem
                res=false;
                return;
            end



            if strcmp(get_param(bdroot(subsystem.handle),'isHarness'),'on')&&...
                ~Simulink.harness.internal.isHarnessCUT(subsystem.handle)
                res=false;
            end
        end

        function res=isValidSFSubchart(subsystem)

            res=isa(subsystem,'Stateflow.AtomicSubchart')||isa(subsystem,'Stateflow.State');
        end

        function res=needsConversion(subsystem,subSysOrSf)


            import Sldv.ui.toolstrip.utils.ToolstripConstants
            res=false;
            switch subSysOrSf
            case ToolstripConstants.CONVERSION_SUBSYSTEM
                try

                    ports=subsystem.Ports;
                    if~strcmpi(subsystem.TreatAsAtomicUnit,'on')&&ports(3)==0&&ports(4)==0
                        res=true;
                        return;
                    end
                catch

                    return;
                end
            case ToolstripConstants.CONVERSION_STATEFLOW
                res=~isa(subsystem,'Stateflow.AtomicSubchart')&&isa(subsystem,'Stateflow.State');
            end
        end

        function res=isSLDVHarness(system)
            res=slavteng('feature','TopItOff')...
            &&~isa(system,'Stateflow.Object')&&~isa(system,'Stateflow.DDObject');
            if res==true
                if(ischar(system)||isstring(system))
                    res=Sldv.HarnessUtils.isSldvGenHarness(get_param(system,'Handle'));
                else
                    res=Sldv.HarnessUtils.isSldvGenHarness(system.Handle);
                end
            end
        end
    end

    methods(Static)
        function referencedModel=getSldvRefHarnessName(harnessH)



            referencedModel='';
            block=find_system(harnessH,'SearchDepth',1,'BlockType','ModelReference');
            if isempty(block)||length(block)>1||strcmp(get_param(block,'ProtectedModel'),'on')
                return;
            else
                referencedModel=get_param(block,'ModelName');
            end
        end

        function tf=isHarnessModelRefUnit(system)
            if ischar(system)


                systemH=get_param(system,'Handle');
            else

                systemH=system.Handle;
            end
            tf=~isempty(Sldv.ui.toolstrip.internal.sldvanalyzable.getSldvRefHarnessName(systemH));
        end
    end
end



