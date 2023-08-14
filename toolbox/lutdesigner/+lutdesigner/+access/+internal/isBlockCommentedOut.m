function tf=isBlockCommentedOut(block)



    tf=false;

    hBlock=get_param(block,'Handle');
    if strcmp(get_param(hBlock,'Commented'),'on')
        tf=true;
        return;
    end

    hRoot=bdroot(hBlock);
    hParent=get_param(get_param(hBlock,'Parent'),'Handle');
    while hParent~=hRoot
        if strcmp(get_param(hParent,'Commented'),'on')
            tf=true;
            return;
        end
        hParent=get_param(get_param(hParent,'Parent'),'Handle');
    end
end
