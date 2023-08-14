classdef(Sealed)BlockInterfaceValidator<FunctionApproximation.internal.utilities.ValidatorInterface










    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=BlockInterfaceValidator()
        end
    end

    methods
        function success=validate(this,blockPath)


            success=true;

            blockObject=get_param(blockPath,'Object');
            if strcmp(blockObject.Variant,'on')
                blockPath=blockObject.ActiveVariantBlock;
            end

            portHandles=get_param(blockPath,'PortHandles');
            nInports=numel(portHandles.Inport);
            nOutports=numel(portHandles.Outport);
            messageIDs={};

            inportNumelValid=nInports>0;
            if~inportNumelValid
                success=false;
                messageIDs=[messageIDs,{'SimulinkFixedPoint:functionApproximation:blockMustHaveAtLeastOneInput'}];
            end

            outportNumelValid=nOutports==1;
            if~outportNumelValid
                success=false;
                messageIDs=[messageIDs,{'SimulinkFixedPoint:functionApproximation:blockMustHaveOneOutput'}];
            end

            hasBusInterface=false;
            if(inportNumelValid&&outportNumelValid)
                hasBusInterface=isBusAnyPort(this,get_param(blockPath,'Object'));
            end

            if hasBusInterface
                success=false;
                messageIDs=[messageIDs,{'SimulinkFixedPoint:functionApproximation:busAsInterface'}];
            end

            if~success
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
                for iMsg=1:numel(messageIDs)
                    this.Diagnostic=this.Diagnostic.addCause(MException(message(messageIDs{iMsg})));
                end
            end
        end
    end

    methods(Access=private)
        function hasBusInterface=isBusAnyPort(~,blockObject)

            portHandles=blockObject.PortHandles;


            inputSignalHierarchy=arrayfun(@(x)get_param(x,'SignalHierarchy'),portHandles.Inport,'UniformOutput',false);
            inputHasBuses=true;
            for ii=1:numel(inputSignalHierarchy)
                inputSignal=inputSignalHierarchy{ii};
                if~isempty(inputSignal)
                    inputHasBuses=inputHasBuses&&(~isempty(inputSignal.BusObject)||~isempty(inputSignal.Children));
                end
            end


            outputSignalHierarchy=arrayfun(@(x)get_param(x,'SignalHierarchy'),portHandles.Outport,'UniformOutput',false);
            outputHasBuses=true;
            for ii=1:numel(outputSignalHierarchy)
                outputSignal=outputSignalHierarchy{ii};
                if~isempty(outputSignal)
                    outputHasBuses=outputHasBuses&&(~isempty(outputSignal.BusObject)||~isempty(outputSignal.Children));
                end
            end

            hasBusInterface=inputHasBuses||outputHasBuses;
        end
    end
end