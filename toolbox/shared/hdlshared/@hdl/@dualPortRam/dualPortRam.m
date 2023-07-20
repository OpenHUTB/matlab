function this=dualPortRam(varargin)





    this=hdl.dualPortRam;

    if nargin==0
        pvpairs={};
    else
        pvpairs=varargin;
    end

    setRamParams(this,pvpairs{:});

    this.CodeGenMode='instantiation';

    this.initParam('dualport')
