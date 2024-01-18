function[url,errMsg]=cmdToUrl(cmd,opt)

    checkPort=true;
    protocol='';
    errMsg='';

    if nargin>1
        if ischar(opt)
            protocol=opt;

        elseif opt
            cmd=setSuppressBrowser(cmd);
        else
            checkPort=false;
        end
    end

    leftParenths=strfind(cmd,'(');
    firstLeftParenth=leftParenths(1);
    rightParenths=strfind(cmd,')');
    lastRightParenth=rightParenths(end);
    command=cmd(1:firstLeftParenth-1);
    args=cmd(firstLeftParenth+1:lastRightParenth-1);

    args=slreq.uri.urlencode4NonAscii(args);

    argsQuoted=strrep(args,'''','"');
    argsEscaped=strrep(argsQuoted,'\','\\');
    if~connector.internal.isRestMatlabRunning
        connector.internal.ensureRestMatlabOn;
    end

    if~checkPort||isAllowedPortNumber(connector.port)
        url=mls.internal.generateUrl(['/matlab/feval/',command],['arguments=[',argsEscaped,']']);
        if~isempty(protocol)
            url=adjustProtocol(url,protocol);
        end
    else
        errMsg=rmiut.warnNonDefaultPort(connector.port,true);
        url='';
    end
end


function url=adjustProtocol(url,protocol)
    switch protocol
    case 'https'
        url=regexprep(url,'^http:','https:');
        url=strrep(url,[':',int2str(connector.port),'/'],[':',connector.securePort,'/']);
    otherwise
        error(message('Slvnv:rmiut:matlabConnectorOn:UnsupportedProtocol',protocol));
    end
end


function cmd_out=setSuppressBrowser(cmd_in)
    cmd_out=regexprep(cmd_in,''');$',''',''_suppress_browser'');');
end


function yesno=isAllowedPortNumber(portNumber)
    if portNumber==31415
        yesno=true;
        return;
    end
    customSettings=rmipref('CustomSettings');
    if isfield(customSettings,'allowedPorts')
        yesno=any(customSettings.allowedPorts==portNumber);
    else
        yesno=false;
    end
end

