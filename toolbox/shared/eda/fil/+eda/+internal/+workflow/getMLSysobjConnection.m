function ConnectionStr=getMLSysobjConnection(buildInfo)




    if isempty(buildInfo.BoardObj.ConnectionOptions)||...
        strcmpi(buildInfo.BoardObj.ConnectionOptions.Name,'UDP')||...
        (strcmpi(buildInfo.BoardObj.ConnectionOptions.Name,'Ethernet')&&~strcmpi(buildInfo.BoardObj.ConnectionOptions.Communication_Channel,'PSEthernet'))
        ConnectionStr=['char(''UDP'',''',buildInfo.IPAddress,''',''',buildInfo.MACAddress,''',''',buildInfo.BoardObj.ConnectionOptions.ProtocolParams,''')'];
    else
        tmp=buildInfo.BoardObj.ConnectionOptions;
        libpath=tmp.RTIOStreamLibName;
        if strcmpi(buildInfo.BoardObj.ConnectionOptions.Communication_Channel,'PSEthernet')
            tmp.Name='TCPIP';
        end
        ConnectionStr=['char(''',tmp.Name,''',''',libpath,''','''...
        ,tmp.RTIOStreamParams,''',''',tmp.ProtocolParams,''')'];
    end

end
