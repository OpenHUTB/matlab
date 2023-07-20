function url=getConnectorTestURL()

    url='https://127.0.0.1:31515/matlab/oslc/inboundTest';



    if connector.securePort~=31515
        messageText=[...
        getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine1',connector.securePort)),newline...
        ,getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine2'))...
        ,getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine3'))];
        rmiut.warnNoBacktrace(messageText);
    end
end
