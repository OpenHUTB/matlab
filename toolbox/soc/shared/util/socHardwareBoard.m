function out=socHardwareBoard(hardwareBoardName,varargin)

























































    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    if nargin==0
        out=listHardware;
    else
        out=ioplayback.hardware(hardwareBoardName,varargin{:});
    end
end

