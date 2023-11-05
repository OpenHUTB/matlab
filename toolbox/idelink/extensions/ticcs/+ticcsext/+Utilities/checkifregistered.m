function varargout=checkifregistered

    linkfoundation.autointerface.baselink.checkPlatformSupport(mfilename,...
    ticcsext.Utilities.getPlatformsSupported(),'ticcs');

    ProxyData=struct('Match',false,'Key','','CLSID','','Path','','ReqdPath','');
    StubData=struct('Match',false,'Key','','CLSID','','Path','','ReqdPath','','InCompDb',false);
    try
        [ProxyData.Key,StubData.Key]=getkeys;
        ProxyData.CLSID=winqueryreg('HKEY_CLASSES_ROOT',ProxyData.Key);
        if(~isempty(ProxyData.CLSID))
            ProxyPathKey=['CLSID\',ProxyData.CLSID,'\InprocServer32'];
            ProxyData.Path=winqueryreg('HKEY_CLASSES_ROOT',ProxyPathKey);
            ProxyData.ReqdPath=ticcsext.Utilities.LfCProperty('inprocFile-current-server');
            ProxyData.Match=cmpbinaries(ProxyData.Path,ProxyData.ReqdPath);
        end
        StubData.CLSID=winqueryreg('HKEY_CLASSES_ROOT',StubData.Key);
        if(~isempty(StubData.CLSID))
            switch(computer)
            case 'PCWIN64',
                StubPathKey=['Wow6432Node\CLSID\',StubData.CLSID,'\InprocServer32'];
            otherwise,
                StubPathKey=['CLSID\',StubData.CLSID,'\InprocServer32'];
            end
            StubData.Path=winqueryreg('HKEY_CLASSES_ROOT',StubPathKey);
            StubData.ReqdPath=ticcsext.Utilities.LfCProperty('inprocFile-current-client');
            StubData.Match=cmpbinaries(StubData.Path,StubData.ReqdPath);
            DbInfo=pluginInfoInDb();
            if(~isempty(DbInfo)&&isfield(DbInfo,'Location'))
                for i=1:length(DbInfo)
                    if exist(DbInfo(i).Location,'file')
                        StubData.InCompDb(i)=cmpbinaries(DbInfo(i).Location,StubData.ReqdPath);
                    else
                        StubData.InCompDb(i)=false;
                    end
                end
            end
        end
    catch regException %#ok<NASGU>
    end

    AllRegistered=ProxyData.Match&&StubData.Match&&any(StubData.InCompDb);

    switch(nargout)
    case 2,
        varargout(2)={struct('Proxy',ProxyData,'Stub',StubData)};
        varargout(1)={AllRegistered};
    case 1,
        varargout(1)={AllRegistered};
    otherwise,
        if(AllRegistered)
            disp(['LinkCCS (in [',ProxyData.Path,']) and OCX ([ ',StubData.Path,']) are registered.']);
        else
            disp('LinkCCS and OCX are not registered.');
        end
    end


    function[ProxyKey,StubKey]=getkeys
        StubKey=[getccsstubname(),'\CLSID'];
        ProxyKey=[getccsproxyname(),'\CLSID'];




        function match=cmpbinaries(left,right)
            match=strcmpi(left,right);
            if(~match)
                eleft=RTW.transformPaths(left,'pathType','full');
                eright=RTW.transformPaths(right,'pathType','full');
                match=strcmpi(eleft,eright);
                if(~match)
                    bleft=getbits(eleft);
                    bright=getbits(eright);
                    match=all(bleft==bright);
                end
            end



            function bits=getbits(fname)
                bits=[];%#ok<NASGU>
                fd=[];
                try
                    fd=fopen(fname,'r','native');
                    bits=fread(fd);
                    fclose(fd);
                catch ex %#ok<NASGU>
                    if(~isempty(fd))
                        fclose(fd);
                    end
                    bits=fname;
                end


                function pluginInfo=pluginInfoInDb()
                    try
                        iniContents=getIniFileContents();
                        regpat=formpattern();
                        pluginInfo=regexp(iniContents,regpat,'names');
                    catch ex
                        rethrow(ex);
                    end


                    function contents=getIniFileContents()
                        iniH=[];
                        try
                            switch(computer)
                            case 'PCWIN64',
                                iniFileName=fullfile(getenv('CommonProgramFiles(x86)'),'Texas Instruments','ccs_compdb.ini');
                            otherwise,
                                iniFileName=fullfile(getenv('CommonProgramFiles'),'Texas Instruments','ccs_compdb.ini');
                            end
                            iniH=fopen(iniFileName,'r');
                            contents=(fread(iniH,'*char'))';
                            fclose(iniH);
                        catch ex
                            if(~isempty(iniH))
                                fclose(iniH);
                            end
                            rethrow(ex);
                        end


                        function regpat=formpattern()

                            stubkey=regexp(getccsstubname(),'(?<Pre>\w+\.\w+\.\d+\.)(?<Num>\w+)','names');
                            regpat=sprintf('(?<Id>\\[PlugIn_\\d*\\])\\s*DisplayName\\s*=(?<DisplayName>MATLAB IDE Link\\"%s)\\s*ProgLocation\\s*=(?<Location>([^\\r\\n])*)',stubkey.Num);
