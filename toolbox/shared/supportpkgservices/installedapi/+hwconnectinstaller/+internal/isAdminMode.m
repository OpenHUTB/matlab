function ret=isAdminMode()

    if ispc()
        try
            perlScript=[tempname,'.pl'];
            LF=hex2dec('A');
            fid=fopen(perlScript,'w');
            if(fid==-1)
                return;
            end
            scriptText=[...
            'use strict;',LF...
            ,'use Win32;',LF...
            ,'if (Win32::IsAdminUser())',LF...
            ,'{',LF...
            ,'    print "1";',LF...
            ,'}',LF...
            ,'else',LF...
            ,'{',LF...
            ,'    print "0";',LF...
            ,'}',LF...
            ,'exit 0;',LF];
            fprintf(fid,'%s',scriptText);
            fclose(fid);
            [Admin,presult]=perl(perlScript);
            assert(presult==0);
            delete(perlScript);
            ret=strcmp(Admin,'1');
        catch ex %#ok<NASGU>
            if(2==exist(perlScript,'file'))
                delete(perlScript);
            end
            ret=false;
        end
    else

        ret=true;
    end