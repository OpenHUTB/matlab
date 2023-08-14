















function mtreeObject=createMtreeObject(codeFragment,resolvedSymbolIds)

    if nargin==1
        mtreeObject=mtree(codeFragment);
    else
        mtreeParameterString=createMtreeParameterString(resolvedSymbolIds);
        if isempty(mtreeParameterString)
            mtreeObject=mtree(codeFragment);
        else
            mtreeObject=mtree(codeFragment,mtreeParameterString);
        end
    end

end












function mtreeParameterString=createMtreeParameterString(resolvedSymbolIds)

    dataIds=Advisor.Utils.Stateflow.filterSymbolIds(resolvedSymbolIds,'data');

    if isempty(dataIds)
        mtreeParameterString='';
    else
        for index=1:length(dataIds)
            name=sf('get',dataIds(index),'.name');
            if index==1
                mtreeParameterString=['-param=',name];
            else
                mtreeParameterString=[mtreeParameterString,',',name];%#ok<AGROW>
            end
        end
    end

end

