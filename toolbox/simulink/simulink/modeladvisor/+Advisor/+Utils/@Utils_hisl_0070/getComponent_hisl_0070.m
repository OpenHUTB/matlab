function component=getComponent_hisl_0070(system,varargin)













    if nargin==5
        opts.lookUnderMask=varargin{2};
        opts.followLinks=varargin{3};
        opts.externalFile=varargin{4};
        opts.link2ContainerOnly=varargin{5};
    elseif nargin==4
        opts.lookUnderMask=varargin{2};
        opts.followLinks=varargin{3};
        opts.externalFile=varargin{4};
        opts.link2ContainerOnly=true;
    elseif nargin==3
        opts.lookUnderMask=varargin{2};
        opts.followLinks=varargin{3};
        opts.externalFile=true;
        opts.link2ContainerOnly=true;
    elseif nargin==2
        opts.lookUnderMask=varargin{2};
        opts.followLinks='off';
        opts.externalFile=true;
        opts.link2ContainerOnly=true;
    elseif nargin==1
        opts.lookUnderMask='off';
        opts.followLinks='off';
        opts.externalFile=true;
        opts.link2ContainerOnly=true;
    else
        error('getComponent function takes 1 to 5 arguments');
    end

    simComponent=Advisor.Utils.Utils_hisl_0070.getSimComponent_hisl_0070(system,opts);
    component.sfComponent=Advisor.Utils.Utils_hisl_0070.getSFComponent_hisl_0070(simComponent,opts);

    if~isempty(simComponent)
        component.simComponent=get_param(simComponent,'object');
    end
    if opts.link2ContainerOnly
        component.mlComponent=Advisor.Utils.Utils_hisl_0070.getMLComponent_hisl_0070(system,opts);
    else
        component.mlComponent=[];
    end
end






