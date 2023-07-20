classdef InputEventServiceInfo




















    methods(Static=true)
        function isTriggered=isTriggeredFunction(periodicFunction)
            isTriggered=slfeature('DDSListenerCodegen')>0&&...
            periodicFunction.Timing.SamplePeriod==1&&...
            periodicFunction.Timing.SampleOffset==-30;
        end
        function modelUsesInputEvents=modelInputEventsForDDSServiceGen(periodicFunctions)
            modelUsesInputEvents=false;
            if~isempty(periodicFunctions)
                for pfm=periodicFunctions
                    if dds.internal.coder.InputEventServiceInfo.isTriggeredFunction(pfm)
                        modelUsesInputEvents=true;
                        break;
                    end
                end
            end
        end
        function[periodicIndexes,aperiodicIndexes,asynchronousIndexes,unknownIndexes]=findOutputFunctionIndex(outputFcns)
            numOutputFunctions=length(outputFcns);
            periodicIndexes(numOutputFunctions)=false;
            aperiodicIndexes(numOutputFunctions)=false;
            asynchronousIndexes(numOutputFunctions)=false;
            unknownIndexes(numOutputFunctions)=false;
            for ii=numOutputFunctions:-1:1
                outfun=outputFcns(ii);
                switch outfun.Timing.TimingMode
                case 'PERIODIC'
                    periodicIndexes(ii)=true;
                case 'APERIODIC'
                    aperiodicIndexes(ii)=true;
                case 'ASYNCHRONOUS'
                    asynchronousIndexes(ii)=true;
                otherwise
                    unknownIndexes(ii)=true;
                end
            end
        end
    end
end
