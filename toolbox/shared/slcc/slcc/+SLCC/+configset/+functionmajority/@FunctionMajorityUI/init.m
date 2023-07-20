function init(this,hParentDlg,hCompSrc)



    import SLCC.configset.functionmajority.FunctionMajoritySS

    this.parentDlg=hParentDlg;
    this.csCompSrc=hCompSrc;
    this.fcnSettingsSS=FunctionMajoritySS(this,...
    hCompSrc.get_param('CustomCodeFunctionArrayLayout'));

end


