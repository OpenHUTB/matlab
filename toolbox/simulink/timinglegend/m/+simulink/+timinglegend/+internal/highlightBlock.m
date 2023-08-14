function highlightBlock(blk)




    model=bdroot(blk);


    set_param(model,'HiliteAncestors','none');
    selected_blocks=find_system(model,'LookUnderMasks','all','FollowLinks','on','Selected','on');

    for idx=1:numel(selected_blocks)
        set_param(selected_blocks{idx},'Selected','off');
    end

    set_param(blk,'Selected','on');

    parents=get_param(blk,'Parent');
    open_system(parents,'force');

    Simulink.scrollToVisible(blk,'ensureFit','off','panMode','minimal');

    studio=simulink.designreview.Util.getActiveStudio();
    studio.App.hiliteAndFadeObject(diagram.resolver.resolve(blk));


    parent=get_param(blk,'Parent');
    if~isempty(parent)
        try
            set_param(0,'CurrentSystem',parent);
            set_param(parent,'CurrentBlock',get_param(blk,'Handle'));
        catch
        end
    end
end
