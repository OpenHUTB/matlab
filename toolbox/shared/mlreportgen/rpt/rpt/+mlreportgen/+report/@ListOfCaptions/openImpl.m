function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2Cxv0y0RgVPSvFmUm2nr+v/yFiKegxodrfpckeVNpBFVmB6XuMSjr4YQTGc'...
        ,'GDUHBW1U1DWfSvNsv1bP4daD6h75kdTfCbnZn3ROdOat6A9NKadraT1BZq+K'...
        ,'RR2I5fH7Emg7S0K2hhMOdQjx6Ow1gk0xIl23bRJ0H3oD4SnZ51Lz1qLR+7S7'...
        ,'lF7TcibZdq4eq+uCWD+IFZ2hD0z7zfgs02qV9CZnek2oCZe29F5uGbkvH0wt'...
        ,'wMOw0Fc01jRPsU2Umf+SX2J0WNFMHBivx4rrnB4rrynNcORW380miAY7nnvK'...
        ,'72yNEbHQzAo='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end