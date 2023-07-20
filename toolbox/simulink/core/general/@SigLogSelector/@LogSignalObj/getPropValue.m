function str=getPropValue(h,prop)




    str='';

    switch prop
    case{'Name'}
        str=h.Name;

    case{'SourcePath'}
        str=h.SourcePath;

    case{'NameMode'}
        if h.signalInfo.loggingInfo_.nameMode_
            str=DAStudio.message('Simulink:Logging:SigLogDlgNameModeTrue');
        else
            str=DAStudio.message('Simulink:Logging:SigLogDlgNameModeFalse');
        end

    case{'LoggingName'}
        str=h.signalInfo.loggingInfo_.loggingName_;
        if isequal(str,[])
            str='';
        end

    case{'DataLogging','DecimateData','LimitDataPoints'}
        val=eval(['h.signalInfo.loggingInfo_.',prop]);
        if val
            str='on';
        else
            str='off';
        end

    case{'Decimation','MaxPoints'}
        val=eval(['h.signalInfo.loggingInfo_.',prop]);
        str=num2str(val);
    end

end
