classdef(Sealed)SubSystemValidator<FunctionApproximation.internal.utilities.ValidatorInterface




    properties
        BlockTypesForStateRegistration={'Delay'};
    end

    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=SubSystemValidator()
        end
    end

    methods
        function success=validate(this,blockPath,options)
            if nargin<3
                options=FunctionApproximation.Options();
            end

            if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(blockPath)
                success=true;
                return;
            end

            if~options.AllowSubSystem

                success=false;
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:blockTypeNotSupported'));
                return;
            end

            success=FunctionApproximation.internal.Utils.getBlockType(blockPath)...
            ==FunctionApproximation.internal.BlockType.SubSystem;

            if success
                [success,diagnostic]=FunctionApproximation.internal.Utils.isBlockInterfaceValid(blockPath);
                this.Diagnostic=diagnostic;
            end

            if success
                messageIDs={};

                blockObject=get_param(blockPath,'Object');


                if strcmp(blockObject.Variant,'on')
                    blockPath=blockObject.ActiveVariantBlock;
                end


                isValidVariant=isVariantValid(this,blockPath);
                if~isValidVariant
                    success=false;
                    messageIDs=[messageIDs,{'SimulinkFixedPoint:functionApproximation:inactiveVariant'}];
                end


                modelReferences=Simulink.findBlocksOfType(blockPath,'ModelReference');
                if~isempty(modelReferences)
                    success=false;
                    messageIDs=[messageIDs,{'SimulinkFixedPoint:functionApproximation:subsystemContainsModelReference'}];
                end


                states=getStates(this,blockPath);
                if~isempty(states)
                    success=false;
                    messageIDs=[messageIDs,{'SimulinkFixedPoint:functionApproximation:subsystemHasStates'}];
                end


                registerDiagnostics(this,success,messageIDs);
            else
                if isempty(this.Diagnostic)
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
                end
            end
        end
    end

    methods(Hidden)
        function states=getStates(this,blockPath)
            for ii=1:numel(this.BlockTypesForStateRegistration)

                states=Simulink.findBlocksOfType(blockPath,this.BlockTypesForStateRegistration{ii});
                if~isempty(states)
                    break;
                end
            end

            if isempty(states)








                warningStruct=warning('off');
                try states=FunctionApproximation.internal.Utils.getInitialStates(blockPath);catch,states=[];end
                warning(warningStruct);
            end
        end

        function registerDiagnostics(this,success,messageIDs)
            if~success
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidSubsystemPath'));
                for iMsg=1:numel(messageIDs)
                    this.Diagnostic=this.Diagnostic.addCause(MException(message(messageIDs{iMsg})));
                end
            end
        end

        function isValid=isVariantValid(~,blockPath)
            parent=get_param(blockPath,'Parent');
            parentObject=get_param(parent,'Object');
            invalidVariant=~isa(parentObject,'Simulink.BlockDiagram')...
            &&~isempty(parentObject.ActiveVariantBlock)...
            &&~strcmp(parentObject.ActiveVariantBlock,blockPath);
            isValid=~invalidVariant;
        end
    end
end


