function this=init(this,varargin)





    hdl.setpvpairs(this,varargin{:});

    if isempty(this.negate_string)&&~isempty(this.in),
        this.negate_string=[this.in.Name,'_neg'];
    end

    if isempty(this.rounding),
        this.rounding='floor';
    end

    if isempty(this.saturation),
        this.saturation=false;
    end

