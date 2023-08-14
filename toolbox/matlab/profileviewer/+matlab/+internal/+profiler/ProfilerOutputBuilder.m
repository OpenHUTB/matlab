classdef ProfilerOutputBuilder<handle







    methods(Static)
        function statusOutput=buildStatusOutput(outputs)
            import matlab.internal.profiler.ProfilerType


            statusOutput=outputs(char(ProfilerType.Matlab));
            if outputs.isKey(char(ProfilerType.Pool))
                statusOutput.ParallelOptions=outputs(char(ProfilerType.Pool));
            end
        end

        function infoOutput=buildInfoOutput(outputs)
            import matlab.internal.profiler.ProfilerOutputBuilder
            import matlab.internal.profiler.ProfilerType


            infoOutput=outputs(char(ProfilerType.Matlab));
            if outputs.isKey(char(ProfilerType.Pool))
                poolInfoOutput=outputs(char(ProfilerType.Pool));



                if~isempty(poolInfoOutput)
                    infoOutput.Pool=getFormattedPoolInfo(poolInfoOutput);
                end
            end
        end
    end
end


function output=getFormattedPoolInfo(poolInfoOutput)
    output=struct('WorkersInfo',poolInfoOutput);


    for poolIdx=1:numel(poolInfoOutput)
        output(poolIdx).WorkersInfo=cellfun(@(x)x,output(poolIdx).WorkersInfo);
    end
end