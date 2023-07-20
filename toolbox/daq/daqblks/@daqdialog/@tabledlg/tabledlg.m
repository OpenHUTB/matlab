function this=tabledlg(tableData,subSystemType)























    this=daqdialog.tabledlg;
    this.CheckBoxValue=eval(tableData{1});

    switch subSystemType
    case 'AnalogInput'
        this.HWChannelID=tableData{2};
        this.Name=tableData{3};
        this.Module=tableData{4};
        this.MeasurementType=tableData{5};
        this.InputRange=tableData{6};
        this.TerminalConfiguration=tableData{7};
        this.CouplingType=tableData{8};
    case 'AnalogOutput'
        this.HWChannelID=tableData{2};
        this.Name=tableData{3};
        this.Module=tableData{4};
        this.MeasurementType=tableData{5};
        this.OutputRange=tableData{6};
        if(length(tableData)==7)
            this.InitialValue=tableData{7};
        end
    case 'DigitalIO'
        this.HWLineID=tableData{2};
        this.Name=tableData{3};
        this.Module=tableData{4};
    otherwise

    end