





function setLocalTimezone(~,timezone)

    persistent logger
    if isempty(logger)
        logger=connector.internal.Logger('connector::lifecycle');
    end

    tz='';
    if nargin<2

        try
            prop=connector.internal.getClientTypeProperties();
            if isfield(prop,'TIMEZONE')
                tz=prop.TIMEZONE;
            end
        catch

        end
    else

        tz=timezone;
    end


    try
        dt=datetime('now','TimeZone',tz);
        datetime.setLocalTimeZone(dt.TimeZone);
        logger.info('Setting local timezone to %s',dt.TimeZone)

    catch

        logger.warning('Invalid timezone string %s',tz)
        datetime.setLocalTimeZone([]);
    end
end