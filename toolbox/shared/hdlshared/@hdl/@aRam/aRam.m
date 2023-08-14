function this=aRam(varargin)





    this=hdl.aRam;

    if nargin==0
        pvpairs={};
    else
        pvpairs=varargin;
    end

    setRamParams(this,pvpairs{:});
