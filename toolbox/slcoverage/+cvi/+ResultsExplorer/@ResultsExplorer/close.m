function close(topModelHandle)






    mes=find(DAStudio.Root,'-isa','DAStudio.Explorer');
    for idx=1:numel(mes)
        mec=mes(idx);
        try
            if isa(mec.getRoot,'SlCovResultsExplorer.Root')&&...
                isequal(topModelHandle,mec.getRoot.m_impl.resultsExplorer.topModelHandle)
                obj=mec.getRoot.m_impl.resultsExplorer;
                obj.isClosing=true;
                obj.save;
                cvi.FilterExplorer.FilterExplorer.close(obj.filterExplorer);
                obj.explorer.hide;
                delete(obj.explorer);
                delete(obj);
            end
        catch MEx %#ok<NASGU>
        end
    end
end