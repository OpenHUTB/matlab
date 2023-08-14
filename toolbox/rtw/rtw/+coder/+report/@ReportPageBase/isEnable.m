function out=isEnable(obj,config)
    out=true;
    opts=obj.getConfigOption();
    if~isempty(opts)
        if~iscell(opts)
            opts={opts};
        end
        for i=1:length(opts)

            value=config.(opts{i});
            if strcmp(value,'off')
                out=false;
                return
            end
        end
    end
end
