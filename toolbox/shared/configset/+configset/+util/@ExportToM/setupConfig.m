function setupConfig(obj,configArray)

















    config=struct('format','MATLAB function',...
    'comments','on',...
    'varname','cs',...
    'timestamp','on');

    if~isempty(configArray)




        argName=configArray{1};
        argValue=configArray{2};

        id=find(ismember(argName,'-format'));
        if~isempty(id)
            config.format=argValue{id};
        end

        id=find(ismember(argName,'-comments'));
        if~isempty(id)
            config.comments=argValue{id};
        end

        id=find(ismember(argName,'-varname'));
        if~isempty(id)
            config.varname=argValue{id};
        end

        id=find(ismember(argName,'-timestamp'));
        if~isempty(id)
            config.timestamp=argValue{id};
        end
    end

    obj.config=config;