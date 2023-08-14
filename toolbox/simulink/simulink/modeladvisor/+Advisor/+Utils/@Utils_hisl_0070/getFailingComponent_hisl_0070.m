function failObj=getFailingComponent_hisl_0070(model,blocks,varargin)








    if nargin==6
        opts.lookUnderMask=varargin{3};
        opts.followLinks=varargin{4};
        opts.link2ContainerOnly=varargin{5};
        opts.excludedBlks=varargin{6};
    elseif nargin==5
        opts.lookUnderMask=varargin{3};
        opts.followLinks=varargin{4};
        opts.link2ContainerOnly=varargin{5};
        opts.excludedBlks=ModelAdvisor.Common.getExemptBlockList_RequirementLink;
    elseif nargin==4
        opts.lookUnderMask=varargin{3};
        opts.followLinks=varargin{4};
        opts.link2ContainerOnly=true;
        opts.excludedBlks=ModelAdvisor.Common.getExemptBlockList_RequirementLink;
    elseif nargin==3
        opts.lookUnderMask=varargin{3};
        opts.followLinks='off';
        opts.link2ContainerOnly=true;
        opts.excludedBlks=ModelAdvisor.Common.getExemptBlockList_RequirementLink;
    elseif nargin==2
        opts.lookUnderMask='off';
        opts.followLinks='off';
        opts.link2ContainerOnly=true;
        opts.excludedBlks=ModelAdvisor.Common.getExemptBlockList_RequirementLink;
    else
        error('getComponent function takes 2 to 5 arguments');
    end
    [opts.slHs,opts.sfHs]=Advisor.Utils.Utils_hisl_0070.getHandlesWithRequirements_hisl_0070(model);
    failObj.simComponent=Advisor.Utils.Utils_hisl_0070.getFailingSimObj_hisl_0070(blocks.simComponent,opts);
    if isempty(blocks.sfComponent)
        failObj.sfComponent=[];
    else
        failObj.sfComponent=Advisor.Utils.Utils_hisl_0070.getFailingSFObj_hisl_0070(blocks.sfComponent,opts);
    end

    for ii=1:length(failObj.sfComponent)
        if isa(failObj.sfComponent{ii},'Stateflow.Chart')||isa(failObj.sfComponent{ii},'Stateflow.LinkChart')||isa(failObj.sfComponent{ii},'Stateflow.EMChart')
            failObj.simComponent=failObj.simComponent(cellfun(@(x)x~=get_param(sfprivate('chart2block',failObj.sfComponent{ii}.Id),'Object'),failObj.simComponent));
        end
    end

    failObj.mlComponent=Advisor.Utils.Utils_hisl_0070.getFailingMLFunctions_hisl_0070(blocks.mlComponent,opts,false);
end

