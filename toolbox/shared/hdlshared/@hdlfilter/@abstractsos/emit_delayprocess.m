function[sections_arch,delayoutputsignal]=emit_delayprocess(this,sections_arch,signame,input,storagevtype,storagesltype,section_idx)






    sec=section_idx;
    if sec~=0
        section=num2str(sec);
    end
    processname=signame;
    if strcmp(signame(end-7:end),'_section')
        processname=signame(1:((strfind(signame,'_')-1)));
    end

    [tempname,delayoutputsignal]=hdlnewsignal([signame,section],'filter',-1,hdlsignaliscomplex(input),0,...
    storagevtype,storagesltype);
    hdlregsignal(delayoutputsignal);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(delayoutputsignal)];
    [tempbody,tempsignals]=hdlunitdelay(input,delayoutputsignal,...
    [processname,hdlgetparameter('clock_process_label'),'_section',section],0);
    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
    sections_arch.signals=[sections_arch.signals,tempsignals];



