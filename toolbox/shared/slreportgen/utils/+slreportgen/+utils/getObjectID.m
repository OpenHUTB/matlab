function id=getObjectID(obj,varargin)























    if iscell(obj)
        obj=obj{1};
    end
    obj=slreportgen.utils.getSlSfObject(obj);

    p=inputParser();
    addParameter(p,"Hash",true,@(x)isempty(x)||islogical(x));
    parse(p,varargin{:});
    args=p.Results;

    try
        if isa(obj,"Simulink.Parameter")

            id=compose("sl-%s",obj.getBoundObjectName());
        elseif isa(obj,"Simulink.Port")

            id=compose("sl-%s-%s-%i",getfullname(obj.Handle),obj.PortType,obj.PortNumber);
        elseif isa(obj,"Stateflow.Object")
            id=compose("sf-%s",Simulink.ID.getSID(obj));
        else
            id=compose("sl-%s",Simulink.ID.getSID(obj));
        end
    catch
        id=compose("slsf-%s",mlreportgen.utils.toString(obj,0));
    end



    if args.Hash
        id=mlreportgen.utils.normalizeLinkID(id);
    end

    id=char(id);
end
