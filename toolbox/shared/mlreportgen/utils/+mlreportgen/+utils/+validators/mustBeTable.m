function mustBeTable(value)







    condition=(isnumeric(value)&&isempty(value));
    if~condition
        if numel(value)==1
            condition=isa(value,'mlreportgen.dom.Table')||isa(value,'mlreportgen.dom.FormalTable');
        end
    end
    if~condition
        error(message("mlreportgen:utils:error:invalidTable"));
    end
end
