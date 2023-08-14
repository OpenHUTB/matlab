function this=singlePortRam(varargin)





    this=hdl.singlePortRam;

    if nargin==0
        pvpairs={};
    else
        pvpairs=varargin;
    end

    setRamParams(this,pvpairs{:});

    this.CodeGenMode='instantiation';

    this.initParam('singleport')
