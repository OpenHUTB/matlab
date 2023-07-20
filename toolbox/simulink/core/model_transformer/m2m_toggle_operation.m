
function m2m_toggle_operation(system,sid,check)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    m2m_obj=mdladvObj.UserData;

    blk=strsplit(sid,'@');
    if length(blk)==1
        if check
            m2m_obj.include(sid);
        else
            m2m_obj.exclude(sid);
        end
    else
        if check
            m2m_obj.includePort(blk{1},str2num(blk{2}));
        else
            m2m_obj.excludePort(blk{1},str2num(blk{2}));
        end
    end







end