



function varidx=CheckForEachMaskVarRefInMaskScript(maskScript,varList)


    varidx=0;
    T=mtree(maskScript);
    for i=1:length(varList)
        if(~isempty(mtfind(T,'String',varList{i}))||...
            ~isempty(mtfind(T,'Var',varList{i}))||...
            ~isempty(mtfind(T,'Fun',varList{i})))
            varidx=i;
            return;
        end
    end
end

