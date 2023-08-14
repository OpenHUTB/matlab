function available=isListenPortAvailable(portnum,varargin)





    diagnose=false;
    if nargin>1
        diagnose=varargin{1};
    end
    available=~testConnectionTo(portnum,diagnose);
end

function result=testConnectionTo(portNumber,diagnose)

    result=false;

    try


        perlScript=[tempname,'.pl'];
        LF=hex2dec('A');
        fid=fopen(perlScript,'w');
        if(-1==fid)

            performDiagnostics(diagnose,'perl-file-creation');
            return;
        end
        scriptText=[...
        'use strict;',LF...
        ,'use Socket;',LF...
        ,'my $portNumber = shift;',LF...
        ,'my $hostName = shift;',LF...
        ,'my $protocol = getprotobyname(''tcp'');',LF...
        ,'my $serverAddress = inet_aton($hostName);',LF...
        ,'my $serverEndPoint = sockaddr_in($portNumber,$serverAddress);',LF...
        ,'print "Attempting connection to $hostName:$portNumber\n";',LF...
        ,'socket(SOCKET,PF_INET,SOCK_STREAM,$protocol) or print "Failed to create socket: $!" and exit 1;',LF...
        ,'connect(SOCKET,$serverEndPoint) or print "Failed to connect: $!" and exit 1;',LF...
        ,'print "Connected!";',LF...
        ,'close SOCKET;',LF...
        ,'exit 0;',LF];
        fprintf(fid,'%s',scriptText);
        fclose(fid);


        [status,result]=perl(perlScript,num2str(portNumber),'LocalHost');
        if(0==result)
            result=true;
        else
            result=false;
        end






        delete(perlScript);

    catch ex
        result=false;
        fprintf('%s\n',ex.message);

        if(2==exist(perlScript,'file'))
            delete(perlScript);
        end

        performDiagnostics(diagnose,'error');
    end
end


function performDiagnostics(diagnose,state)
    if diagnose
        et_performPortDiagnostics(state);
    end
end

