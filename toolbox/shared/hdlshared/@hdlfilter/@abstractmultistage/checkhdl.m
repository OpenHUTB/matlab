function v=checkhdl(this,varargin)








    for n=1:length(this.Stage)
        v=this.Stage(n).checkhdl(varargin{:});
        if v.Status

            v.Message=sprintf('%s\n%s',getString(message('HDLShared:hdlfilter:codegenmessage:cascadestageerr',...
            n)),v.Message);

            return
        end
    end


