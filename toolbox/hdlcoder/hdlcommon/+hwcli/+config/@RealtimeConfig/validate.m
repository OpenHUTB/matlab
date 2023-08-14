function validate(obj,varargin)



    isVivado=strcmp(obj.SynthesisTool,'Xilinx Vivado');

    if(isVivado)
        validate@hwcli.base.IPCoreBase(obj,varargin{:});
    else
        validate@hwcli.base.TurnkeyBase(obj,varargin{:});
    end

end