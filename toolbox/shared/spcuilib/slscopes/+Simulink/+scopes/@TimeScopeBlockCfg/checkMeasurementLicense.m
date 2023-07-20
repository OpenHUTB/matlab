function[success,errMessage]=checkMeasurementLicense(~,id)




    isDSPInstalled=~isempty(ver('dsp'));
    isSimScapeInstalled=~isempty(ver('simscape'));

    if~isDSPInstalled&&~isSimScapeInstalled
        success=false;
        errMessage=getString(message('Spcuilib:scopes:DSTAndSimScapeNotInstalled'));
        return;
    end


    if isSimScapeInstalled
        [success,errMessage]=builtin('license','checkout','Simscape');
        if success
            return
        end
    end



    if isDSPInstalled
        if~isSimScapeInstalled||builtin('license','test','Signal_Blocks')
            [success,errMessage]=builtin('license','checkout','Signal_Blocks');
        end
    end


    if~success

        switch id
        case 'peaks'
            str=getString(message('Spcuilib:measurements:PeakFinder'));
        case 'signalstats'
            str=getString(message('Spcuilib:measurements:SignalStatistics'));
        case 'bilevel'
            str=getString(message('Spcuilib:measurements:BilevelMeasurements'));
        end
        errMessage=getString(message('Spcuilib:scopes:MeasurementLicenseError',str));
    end


