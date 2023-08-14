function Sources=getInterruptSources(ModelName,IsrName)





    if nargin<2
        IsrName=[];
    end
    Sources='';
    try
        intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(ModelName);
        if isempty(IsrName)
            bc=getBuildConfigurationInfo(intdef,'toolchain',get_param(ModelName,'Toolchain'));
        else
            irqgrp=getInterruptGroupBasedOnInterruptName(intdef,IsrName);
            bc=getBuildConfigurationInfo(irqgrp,'toolchain',get_param(ModelName,'Toolchain'));
        end

        if~isempty(bc)&&~isempty(bc.SourceFiles)

            Sources=bc.SourceFiles;
        end
    catch
    end
end


