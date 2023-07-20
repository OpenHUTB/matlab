function v=checkhdl(this,varargin)






    v=this.checkInvalidProps(varargin{:});
    if v.Status
        return
    end


    v=this.checkConverter;
    if v.Status
        return
    end

    v=this.Filters.checkhdl(varargin{:});
    if v.Status

        v.Message=['Filtering stages in digital up/down converter has error: ',newline,v.Message];
        return
    end
    v=this.NCO.checkhdl(varargin{:});
    if v.Status

        v.Message=['NCO in digital up/down converter has error: ',newline,v.Message];
        return
    end


