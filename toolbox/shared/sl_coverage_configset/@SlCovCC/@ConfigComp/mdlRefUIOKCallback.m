function mdlRefUIOKCallback(this,mdlRefUI)


    set(this,'CovModelRefEnable',mdlRefUI.m_CovModelRefEnable);
    this.CovModelRefExcluded=mdlRefUI.m_CovModelRefExcluded;
    set(this,'CovIncludeTopModel',mdlRefUI.m_CovIncludeTopModel);

