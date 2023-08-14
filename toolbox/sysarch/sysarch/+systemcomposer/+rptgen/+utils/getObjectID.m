function id=getObjectID(obj,varargin)
    if iscell(obj)
        obj=obj{1};
    end

    p=inputParser();
    addParameter(p,"Hash",true,@(x)isempty(x)||islogical(x));
    parse(p,varargin{:});
    args=p.Results;

    try
        if isa(obj,"")

            id=compose("sl-%s",obj.getBoundObjectName());
        elseif isa(obj,"systemcomposer.rptgen.finder.InterfaceResult")

            id=compose("ZC-%s-%s",obj.InterfaceName,obj.Object);
        elseif isa(obj,"systemcomposer.rptgen.finder.ComponentResult")
            id=compose("ZC-%s-%s-%s",obj.Parent,obj.Name,obj.Object);
        elseif isa(obj,"systemcomposer.rptgen.finder.AllocationSetResult")
            id=compose("ZC-%s-%s-%s",obj.SourceModel,obj.TargetModel,obj.Object);
        elseif isa(obj,"systemcomposer.rptgen.finder.ProfileResult")
            id=compose("ZC-%s-%s",obj.Name,obj.Object);
        elseif isa(obj,"systemcomposer.rptgen.finder.StereotypeResult")
            id=compose("ZC-%s-%s",obj.Name,obj.Object);
        elseif isa(obj,"systemcomposer.rptgen.finder.RequirementLinkResult")
            id=compose("ZC-%s",obj.Destination);
        elseif isa(obj,"systemcomposer.rptgen.finder.RequirementSetResult")
            id=compose("ZC-%s",obj.ID);
        end
    catch
        id=compose("slsf-%s",mlreportgen.utils.toString(obj,0));
    end















    id=char(id);
end