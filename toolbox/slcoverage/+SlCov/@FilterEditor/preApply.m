function[status,errstr]=preApply(this)




    dlgHandle=this.m_dlg;

    if dlgHandle.hasUnappliedChanges
        this.hasUnappliedChanges=true;
    end

    status=true;
    errstr='';