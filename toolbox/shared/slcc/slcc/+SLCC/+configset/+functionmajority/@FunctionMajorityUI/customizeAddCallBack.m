function customizeAddCallBack(this)



    import SLCC.configset.functionmajority.MajorityUIOpts;
    import SLCC.configset.functionmajority.utils.*;

    editHint=getString(message('Simulink:CustomCode:MajorityDlgSSFcnNameEditHint'));
    arrayLayoutOptsEnlgish=getFunctionArrayLayoutOptsEnglish();
    defaultArrayLayout=arrayLayoutOptsEnlgish{int32(MajorityUIOpts.ColumnMajor)};
    fcnMajorityEntry=struct('FunctionName',editHint,'ArrayLayout',defaultArrayLayout);
    this.fcnSettingsSS.addNewChildren(fcnMajorityEntry);
    this.enableApplyOnParentUponApply=true;
end
