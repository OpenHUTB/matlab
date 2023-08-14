

function cellFuncs=ReadFunctions(~,mtreeObj)
    NameFunc=mtfind(mtreeObj,'Isfun',true);
    cellFunc=strings(NameFunc);
    cellFunc=cellfun(@(x)char(x),cellFunc,'UniformOutput',0);
    if(~isempty(cellFunc))
        setFunc=containers.Map({cellFunc{1}},{0});
        for i=cellFunc
            setFunc(i{1})=0;
        end
        setKeys=setFunc.keys;
    else
        setKeys={};
    end

    userDefined=~(cellfun(@(x)exist(char(x)),setKeys));
    cellUserDefined={};
    for i=1:numel(userDefined)
        if(userDefined(i))
            cellUserDefined{numel(cellUserDefined)+1}=setKeys{i};
        end
    end
    cellFuncs=cellUserDefined;
end