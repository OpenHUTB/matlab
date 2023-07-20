


function out=isSupportedNonReusableSubsystem(blk_sid)

    out=false;


    if~strcmpi(get_param(blk_sid,'BlockType'),'SubSystem')
        return;
    end

    RTWSystemCode=get_param(blk_sid,'RTWSystemCode');

    if strcmpi(RTWSystemCode,'Nonreusable function')
        RTWFcnNameOpts=get_param(blk_sid,'RTWFcnNameOpts');
        FunctionInterfaceSpec=get_param(blk_sid,...
        'FunctionInterfaceSpec');
        FunctionWithSeparateData=get_param(blk_sid,...
        'FunctionWithSeparateData');

        out=strcmpi(RTWFcnNameOpts,'User specified')...
        &&strcmpi(FunctionInterfaceSpec,'void_void')...
        &&strcmpi(FunctionWithSeparateData,'off');
    end

end