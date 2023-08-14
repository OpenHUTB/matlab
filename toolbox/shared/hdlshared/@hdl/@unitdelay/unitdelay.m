function this=unitdelay(varargin)





    this=hdl.unitdelay;

    this.init(varargin{:});

    if length(this.outputs)>1
        this.resetvalues=this.resetvalues(:);
    end
