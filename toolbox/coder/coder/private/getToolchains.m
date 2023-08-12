function [ toolchains, default ] = getToolchains( isGpuCoder )
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpVJB91D.p.
% Please follow local copyright laws when handling this file.

