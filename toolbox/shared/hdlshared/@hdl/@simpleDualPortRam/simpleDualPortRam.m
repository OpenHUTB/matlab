function this=simpleDualPortRam(varargin)





    this=hdl.simpleDualPortRam;

    if nargin==0
        pvpairs={};
    else
        pvpairs=varargin;
    end

    setRamParams(this,pvpairs{:});

    this.CodeGenMode='instantiation';

    this.initParam('simpledualport')
