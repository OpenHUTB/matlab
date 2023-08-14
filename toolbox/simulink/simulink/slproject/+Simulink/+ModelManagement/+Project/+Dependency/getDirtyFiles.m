function dirty=getDirtyFiles()








    dirty={};
    iterator=com.mathworks.mde.editor.MatlabEditorApplication.getInstance.getOpenEditors.iterator;
    while iterator.hasNext
        editor=iterator.next;
        if editor.isDirty&&~editor.isBuffer
            dirty{end+1}=char(editor.getLongName);%#ok<AGROW>
        end
    end


    if dependencies.internal.util.isProductInstalled('SL','simulink')&&is_simulink_loaded
        bds=Simulink.allBlockDiagrams();
        dirtyBds=bds(strcmp(get_param(bds,'Dirty'),'on'));
        models=get_param(dirtyBds,'FileName');
        dirty=[dirty,models];


        if dependencies.internal.util.isProductInstalled('SZ','simulinktest')
            try
                tfs=sltest.testmanager.getTestFiles();
                for i=1:length(tfs)
                    if tfs(i).Dirty
                        dirty{end+1}=tfs(i).FilePath;%#ok<AGROW>
                    end
                end
            catch


            end
        end
    end

end

