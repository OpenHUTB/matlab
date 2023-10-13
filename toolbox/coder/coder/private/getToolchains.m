function [ toolchains, default ] = getToolchains( isGpuCoder )
arguments
    isGpuCoder = false
end

[ toolchains, default ] = coder.make.internal.guicallback.getToolchains(  );
isNvidia = contains( toolchains, 'NVIDIA' );
isNvidiaGcc = strcmpi( toolchains, 'GNU GCC for NVIDIA Embedded Processors' );

if isGpuCoder
    toolchains = toolchains( isNvidia & ~isNvidiaGcc );
else
    toolchains = toolchains( ~isNvidia | isNvidiaGcc );
end
toolchains = unique( [ { default }, toolchains ] );
end


