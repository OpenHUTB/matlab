


function out=isSupportedReusableSubsystem(blk_sid)

    out=false;


    if~strcmpi(get_param(blk_sid,'BlockType'),'SubSystem')
        return;
    end

    RTWSystemCode=get_param(blk_sid,'RTWSystemCode');

    if strcmpi(RTWSystemCode,'Reusable function')

        out=true;
    end

end