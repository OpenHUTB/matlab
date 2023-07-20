function s=size_string(sz)




    if~isa(sz,'coder.Type')
        sz=sz.val;
    end


    s.SizeVector=sz.SizeVector;
    s.VariableDims=sz.VariableDims;

    str='';
    for i=1:numel(sz.SizeVector)
        if i>1
            str=[str,'x'];%#ok MLINT
        end
        if sz.VariableDims(i)
            str=[str,':'];%#ok MLINT
        end
        str=[str,num2str(sz.SizeVector(i))];%#ok MLINT
    end
    s.SizeString=str;
end
