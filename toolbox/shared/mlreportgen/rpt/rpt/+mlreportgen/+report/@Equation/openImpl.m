function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2Cxoky0AQVPiNBuGnoDvQaejsvvC6T2T5bpmZ6qgXzI5OKd/bwRLnhuCT13'...
        ,'Lp3PEiVLIjqtgdpguoPhHv0t8QXMcRpyK4KQptp6ncYWzWuIjgIM2N4chuqI'...
        ,'99/4tLViPSP1w30RHLi/GYkb92/ghrrJoRX660QO2BeEMwoNaDvcyp4ynjTR'...
        ,'+2m1Htzi9v/Gw9AxEE0Jzvwvat0P1tuEXgUazgMgYM9bxDjLYk8vvAK/LvVW'...
        ,'UbZZatwtjVCyoaB4ZyjXbMN9TyH81HmJOvNbBVQrWTlGCz2B+17VoxRCL1/w'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end