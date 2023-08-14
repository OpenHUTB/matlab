function HDL_SystemVerilog(mode)
    if strcmp(mode,'on')&&~mislocked
        mlock;
    elseif strcmp(mode,'off')&&mislocked
        munlock;
    else
        if~(strcmp(mode,'on')||strcmp(mode,'off'))
            munlock;
            error('Undefined argument, possible value are ''on'' OR ''off''...Resetting SystemVerilog mode to ''off''');
        end
    end
end

