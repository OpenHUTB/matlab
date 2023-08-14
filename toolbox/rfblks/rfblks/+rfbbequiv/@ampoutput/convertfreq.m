function out=convertfreq(h,in,varargin)






    ckt=get(h,'OriginalCkt');
    out=convertfreq(ckt,in,varargin{:});