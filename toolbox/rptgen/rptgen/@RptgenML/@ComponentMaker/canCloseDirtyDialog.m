function continueClose=canCloseDirtyDialog(this)







    yes=getString(message('rptgen:RptgenML_ComponentMaker:yesLabel'));
    no=getString(message('rptgen:RptgenML_ComponentMaker:noLabel'));
    cancel=getString(message('rptgen:RptgenML_ComponentMaker:cancelLabel'));

    continueClose=true;

    closeResult=questdlg(sprintf(getString(message('rptgen:RptgenML_ComponentMaker:buildBeforeClosing')),this.getDisplayLabel),...
    getString(message('rptgen:RptgenML_ComponentMaker:ReportGeneratorLabel')),...
    yes,no,cancel,cancel);
    switch closeResult
    case yes
        this.build(true);
    case no

    otherwise
        continueClose=false;
    end
