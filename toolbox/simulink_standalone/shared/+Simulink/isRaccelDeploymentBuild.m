function val=isRaccelDeploymentBuild(varargin)






    mlock;

    persistent isdep;
    if(isempty(isdep))
        isdep=false;
    end
    if(nargin>0)
        isdep=varargin{1};
    else
        val=isdep;
    end
