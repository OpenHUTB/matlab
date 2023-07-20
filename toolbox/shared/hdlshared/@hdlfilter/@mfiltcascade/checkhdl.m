function v=checkhdl(this,varargin)






    v=this.checkInvalidProps(varargin{:});
    if v.Status
        return
    end

    v=this.checkComplex;
    if v.Status
        return
    end

    v=this.checkVarRate;
    if v.Status
        return
    end


    for stn=1:length(this.Stage)
        v=checkhdl(this.Stage(stn));
        if v.Status
            v.Message=sprintf('%s\n%s',...
            getString(message('HDLShared:hdlfilter:codegenmessage:stageerr',stn)),...
            v.Message);

            return
        end
    end
