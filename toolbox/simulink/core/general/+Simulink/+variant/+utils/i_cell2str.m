

function str=i_cell2str(x)
    str='';
    if isempty(x)
        return;
    end
    for i=1:numel(x)
        str=[str,x{i},', '];%#ok<AGROW>
    end
    str=str(1:end-2);
end