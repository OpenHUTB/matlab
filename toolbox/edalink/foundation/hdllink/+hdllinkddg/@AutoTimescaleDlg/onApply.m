function onApply(this,dialog)



    if(~this.isCurrentTimeScaleValid)
        errmsg=sprintf(['The current timescale setting is invalid. '...
        ,'To change the timescale, supply a valid sample time in one \n'...
        ,'of the editable cells of the table, or click the ''Use Suggested Timescale'' button.']);
        errdlg=DAStudio.DialogProvider;
        errdlg.errordlg(errmsg,'Error',true);
        return;
    end

    unitName=getComboBoxText(dialog,'HdlTimeUnit');

    switch(unitName)
    case 'Tick'
        unitvalue=this.UserData.Precision;
    case 'fs'
        unitvalue=1e-15;
    case 'ps'
        unitvalue=1e-12;
    case 'ns'
        unitvalue=1e-9;
    case 'us'
        unitvalue=1e-6;
    case 'ms'
        unitvalue=1e-3;
    case 's'
        unitvalue=1;
    otherwise
        error(message('HDLLink:AutoTimescale:InvalidTimeUnit'));
    end

    this.UserData.ParentDialog.Block.TimingScaleFactor=num2str(this.UserData.TimeScale/unitvalue,'%16.15g');
    this.UserData.ParentDialog.Block.TimingMode=unitName;





