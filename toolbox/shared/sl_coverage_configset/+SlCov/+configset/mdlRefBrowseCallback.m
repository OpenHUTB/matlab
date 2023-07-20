function mdlRefBrowseCallback(slcovcc,parentDialog)



    cs=slcovcc.getConfigSet;
    slcovcc.modelH=cs.getModel;
    covMdlRefSelUIH=slcovcc.getCovMdlRefSelUIH;


    if~isempty(covMdlRefSelUIH)&&isvalid(covMdlRefSelUIH)&&ishandle(covMdlRefSelUIH.m_editor.getDialog)
        covMdlRefSelUIH.m_editor.show;
    else
        covMdlRefSelUIH=cv.ModelRefSelectorUI.UI(slcovcc.modelH,parentDialog,...
        slcovcc.CovIncludeTopModel,slcovcc.CovModelRefEnable,slcovcc.CovModelRefExcluded);
        slcovcc.setCovMdlRefSelUIH(covMdlRefSelUIH);
        covMdlRefSelUIH.m_panelH=[];
        covMdlRefSelUIH.m_callerSource=slcovcc;
    end
