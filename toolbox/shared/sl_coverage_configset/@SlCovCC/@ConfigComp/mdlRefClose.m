

function mdlRefClose(this)
    covMdlRefSelUIH=this.getCovMdlRefSelUIH;
    if~isempty(covMdlRefSelUIH)&&isvalid(covMdlRefSelUIH)&&ishandle(covMdlRefSelUIH.m_editor.getDialog)
        covMdlRefSelUIH.closeCallback([Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase,'Hidden_Destroy']);
    end

