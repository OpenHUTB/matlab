function blk=add_comment_cb(~)





    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if~isempty(studios)
        studio=studios(1);
        activeEditor=studio.App.getActiveEditor;
        if~isempty(activeEditor)
            blk=simulink.designreview.UriProvider.getTargetUri(activeEditor);
        end
    end
end
