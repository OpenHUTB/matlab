function customizeDeleteCallBack(this)



    removedAny=this.fcnSettingsSS.removeSelectedChildren();
    if removedAny
        this.enableApplyOnParentUponApply=true;
        this.thisDlg.enableApplyButton(true,false);
    end
end