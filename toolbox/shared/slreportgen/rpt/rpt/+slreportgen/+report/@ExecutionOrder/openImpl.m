function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxpMS0AXVPCeGaC6wwhEbs24hA6aMgvL3c8aBfUmyIaUpb0uB19z5GuINM'...
        ,'Pi6+KzN5zUqXpKIEotuJc++syXF9JKNCPRiOtvt4z/PzWcwTdKie3LuB0K3x'...
        ,'4TVD6HnlOQTta06i0rVB2BtM7Lz1gA5f8gzCMQAqRzCnie0qs0lX6BPsfB9B'...
        ,'nBxDsBXVys1c1t03NVeN6OyfTJ0w/Yz8zHKuKfQAeDWohpUXicXrHk6fGGyw'...
        ,'R9QKwEVaR6M8xVueRgt1NwxYb4lCq5yw56JXL/qKoRwpp3jiTQcTSK9MUYQ/'...
        ,'+ojQ'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end