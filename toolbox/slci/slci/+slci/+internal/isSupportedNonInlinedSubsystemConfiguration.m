




function[out]=isSupportedNonInlinedSubsystemConfiguration(...
    blk_sid,mdlName)

    out=false;

    codeInterfPackaging=get_param(mdlName,'CodeInterfacePackaging');
    if strcmpi(codeInterfPackaging,'Nonreusable function')...
        ||strcmpi(codeInterfPackaging,'C++ class')


        obj=get_param(blk_sid,'Object');
        out=strcmpi(slci.internal.getSubsystemType(obj),'SimulinkFunction')...
        ||slci.internal.isSupportedNonReusableSubsystem(blk_sid)...
        ||(slci.internal.isSupportedReusableSubsystem(blk_sid)...
        &&strcmpi(get_param(mdlName,'PassReuseOutputArgsAs'),...
        'Individual arguments'));
    end

end
