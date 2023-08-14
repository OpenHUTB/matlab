function out=repmat(in,varargin)




    out=simscape.Unit(repmat(string(in),varargin{:}));
end