function c=cv1_adapter(varargin)









    c=feval(mfilename('class'));

    if length(varargin)==1
        if isa(varargin{1},'rptcp')
            varargin{1}=unpoint(varargin{1});
        end
        varargin=[{'OldComponent'},varargin];
    elseif length(varargin)==2&&isa(varargin{2},'rptcp')
        varargin{2}=unpoint(varargin{2});
    end

    c.init(varargin{:});

