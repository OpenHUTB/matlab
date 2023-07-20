function count=power_printf(fid,varargin)









    if fid>0
        count=fprintf(fid,varargin{:});
    end
