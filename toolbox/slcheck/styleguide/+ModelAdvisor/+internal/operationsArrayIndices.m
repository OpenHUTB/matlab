
function res=operationsArrayIndices(str)
    res=false;
    if isempty(str)
        return;
    end

    if iscell(str)
        str=str{1};
    end

    tokens=regexp(str,'\w\s*[(\[](.*?)[\])]','tokens');
    if~isempty(tokens)
        tokens=cellfun(@(x)x{:},tokens,'UniformOutput',false);
        res=~isempty(regexp(tokens{1},'[\/\+\*\-=~]','once'));
    end

end