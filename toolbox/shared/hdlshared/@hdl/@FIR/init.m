function this=init(this,varargin)





    hdl.setpvpairs(this,varargin{:});

    if isempty(this.pipeline_processname)
        this.pipeline_processname=hdluniqueprocessname;
    end

    if isempty(this.resetvalues)
        this.resetvalues=0;
    end

