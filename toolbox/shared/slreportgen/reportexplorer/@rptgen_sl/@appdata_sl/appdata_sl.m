function this=appdata_sl(varargin)






    mlock;

    persistent RPTGEN_APPDATA_PERSISTENT;

    if length(varargin)==1
        if isa(varargin{1},mfilename('class'))


            RPTGEN_APPDATA_PERSISTENT=varargin{1};
        else

            RPTGEN_APPDATA_PERSISTENT=[];
        end
        varargin={};
    end

    if isempty(RPTGEN_APPDATA_PERSISTENT)
        RPTGEN_APPDATA_PERSISTENT=feval(mfilename('class'));
    end
    this=RPTGEN_APPDATA_PERSISTENT;

    if~isempty(varargin)
        set(this,varargin{:});
    end
