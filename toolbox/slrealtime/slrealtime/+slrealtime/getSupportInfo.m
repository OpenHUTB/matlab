function[outstruct]=getSupportInfo(testmodel)


























    if nargin==1
        testmodel=convertStringsToChars(testmodel);
    else
        testmodel=[];
    end

    filename='slrealtimeinfo.txt';

    [fid,errMsg]=fopen(filename,'wt');


    if fid==-1
        error(message('slrealtime:utils:CantOpenFile',filename,errMsg));
    else
        fclose(fid);
    end

    try
        diary('slrealtimeinfo.txt');
        diary on
        fprintf(1,'\n---------- File created using the Simulink Real-Time support utility getSupportInfo ----------\n');


        fprintf(1,'\n %%%% ---------- General Information ----------\n');

        outstruct.date=string(datetime("now"));
        fprintf(1,'\n %%%% Current Time & Date: %s\n',outstruct.date);

        fprintf(1,'\n %%%% MATLAB version and list of installed toolboxes: \n');
        ver -support
        outstruct.ver=ver('-support');

        fprintf(1,'\n %%%% MATLAB path:  \n');
path
        outstruct.path=path;

        outstruct.matlabroot=matlabroot;
        fprintf(1,'\n %%%% Matlabroot: %s\n',outstruct.matlabroot);

        outstruct.pwd=pwd;
        fprintf(1,'\n %%%% Current working directory: %s\n',outstruct.pwd);

        fprintf(1,'\n %%%% Speedgoatlib: \n');
        try
            fprintf(1,evalc('sg.mw.getSupportInfoHost'),'\n');
            outstruct.speedgoatver=evalc('sg.mw.getSupportInfoHost');
        catch
            fprintf(1,'Speedgoatlibrary files are not installed\n');
        end






        [~,outstruct.hostname]=system('hostname');
        fprintf(1,'\n %%%% ---------- Host Information ----------\n');
        fprintf(1,'\nHostname: %s',outstruct.hostname);
        if strcmpi(computer('arch'),'win64')

            [~,outstruct.systemversion]=system('ver');
            outstruct.systemversion(1)=[];
            fprintf(1,'\n %%%% Windows Version:  \n%s',outstruct.systemversion);

            [~,ipconfiguration]=system('ipconfig /all');
            fprintf(1,'\n %%%%  IP Configuration: %s ',ipconfiguration);

            fprintf(1,'\n %%%% ---------- Antivirus Info: ----------\n');
            try
                [~,outstruct.antivirus]=system('WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName /Format:List');
                outstruct.antivirus=fliplr(deblank(fliplr(outstruct.antivirus)));
                fprintf(1,'\n%s\n',outstruct.antivirus);
            catch
                fprintf(1,'\nAntivirus information is not available\n');
            end
        elseif strcmpi(computer('arch'),'glnxa64')

            [~,outstruct.systemversion]=system('cat /proc/version');
            fprintf(1,'\n %%%% Linux Version:  \n%s',outstruct.systemversion);


            [~,ipconfiguration]=system('ifconfig');
            fprintf(1,'\n %%%%  IP Configuration: %s ',ipconfiguration);



            fprintf(1,'\nAntivirus information is not available\n');
        else


            fprintf(1,'Not Windows or Linux, not supported in Simulink Real-Time')
        end

        fprintf(1,'\n %%%% ---------- Matlab workspace variable Information ----------\n');
        evalin('base','whos');


        fprintf(1,'\n %%%% ---------- QNX Support Package location ----------\n');







        fullpathToSP=slrealtime.internal.getSupportPackageRoot;
        if~isempty(fullpathToSP)

            setenv('SLREALTIME_QNX_SP_ROOT',fullpathToSP);
        end

        qnxdir=getenv('SLREALTIME_QNX_SP_ROOT');
        if~isempty(qnxdir)
            outstruct.qnxbase=qnxdir;
            fprintf(1,'    QNX base directory: %s\n',qnxdir);
        else
            fprintf(1,'Unable to locate the QNX base directory.\n');
        end



        fprintf(1,'\n %%%%  ---------- Target Machine Network Connectivity:  ---------- \n');

        alltgts=slrealtime.Targets;
        fprintf(1,'\n  %%%% Simulink Real-Time Target Connections: \n');
        defaulttgt=alltgts.getDefaultTargetName;
        outstruct.defaultTarget=defaulttgt;
        fprintf(1,'\n----------\n');
        fprintf(1,'\n     Default Target is %s\n',defaulttgt);
        targets=alltgts.getTargetSettings;
        names=alltgts.getTargetNames;
        outstruct.target=[];
        for i=1:alltgts.getNumTargets
            fprintf(1,'\n----------\n');
            disp(targets(i));
            tgn=slrealtime(names{i});
            outstruct.target(i).name=names{i};
            if isempty(tgn.TargetSettings.address)
                fprintf(1,'Target: %s does not have an IP address assigned',names{i})
                continue;
            end
            if strcmpi(computer('arch'),'win64')


                [outstruct.target(i).pingstat,outstruct.target(i).systemTargetPing]=system(['ping -w 100 -n 2 ',tgn.TargetSettings.address]);
            elseif strcmpi(computer('arch'),'glnxa64')


                [outstruct.target(i).pingstat,outstruct.target(i).systemTargetPing]=system(['ping -W 1 -c 2 ',tgn.TargetSettings.address]);
            end
            disp(outstruct.target(i).systemTargetPing);
            timedout=contains(outstruct.target(i).systemTargetPing,'Request timed out');
            if((timedout~=0)||(outstruct.target(i).pingstat==1))
                fprintf(1,'Target ''%s'' not responding.\n',names{i});
                continue;
            end

            try
                fprintf(1,'\n %%%%  ---------- %s configuration information, generic info ---------- \n',names{i});

                [status,info,rootssh]=tgn.getTargetInfo;

                if status==0
                    disp(info);
                else

                    fprintf(1,'Transfer of target generic information failed\n');
                    continue;
                end
            catch Err

                fprintf(1,'Error getting Target ''%s'' information, error: %s\n',names{i},Err.message);
                continue;
            end









            try
                [iok,qok,sok,sgok]=tgn.checkVersion;
                if iok&&qok&&sok&&sgok


                    fprintf(1,'\n %%%%  ---------- %s configuration information, Speedgoat info ---------- \n',names{i});

                    sg.mw.getSupportInfoTarget('TargetObject',tgn);
                else
                    fprintf(1,'\nSoftware version mismatch on target.\n');
                    fprintf(1,'image %d, qnx %d, slrt %d, sg %d\n\n',iok,qok,sok,sgok);

                    sg.mw.getSupportInfoTarget('SshObject',rootssh);
                end
            catch
                fprintf(1,'Speedgoat support information not available.\n');
            end

        end



        if~isempty(testmodel)
            fprintf(1,'\n %%%% ---------- Get information about the specified model and try compiling ---------- \n');
            try
                open_system(testmodel);
                hCs=getActiveConfigSet(testmodel);
                hCs.saveAs([testmodel,'_configset.m']);
                close_system(testmodel);
            catch
                warning('Configuration set cannot be generated')
            end


            if~isempty(qnxdir)
                open_system(testmodel);
                if strcmp(get_param(testmodel,'SystemTargetFile'),'slrealtime.tlc')
                    fprintf(1,'\n\nBuild model %s to check if the compiler is configured correctly.\n',testmodel);
                    rtwbuild(testmodel)
                else
                    fprintf(1,'\nModel %s is not configured for slrealtime, so it will not be built\n',testmodel);
                end
            else
                fprintf(1,'\nWe did not find the QNX tool directory so the specified model will not be built\n');
            end
        end

        fprintf(1,'\n %%%% ----------End test---------- \n');

        fprintf(1,'\nThis information has been saved in the text file %s in the current directory.',filename);
        if~isempty(testmodel)
            fprintf('\nThe configuration set for %s is in the file %s\n',testmodel,[testmodel,'_configset.m']);
        end
        fprintf(1,'\nPlease attach this text file to the Service Request you create at:''https://www.mathworks.com/support''\n\n');
        fprintf(1,'Note: slrrealtimetinfo.txt may contain sensitive information. Please review');
        fprintf(1,'\nbefore sending to MathWorks.\n');
        diary off;
        outstruct=orderfields(outstruct);

    catch err
        diary off;
    end
end










