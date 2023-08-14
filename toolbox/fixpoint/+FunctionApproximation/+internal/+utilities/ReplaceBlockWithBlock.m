classdef ReplaceBlockWithBlock<FunctionApproximation.internal.utilities.BlockReplacementInterface




    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=ReplaceBlockWithBlock()
        end
    end

    methods
        function[success,diagnostic]=replace(~,originalBlockPath,substituteBlockPath)
            [success,causeDiagnostic]=FunctionApproximation.internal.Utils.checkIfNumberOfInterfacesMatch(originalBlockPath,substituteBlockPath);
            diagnostic=MException.empty;
            if success

                pos=get_param(originalBlockPath,'Position');
                orientation=get_param(originalBlockPath,'Orientation');


                instrumentationResults=get_param(bdroot(originalBlockPath),'InstrumentedSignals');
                sigSpecOfInterest=[];
                if~isempty(instrumentationResults)
                    allSignalSpecifications=arrayfun(@(x)instrumentationResults.get(x),1:instrumentationResults.Count);
                    blockPaths=arrayfun(@(x)x.BlockPath.convertToCell{1},allSignalSpecifications,'UniformOutput',false)';
                    sigSpecOfInterest=allSignalSpecifications(strcmp(blockPaths,originalBlockPath));
                end


                delete_block(originalBlockPath);


                set_param(substituteBlockPath,'Orientation',orientation);


                add_block(substituteBlockPath,originalBlockPath,'Position',pos);


                set_param(originalBlockPath,'Commented','off');


                for ii=1:numel(sigSpecOfInterest)
                    Simulink.sdi.markSignalForStreaming(originalBlockPath,sigSpecOfInterest(ii).OutputPortIndex,'on');
                end
            else
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:cannotReplaceBlock'));
                diagnostic=diagnostic.addCause(causeDiagnostic);
            end
        end
    end
end
