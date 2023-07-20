function setAxesOperationMode(clientID,mode,value)










































    switch mode
    case{'ZoomMarquee','ZoomT','ZoomY'}
        if~islogical(value)
            error(message('SDI:sdi:InvalidValueZoomMode'));
        end
    case{'NormalMode','ZoomOut','FitWindow'}
        value=true;
    case 'DataCursors'
        if~isnumeric(value)||value<0||value>2
            error(message('SDI:sdi:InvalidDataCursors'));
        end
    otherwise
        error(message('SDI:sdi:InvalidAxesOperationMode'));
    end

    data.ClientID=clientID;
    data.OperationMode=mode;
    data.OperationValue=value;
    message.publish('/sdi2/axesOperationMode',data);

end
