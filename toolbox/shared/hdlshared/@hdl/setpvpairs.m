function setpvpairs(this,varargin)






    if nargin==1
        pvpairs=[];
    else
        pvpairs=varargin;
    end

    if~isempty(pvpairs)

        if mod(length(pvpairs),2)~=0
            error(message('HDLShared:directemit:oddpvpairs',mfilename));
        end

        set(this,pvpairs{:});

    end
