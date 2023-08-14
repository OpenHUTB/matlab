function str=cell2str(c)



    str='{';
    for k=1:numel(c)
        str=[str,'''',c{k},''''];%#ok<*AGROW>
        if k~=numel(c)
            str=[str,','];
        end
    end
    str=[str,'}'];
end
