function cleanupAtModelClose(blk)




    modelName=bdroot(blk);




    currentDlgs=DAStudio.ToolRoot.getOpenDialogs;
    for idx=1:length(currentDlgs)
        dlg=currentDlgs(idx);
        src=dlg.getSource;

        if isa(src,'slrealtime.internal.dds.ui.TopicSelector')||...
            isa(src,'slrealtime.internal.dds.ui.DictionarySelector')

            if strcmp(src.ModelName,modelName)

                dlg.delete;
                return;
            end
        end
    end
end

