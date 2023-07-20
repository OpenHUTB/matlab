






function status=isBlockCommented(blockObj)
    status=false;
    while~isempty(blockObj)&&isa(blockObj,'Simulink.Block')
        if strcmp(blockObj.Commented,'on')||strcmp(blockObj.Commented,'through')
            status=true;
            break;
        end

        blockObj=get_param(blockObj.Parent,'Object');
    end
end