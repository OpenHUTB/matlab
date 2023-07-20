


function schema=lampIconRF(fncname,userData,cbinfo,action)
    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(userData,cbinfo,action);
    else
        schema=[];
        fnc(userData,cbinfo,action);
    end
end

function getIcon(userData,cbinfo,action)
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        return;
    end
    blockHandle=block.handle;
    isLampBlock=strcmp(get_param(blockHandle,'BlockType'),'LampBlock');
    isPushButtonBlock=strcmp(get_param(blockHandle,'BlockType'),'PushButtonBlock');


    if~isLampBlock&&~isPushButtonBlock
        return;
    end
    icon=get_param(blockHandle,'Icon');
    customIcon=get_param(blockHandle,'CustomIcon');
    if~strcmp(userData,'Custom')
        if strcmp(icon,userData)
            action.selected=true;
        else
            action.selected=false;
        end
    else
        if~isempty(customIcon)
            action.enabled=true;
        else
            action.enabled=false;
        end
    end
end