



classdef FunctionInterfaceUtils<handle
    methods(Static)
        function actualArgs=getActualArguments(functionInterfaces)
            numberOfFunctionInterfaces=length(functionInterfaces);
            actualArgs=[];
            for taskIdx=1:numberOfFunctionInterfaces
                functionInterface=functionInterfaces(taskIdx);
                if coder.internal.modelreference.TimingInterfaceUtils.isAsynchronousSampleTime(functionInterface.Timing(1))
                    assert(false);
                    break;
                end
                actualArgs=union(actualArgs,functionInterfaces(taskIdx).ActualArgs,'stable');
            end
        end


        function status=hasContinuousSampleTimes(functionInterface)
            status=false;
            numberOfSampleTimes=length(functionInterface.Timing);
            for sampIdx=1:numberOfSampleTimes
                if coder.internal.modelreference.TimingInterfaceUtils.isContinuousSampleTime(functionInterface.Timing(sampIdx))
                    status=true;
                    return;
                end
            end
        end


        function status=hasAsyncSampleTime(functionInterface)
            status=coder.internal.modelreference.TimingInterfaceUtils.isAsynchronousSampleTime(functionInterface.Timing(1));
        end
    end
end
