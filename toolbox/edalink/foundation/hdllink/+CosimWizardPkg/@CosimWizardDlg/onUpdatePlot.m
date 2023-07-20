function onUpdatePlot(this,dlg)



    try

        runtime=getWidgetValue(this,dlg,'edaRunTime');
        this.UserData.ResetRunTimeStr=runtime;


        genWaveform(this.UserData,false);

        restoreFromSchema(this,dlg);
        clearStatusMessage(this,dlg);

    catch ME
        displayErrorMessage(this,dlg,ME.message);
    end

