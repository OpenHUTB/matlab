function publish(channel,msg,varargin)




    if nargin>1
        msg=convertStringsToChars(msg);
    end

    if connector.isRunning
        if nargin>2
            name=varargin{1};
        else
            name='shared';
        end


        messageJSON=unicode2native(mls.internal.toJSON(msg),'UTF-8');
        channel=strrep(channel,'//','/');
        try
            builtin('_connectorMessageServicePublish',channel,messageJSON,name);
        catch ex
            logger=connector.internal.Logger('connector::message_service_m');
            logger.error(['Error in publish: ',ex.getReport()]);
        end
    else
        warning(message('MATLAB:connector:connector:ConnectorNotRunning'));
    end
