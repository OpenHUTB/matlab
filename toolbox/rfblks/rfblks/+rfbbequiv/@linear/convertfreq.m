function out=convertfreq(h,in,varargin)






    out=in;
    ckt=get(h,'RFckt');
    if isa(ckt,'rfckt.rfckt')
        out=convertfreq(ckt,in,varargin{:});
    end