function highlightSystem(blocks,type)





















    if nargin==1
        type='find';
    end

    handles=lGetHandles(blocks);
    lUnhighlight(handles);
    lUnSelect();
    lSelect(handles);
    hilite_system(handles,type);
    lUpdateGcb(handles(end));

end

function handles=lGetHandles(blocks)


    if iscell(blocks)
        handles=cell2mat(get_param(blocks,'Handle'));
    elseif ischar(blocks)
        handles=get_param(blocks,'Handle');
    else
        handles=blocks;
    end

end

function lUnhighlight(handles)

    models=unique(bdroot(handles));
    arrayfun(@(m)(set_param(m,'HiliteAncestors','none')),models);
end

function lUnSelect()




    blocks=find_system(bdroot,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','Selected','on');
    cellfun(@(b)(set_param(b,'Selected','off')),blocks);
end

function lSelect(handles)


    blocks=unique(handles);
    arrayfun(@(b)(set_param(b,'Selected','on')),blocks);
end

function lUpdateGcb(blockHandle)


    parent=get_param(blockHandle,'Parent');
    if~isempty(parent)
        set_param(0,'CurrentSystem',parent);
        set_param(parent,'CurrentBlock',blockHandle);
    end

end

