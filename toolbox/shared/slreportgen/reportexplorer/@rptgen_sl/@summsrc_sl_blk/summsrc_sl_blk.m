function h=summsrc_sl_blk(varargin)









    h=rptgen_sl.summsrc_sl_blk;


    if length(varargin)==3
        varargin={'type',varargin{1},...
        'propsrc',varargin{2},...
        'loopcomp',varargin{3}};
    elseif length(varargin)==5
        varargin={'type',varargin{1},...
        'propsrc',varargin{2},...
        'loopcomp',varargin{3},...
        'properties',varargin{4},...
        'anchor',varargin{5}};
    end

    set(h,varargin{:});
