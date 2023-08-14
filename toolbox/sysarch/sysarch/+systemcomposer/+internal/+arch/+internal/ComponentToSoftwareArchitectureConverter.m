classdef ComponentToSoftwareArchitectureConverter<systemcomposer.internal.arch.internal.ComponentToReferenceConverter





    properties(Access=private)



        ErrorReporter;
    end

    methods(Access=public)
        function this=ComponentToSoftwareArchitectureConverter(blkH,mdlName,reporter,dirPath,template)
            if nargin<5
                template=[];
            end

            if nargin<4
                dirPath=string(pwd);
            end

            if nargin<3
                reporter=systemcomposer.internal.CommandLineErrorReporter;
            end

            this@systemcomposer.internal.arch.internal.ComponentToReferenceConverter(blkH,mdlName,dirPath,template);
            this.ErrorReporter=reporter;
        end
    end

    methods(Access=protected)
        function runValidationChecksHook(this)









            compToConvert=systemcomposer.utils.getArchitecturePeer(this.BlockHandle);
            if~systemcomposer.internal.arch.internal.isValidCIdentifier(compToConvert.getName())
                this.ValidationPassed=false;
                this.ErrorReporter.reportAsError(...
                MSLException('SystemArchitecture:SoftwareArchitecture:InvalidComponentNameForConverting',...
                getfullname(this.BlockHandle)));
                return;
            end

            childElems=compToConvert.getArchitecture().getComponentsAcrossHierarchy();
            unsupportedElemMsgs=[];
            reportedAdapterConversion=false;
            for elem=childElems
                msg=[];
                if elem.isAdapterComponent()&&~isempty(elem.p_Adaptation)&&...
                    ~isempty(elem.p_Adaptation.p_Adaptations.toArray)



                    if~reportedAdapterConversion
                        canContinue=this.ErrorReporter.reportAsWarning(...
                        message('SystemArchitecture:SaveAndLink:WarningRemovingAdapterConversions'));
                        if~canContinue
                            this.ValidationPassed=false;
                            return;
                        end
                        reportedAdapterConversion=true;
                    end
                else
                    msg=reportUnsupportedElement(elem);
                end

                if~isempty(msg)
                    unsupportedElemMsgs=[unsupportedElemMsgs,msg];%#ok<AGROW>
                end
            end

            if~isempty(unsupportedElemMsgs)
                mainDiag=MSLException(message('SystemArchitecture:SaveAndLink:CreateSoftwareArchitectureFailed',getfullname(this.BlockHandle)));
                for elemMsg=unsupportedElemMsgs
                    mainDiag=addCause(mainDiag,elemMsg);
                end
                this.ValidationPassed=false;
                this.ErrorReporter.reportAsError(mainDiag);
            end
        end

        function postCreateReferenceModelHook(this)



            rootArch=systemcomposer.utils.getArchitecturePeer(this.ModelHandle);
            rootArch.addTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            rootArch.setIsSoftwareArchitecture();
            SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(...
            this.ModelHandle,SimulinkSubDomainMI.SimulinkSubDomainEnum.SoftwareArchitecture)
            set_param(this.ModelHandle,'Solver','FixedStepDiscrete');
        end
    end
end

function unsupportedElemMsg=reportUnsupportedElement(component)



    arch=component.getArchitecture();
    if isa(arch,'systemcomposer.architecture.model.design.BehaviorArchitecture')
        if strcmp(arch.getArchitectureType(),'SFChart')
            unsupportedElemMsg=getUnsupportedElementMsg(...
            'StateflowBehaviorNotSupportedInSWArch',component);
        elseif strcmp(arch.getArchitectureType(),'FMU')
            unsupportedElemMsg=getUnsupportedElementMsg(...
            'FMUBehaviorNotSupportedInSWArch',component);
        else
            unsupportedElemMsg=getUnsupportedElementMsg(...
            'UnknownBehaviorNotSupportedInSWArch',component);
        end
    elseif component.isReferenceComponent()&&~arch.isSoftwareArchitecture()
        unsupportedElemMsg=getUnsupportedElementMsg(...
        'ReferencedArchitectureNotSupportedInSWArch',component);
    else
        unsupportedElemMsg=[];
    end

end

function msg=getUnsupportedElementMsg(id,component)
    asBlock=systemcomposer.utils.getSimulinkPeer(component);
    msg=MSLException(message(...
    ['SystemArchitecture:SaveAndLink:',id],...
    getfullname(asBlock)));
end


