function res=closeAll()




    mes=find(DAStudio.Root,'-isa','DAStudio.Explorer');
    res=numel(mes);
    for idx=1:numel(mes)
        mexp=mes(idx);
        try
            if isa(mexp.getRoot,'SlCovResultsExplorer.Root')
                delete(mexp);
            end
        catch MEx %#ok<NASGU>
        end
    end
end