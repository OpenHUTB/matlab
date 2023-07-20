function status=db2dom_on(varargin)







    if nargin==0
        status=rptgen.db2dom_on;
    else
        onoff=varargin{1};
        status=rptgen.db2dom_on(onoff);
    end

end

