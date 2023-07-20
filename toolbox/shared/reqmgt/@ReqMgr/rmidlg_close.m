function[cont,info]=rmidlg_close(dlgSrc,~)



    if length(dlgSrc.objectH)==1&&ishandle(dlgSrc.objectH)&&...
        rmisl.is_signal_builder_block(dlgSrc.objectH)

        sigbuilder('cmdApi','requiopen',dlgSrc.objectH,false);
    end

    cont=true;
    info=[];
    dlgSrc.listener=[];

    ReqMgr.rmidlg_mgr('remove',dlgSrc.objectH);
