





classdef DLCrosscompilersRegistry<handle
    properties(Constant,Access=public)
        m_supportedCrossCompilerToolChains=dltargets.arm_neon.DLCrosscompilersRegistry.getRegisteredToolchains()
    end

    methods(Static=true)
        function crossCompilerToolChainMap=getRegisteredToolchains()
            crossCompilerToolChainMap=containers.Map();
            crossCompilerToolChainMap('Linaro AArch32 Linux v6.3.1')='Linux';
            crossCompilerToolChainMap('Linaro AArch64 Linux v6.3.1')='Linux';
        end
    end

    methods
        function isSupportedCrossCompilerToolchain=isSupportedCrossCompilerToolChain(regObj,toolchain)
            if(isKey(regObj.m_supportedCrossCompilerToolChains,toolchain))
                isSupportedCrossCompilerToolchain=true;
            else
                isSupportedCrossCompilerToolchain=false;
            end
        end
    end
end
