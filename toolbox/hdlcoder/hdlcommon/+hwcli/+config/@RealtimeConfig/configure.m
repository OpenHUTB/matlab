function configure(obj,hDI)







    isVivado=strcmp(obj.SynthesisTool,'Xilinx Vivado');

    if(isVivado)
        configure@hwcli.base.IPCoreBase(obj,hDI);
    else
        configure@hwcli.base.TurnkeyBase(obj,hDI);
    end

end