
function initStruct=CRCSInitModel(wrapperModelName,startTime)
    initStruct=struct('isError',false,'errorMsg','');
    try
        set_param(wrapperModelName,'StartTime',['hex2num(''',startTime,''')']);
        set_param(wrapperModelName,'StopTime',['hex2num(''',startTime,''')']);
    catch eCause
        initStruct.isError=true;
        if ismethod(eCause,'json')
            initStruct.errorMsg=eCause.json;
        else
            initStruct.errorMsg=jsonencode(eCause);
        end
    end

end
