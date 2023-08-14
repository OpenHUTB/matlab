function setOslcOptionsFromQueryBuilderDialog(this,childDlgSrc,commit)




    childDlgSrc.caller.setEnabled('SlreqImportDlg_attributeSelector',true);

    if commit

        this.queryString=childDlgSrc.queryString;


        this.refreshDlg(childDlgSrc.caller);
    end
end

