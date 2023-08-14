function afTime=datetime2aftime(time)



    if isempty(time.TimeZone)


        time.TimeZone=icomm.pi.internal.defaultTimeZone();
    end

    time.Format='yyyy/MM/dd HH:mm:ss Z';

    formatProvider=OSIsoft.AF.Time.AFLocaleIndependentFormatProvider();

    afTime=OSIsoft.AF.Time.AFTime(char(time),formatProvider);
end