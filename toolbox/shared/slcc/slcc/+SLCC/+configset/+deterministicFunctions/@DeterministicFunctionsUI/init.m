function init(this,hParentDlg,hCompSrc)



    import SLCC.configset.deterministicFunctions.DeterministicFunctionsSS

    this.parentDlg=hParentDlg;
    this.csCompSrc=hCompSrc;
    this.fcnSettingsSS=DeterministicFunctionsSS(this,...
    hCompSrc.get_param('CustomCodeDeterministicFunctions'));

end


