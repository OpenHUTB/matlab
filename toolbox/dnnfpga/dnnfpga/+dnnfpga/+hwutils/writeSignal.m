function outputVar=writeSignal(mode,addr,val,h,varargin)


    if(nargin==4)
        arg0='OutputDataType';
        arg1='single';
    else
        assert(nargin==6);
        arg0=varargin{1};
        arg1=varargin{2};
    end

    if(length(val)>1)

        outputVar=dnnfpga.hwutils.writeSignalForced(mode,hex2dec(addr),val,h,arg0,arg1);
    else
        outputVar=dnnfpga.hwutils.writeSignalPrivate(mode,addr,val,h);
    end
end
