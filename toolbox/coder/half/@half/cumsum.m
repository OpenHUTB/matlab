function out=cumsum(in,varargin)




    out=half(cumsum(single(in),varargin{:}));
