function mdlRefRecordCoverageUpdate(this)



    covMdlRefSelUIH=this.getCovMdlRefSelUIH;
    if~isempty(covMdlRefSelUIH)&&isvalid(covMdlRefSelUIH)&&...
        ishandle(covMdlRefSelUIH.m_editor)&&~isempty(covMdlRefSelUIH.m_editor.getDialog)
        covMdlRefSelUIH.set_root_enabled_status;
    end
