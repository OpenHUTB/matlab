function ipAddr=getHostIPAddress()




    ipAddr='';
    try
        perlScript=[tempname,'.pl'];
        LF=hex2dec('A');
        fid=fopen(perlScript,'w');
        if(-1==fid)
            return;
        end
        scriptText=[...
        'use strict;',LF...
        ,'use Socket;',LF...
        ,'my $hostName = shift;',LF...
        ,'my ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname($hostName);',LF...
        ,'my ($a,$b,$c,$d) = unpack(''C4'',$addrs[0]);',LF...
        ,'if (($a == ''127'') && ($b == ''0'') && ($c == ''0'') && ($d == ''1''))',LF...
        ,'{',LF...
        ,'    ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname($name);',LF...
        ,'    ($a,$b,$c,$d) = unpack(''C4'',$addrs[0]);',LF...
        ,'}',LF...
        ,'print "$a.$b.$c.$d\n";',LF...
        ,'exit 0;',LF];
        fprintf(fid,'%s',scriptText);
        fclose(fid);
        [ipAddr,presult]=perl(perlScript,'LocalHost');
        assert(0==presult);
        delete(perlScript);
    catch ex
        fprintf('%s\n',ex.message);
        if(2==exist(perlScript,'file'))
            delete(perlScript);
        end
        ipAddr='';
    end


