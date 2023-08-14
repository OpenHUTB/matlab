function out=isLoaded(varargin)



    mlock;
    persistent loaded;

    narginchk(0,1);

    if nargin==0
        if isempty(loaded)
            out=false;
        else
            out=true;
        end
    else
        assert(varargin{1}==true);

        loaded=true;
        out=true;
    end

