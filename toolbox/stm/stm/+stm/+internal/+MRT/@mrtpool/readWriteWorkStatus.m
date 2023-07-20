function status=readWriteWorkStatus(statusString,bUpdate)




    persistent stm_Worker_Status;

    status='';
    if(isempty(stm_Worker_Status))
        stm_Worker_Status='Not Started';
    end
    if(bUpdate)
        stm_Worker_Status=statusString;
    else
        status=stm_Worker_Status;
    end
end