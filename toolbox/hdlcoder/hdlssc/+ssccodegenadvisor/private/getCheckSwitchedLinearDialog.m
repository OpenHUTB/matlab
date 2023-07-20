function tbTab=getCheckSwitchedLinearDialog()














    description.Type='text';
    description.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSwitchedLinearCheckTitleTips');
    description.RowSpan=[1,1];
    descriptionSection.Type='panel';
    descriptionSection.Items={description};
    descriptionSection.LayoutGrid=[1,4];
    descriptionSection.RowSpan=[1,1];
    descriptionSection.ColSpan=[1,4];
    descriptionSection.Enabled=true;

    tbTab.Items={descriptionSection};
    tbTab.LayoutGrid=[1,4];
    tbTab.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSwitchedLinearCheckTitle');
