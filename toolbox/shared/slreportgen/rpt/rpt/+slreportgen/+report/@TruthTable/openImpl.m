function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2Cxocy0AQVPCeGaF6zwSwNaDyUAjWFOZJ2Lx9LarizHt5gtnSnnd4SUID88'...
        ,'L8WHdXGEq2JycndCAYX/pA+gn+1vpMr8u6b7Ova6Z7mvqkkZUgS5mpcacvD3'...
        ,'7pZpxndQY871M+tzS7VRI+uEbwJ7nJuFw3SeLkpc5x4bV2iiR7g/q6IRr3/X'...
        ,'Ei7/GBKIg/HagyLIzOgMK46FwjO20IM7HOhwP0olorPErdoSdu34QuL1oKNF'...
        ,'E1c4l2eh7feaeH6SG2kzLRiZb+hRIurYKWY5a29brq3EBZh3xRoRu01Xyg5l'...
        ,'zM50'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end