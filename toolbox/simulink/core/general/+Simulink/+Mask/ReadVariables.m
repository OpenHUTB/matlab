

function cellVars=ReadVariables(~,mtreeObj)
    nameVar=mtfind(mtreeObj,'Isvar',true);
    cellVars=strings(nameVar);
    cellVars=cellfun(@(x)char(x),cellVars,'UniformOutput',0);
    if(~isempty(cellVars))
        set_var=containers.Map({cellVars{1}},{0});
        for i=cellVars
            set_var(i{1})=0;
        end
        cellVars=set_var.keys;
    else
        cellVars='';
    end
end