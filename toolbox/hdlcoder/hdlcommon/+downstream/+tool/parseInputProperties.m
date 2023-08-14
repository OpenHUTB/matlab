function p=parseInputProperties(propList,varargin)




    p=inputParser;
    for ii=1:numel(propList)
        prop=propList{ii};
        p.addParameter(prop{1},prop{2});
    end
    p.parse(varargin{:});

end

