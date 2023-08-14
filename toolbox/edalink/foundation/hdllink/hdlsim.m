function hdlsim(varargin)

















































































    pv=struct(...
    'rundir','',...
    'hdlsimdir','',...
    'libdir','',...
    'libfile','',...
    'tclstart','',...
    'startupfile','compile_and_launch.tcl',...
    'socketsimulink','',...
    'socketmatlabsysobj','',...
    'starthdlsim',true,...
    'startgui',true,...
    'linkproduct','',...
    'runmode','GUI',...
    'hdlsimexe',''...
    );

    pv=l_ParseArgs(pv,varargin);

    [arch,lfxarch,soext]=l_GetArchInfo;


    savedPath=getenv('PATH');
    savedLdLibraryPath=getenv('LD_LIBRARY_PATH');


    restorePathObj=onCleanup(@()setenv('PATH',savedPath));
    restoreLdPathObj=onCleanup(@()setenv('LD_LIBRARY_PATH',savedLdLibraryPath));

    if~isempty(pv.hdlsimdir)
        setenv('PATH',[pv.hdlsimdir,pathsep,getenv('PATH')]);
    end




    switch(pv.linkproduct)
    case 'Xcelium'
        libInfo=l_GetIncisiveLibInfo;
    case 'ModelSim'

        if isunix
            mtiVcoMode=getenv('MTI_VCO_MODE');
            cleanupObjMTIVCOMode=onCleanup(@()setenv('MTI_VCO_MODE',mtiVcoMode));
            setenv('MTI_VCO_MODE','64');
        end
        libInfo=l_GetModelSimLibInfo;

    otherwise

    end




    if(isempty(pv.libdir)),libInfo.dir=strrep(libInfo.dir,'\','/');
    else libInfo.dir=pv.libdir;%#ok<*SEPEX> 
    end

    if(~isempty(pv.libfile))
        if(strcmp(pv.linkproduct,'Xcelium'))
            libInfo.server=pv.libfile;
            libInfo.client=pv.libfile;
        else
            libInfo.server=[pv.libfile,'.',soext];
            libInfo.client=[pv.libfile,'.',soext];
        end
    end



    usingTMWGCC=any(contains({libInfo.server,libInfo.client},{'tmwgcc','tmwvs'}));
    if usingTMWGCC
        switch pv.linkproduct
        case 'ModelSim',libInfo.letMtiPrependLdPath=false;
        case 'Xcelium',libInfo.ldPreload=fullfile(matlabroot,'sys','os','glnxa64','libstdc++.so.6');
        end
    else
        libInfo.letMtiPrependLdPath=true;
        libInfo.ldPreload='';
    end





    switch(pv.linkproduct)
    case 'Xcelium',tclInfo=l_GetIncisiveTclInfo(libInfo);
    case 'ModelSim',tclInfo=l_GetModelSimTclInfo(libInfo);
    otherwise

    end


    if(iscell(pv.tclstart)),pv.tclstart=sprintf('%s\n',pv.tclstart{:});end


    switch(pv.linkproduct)
    case 'Xcelium'
        pv.hdlsimexe=[pv.hdlsimexe,' $runopt'];
        if(~strcmp(pv.runmode,'Batch'))
            pv.hdlsimexe=regexprep(pv.hdlsimexe,'exec','exec <@stdin >@stdout ');
        end
    otherwise

    end

    if(isempty(pv.tclstart)&&strcmp(pv.linkproduct,'Xcelium'))
        error(message('HDLLink:HDLSimScript:TCLStartNeeded'));
    end


    simtclcmd=l_GenSimTclCmd(tclInfo);
    matsotclcmd=l_GenMatSOTclCmd(tclInfo);
    mattclcmd=l_GenMatTclCmd(tclInfo);
    wraptclcmd=l_GenWrapTclCmd;




    if(isempty(pv.rundir))
        cdcmd=[];
    elseif(strcmp(pv.rundir,'TEMPDIR'))
        newdir=tempname;
        s=mkdir(newdir);
        if~s
            error(message('HDLLink:HDLSimScript:MKDIR',newdir));
        end
        pv.rundir=newdir;
    else
        if~exist(pv.rundir,'dir')
            error(message('HDLLink:HDLSimScript:DirNotFound',pv.rundir));
        end
    end
    if(isunix&&~isempty(pv.rundir))
        cdcmd=['cd "',pv.rundir,'" ; '];
    elseif(ispc&&~isempty(pv.rundir))
        driveLetter=regexp(pv.rundir,'^([A-Za-z]{1}:)','tokens');
        if(~isempty(driveLetter))
            cdToDrive=[' && ',driveLetter{:}];
        else
            cdToDrive={''};
        end
        cdcmd=['cd ',pv.rundir,cdToDrive{:},' && '];
    end


    assert(isempty(regexp(pv.startupfile,'\s','once')),...
    message('HDLLink:HDLSimScript:InvalidStartupFile',pv.startupfile));






    if~isempty(pv.rundir)||~strcmp(pv.startupfile,'compile_and_launch.tcl')
        pv.startupfile=l_AdjustFileName(pv.startupfile,pv.rundir,'compile_and_launch.tcl');
    end


    fidcmd=fopen(pv.startupfile,'w');
    if fidcmd==-1
        error(message('HDLLink:HDLSimScript:StartupFileOpen',pv.startupfile));
    end
    switch(pv.linkproduct)
    case 'Xcelium',fprintf(fidcmd,'%s\n%s\n%s\n',simtclcmd,mattclcmd,matsotclcmd);
    case 'ModelSim',fprintf(fidcmd,'%s\n%s\n%s\n',simtclcmd,mattclcmd,wraptclcmd,matsotclcmd);
    end
    fprintf(fidcmd,'%s\n',pv.tclstart);

    fclose(fidcmd);






    if(pv.starthdlsim)
        switch(pv.linkproduct)
        case 'Xcelium'
            launcherInfo=l_GetIncisiveLauncherInfo;
            launchMcmd='nclaunch';
        case 'ModelSim'
            launcherInfo=l_GetModelSimLauncherInfo;
            launchMcmd='vsim';
        end

        switch(computer)
        case 'GLNXA64'
            checkhdlsimcmd=['which ',launcherInfo.launcher];
            [stat,result]=system(checkhdlsimcmd);
            if stat~=0
                disp(['Failed to find ',launcherInfo.launcher,'!']);
                disp(['If ',launcherInfo.launcher,' is not on the system path, ']);
                disp(' please use parameter ''hdlsimdir'' to specify its location');
                error(message('HDLLink:HDLSimScript:LauncherNotFound',result));
            else
                if(strcmp(pv.runmode,'Batch'))
                    disp('The HDL simulator has been started in the background. When linking with');
                    disp('MATLAB, the HDL simulator starts the simulation automatically when the');
                    disp(['''run'' command is provided with the ''tclstart'' property of the ',launchMcmd,' command.']);
                    disp('When linking with Simulink, the HDL simulator is blocked after startup by');
                    disp(['the ',tclInfo.sltclcmdname,' command. It is unblocked by starting the cosimulation from']);
                    disp('Simulink. To unblock and exit the HDL simulator without initiating a');
                    disp('cosimulation session, use the breakHdlSim command in MATLAB.');
                    disp('When linking with MATLAB System Object, the HDL simulator is blocked after startup by');
                    disp(['the ',tclInfo.mlsotclcmdname,' command. It is unblocked by starting the cosimulation from']);
                    disp('MATLAB. To unblock and exit the HDL simulator without initiating a');
                    disp('cosimulation session, use the breakHdlSim command in MATLAB.');
                    disp(' ');
                end
            end
            hdlsimcmd=[cdcmd,' ',launcherInfo.hdlsimcmd];

            [stat,result]=system(hdlsimcmd);
            if stat~=0
                disp(['Launcher "',launcherInfo.launcher,'" failed with non-zero status!']);
                error(message('HDLLink:HDLSimScript:LauncherFailed',result));
            end
        case{'PCWIN','PCWIN64'}

            hdlsimcmd_vsim=[cdcmd,' ',launcherInfo.hdlsimcmd_vsim];
            hdlsimcmd_modelsim=[cdcmd,' ',launcherInfo.hdlsimcmd_modelsim];
            hdlsimcmd_questasim=[cdcmd,' ',launcherInfo.hdlsimcmd_questasim];

            switch(pv.runmode)
            case{'Batch','CLI'}
                [stat,result]=system(hdlsimcmd_vsim);
                if~isempty(result)
                    disp(['Launcher "',hdlsimcmd_vsim,'" failed with non-zero status! ']);
                    disp('If the problem is that it is not on the system path, ');
                    disp('please use parameter ''hdlsimdir'' to specify its location');
                    error(message('HDLLink:HDLSimScript:LauncherFailed',result));
                end
            otherwise
                [stat,result]=system(hdlsimcmd_modelsim);
                if~isempty(result)
                    [stat,result]=system(hdlsimcmd_questasim);
                    if(~isempty(result))
                        disp(['Both launcher "',hdlsimcmd_modelsim,'" and "',hdlsimcmd_questasim,'" failed with non-zero status! ']);
                        disp('If the problem is that it is not on the system path, ');
                        disp('please use parameter ''hdlsimdir'' to specify its location');
                        error(message('HDLLink:HDLSimScript:LauncherFailed',result));
                    end
                end
            end
        otherwise
            error(message('HDLLink:HDLSimScript:NonSupportedPlatformByProduct'));
        end
    end








    function pv=l_ParseArgs(defaultPv,inArgs)

        if(mod(length(inArgs),2)~=0)
            error(message('HDLLink:HDLSimScript:MissingArgument',char(fieldnames(defaultPv))));
        end

        pv=defaultPv;
        for ix=1:2:length(inArgs)
            p=inArgs{ix};
            v=inArgs{ix+1};
            if(isfield(defaultPv,p))
                pv.(p)=v;
            else
                fn=fieldnames(defaultPv);
                error(message('HDLLink:HDLSimScript:BadParameter',p,sprintf('%s ',fn{:})));
            end
        end


        fnames=fieldnames(pv);
        for findex=1:length(fnames)
            fname=fnames{findex};
            fval=pv.(fname);
            badValType=false;
            if(~ischar(fval))
                switch(fname)
                case 'socketsimulink'
                    if(isnumeric(fval)),pv.(fname)=num2str(fval);
                    else badValType=true;
                    end
                case 'socketmatlabsysobj'
                    if(isnumeric(fval)),pv.(fname)=num2str(fval);
                    else badValType=true;
                    end
                case 'tclstart'
                    if(~iscell(fval)),badValType=true;
                    end
                case{'starthdlsim','startgui'}
                    if(~islogical(fval)),badValType=true;
                    end
                otherwise
                    if(~isempty(fval))
                        badValType=true;
                    end
                end
            else
                switch(fname)
                case{'starthdlsim','startgui'}
                    if strcmp(fval,'yes'),pv.(fname)=true;
                    elseif strcmp(fval,'no'),pv.(fname)=false;
                    else
                        error(message('HDLLink:HDLSimScript:InvalidStartHDLsim',fname));
                    end
                case 'runmode'
                    switch(pv.linkproduct)
                    case 'ModelSim',validModes={'Batch','CLI','GUI'};
                    case 'Xcelium',validModes={'Batch','Batch with Xterm','CLI','GUI'};
                    end
                    if(~any(strcmp(fval,validModes)))
                        validModesStr=sprintf('''%s'' ',validModes{:});
                        error(message('HDLLink:HDLSimScript:InvalidRunMode',fval,validModesStr));
                    end
                otherwise

                end
            end
            if(badValType)
                error(message('HDLLink:HDLSimScript:BadValType',fname));
            end
        end

    end


    function[arch,lfxarch,soext]=l_GetArchInfo


        if strcmp(computer,'GLNXA64')
            arch='glnxa64';
            lfxarch='linux64';
            soext='so';
        elseif strcmp(computer,'PCWIN')
            if(strcmp(pv.linkproduct,'Xcelium'))
                arch='NOT SUPPORTED';
            else
                arch='win32';
                lfxarch='windows32';
                soext='dll';
            end
        elseif strcmp(computer,'PCWIN64')
            if(strcmp(pv.linkproduct,'Xcelium'))
                arch='NOT SUPPORTED';
            else
                arch='win64';
                lfxarch='windows64';
                soext='dll';
            end
        else
            arch='NOT SUPPORTED';
        end
        if(strcmp(arch,'NOT SUPPORTED'))
            error(message('HDLLink:HDLSimScript:NonSupportedPlatformBySimulator'));
        end

    end


    function libInfo=l_GetIncisiveLibInfo

        lfiLibArch='linux64';

        if(ispc)
            error(message('HDLLink:HDLSimScript:NonSupportedPlatform',seeRequirementPage));
        end




        if(pv.starthdlsim)




            setenv('LD_LIBRARY_PATH',...
            ['/hub/share/apps/HDLTools/IUS:',getenv('LD_LIBRARY_PATH')]);


            [stat,xmroot]=system('xmroot');
            if(stat)
                error(message('HDLLink:HDLSimScript:XmrootNotFound'));
            end



            [stat,fullver]=system('xmsim -64bit -ver');

            if(stat)
                error(message('HDLLink:HDLSimScript:XceliumVersionNotFound',fullver));
            else
                [iusVer,iusBits]=l_ParseNcsimVer(fullver);
            end

            if(isempty(iusVer)||length(iusVer)<4)
                warning(message('HDLLink:HDLSimScript:XceliumUnknownVer',fullver,seeRequirementPage));
            else

                switch(iusVer(1:4))
                case{'21.0'}
                otherwise
                    warning(message('HDLLink:HDLSimScript:XceliumUnsupportedVersion',iusVer,seeRequirementPage));
                end
            end



            if(isempty(iusBits))
                [stat,result]=system('xmbits');
                if(stat)
                    error(message('HDLLink:HDLSimScript:XmbitsNotFound'));
                end
                iusBits=regexp(result,'(^64$|^32$)?','match','once','lineanchors');
                if(isempty(iusBits))
                    error(message('HDLLink:HDLSimScript:XceliumModeNotFound',result));
                end
            end

            if(strcmp(iusBits,'32'))
                error(message('HDLLink:HDLSimScript:NotSupportedXcelium32'));
            end


            [iusBaseDir,tclBinDir]=l_ParseXmroot(xmroot);
            if(isempty(tclBinDir))
                warning(message('HDLLink:HDLSimScript:TclPathNotFound'));
            else
                setenv('PATH',[tclBinDir,':',getenv('PATH')]);
            end
            if(isempty(iusBaseDir))
                warning(message('HDLLink:HDLSimScript:XceliumPathNotFound',xmroot));
            else
                setenv('LD_LIBRARY_PATH',...
                [iusBaseDir,'/tools/systemc/gcc/64bit/install/lib64:'...
                ,getenv('LD_LIBRARY_PATH')]);
            end
        end

        libInfo.dir=fullfile(matlabroot,'toolbox','edalink','extensions','incisive',lfiLibArch);


        gcctag='tmwgcc';

        libInfo.server=['liblfihdls_',gcctag,'.',soext];
        libInfo.client=['liblfihdlc_',gcctag,'.',soext];

    end


    function libInfo=l_GetModelSimLibInfo

        lfmLibArch=lfxarch;

        libInfo.use64BitSwitch=false;



        if(pv.starthdlsim)
            [s,fullver]=system('vsim -version');
            if(s)
                if isunix
                    error(message('HDLLink:HDLSimScript:ModelSim64BitVersionNotFound'));
                else
                    error(message('HDLLink:HDLSimScript:ModelSimVersionNotFound'));
                end
            end

            [lfmBits,lfmVer]=l_ParseVsimVersion(fullver);


            if strcmp(lfmBits,'64')&&strcmp(lfxarch,'windows32')
                lfmLibArch='windows64';

            elseif strcmp(lfmBits,'32')&&strcmp(lfxarch,'windows64')
                lfmLibArch='windows32';
            end


            if~any(strcmpi(lfmVer,{'2021.4'}))
                warning(message('HDLLink:HDLSimScript:UnsupportedModelSimVersion',lfmVer,seeRequirementPage));
            end



            libInfo.letMtiPrependLdPath=false;
            if str2double(lfmVer)<6.3

                libInfo.letMtiPrependLdPath=true;
            end

            if isunix&&strcmp(lfmBits,'32')
                if str2double(lfmVer)>=6.6
                    libInfo.use64BitSwitch=true;
                else
                    error(message('HDLLink:HDLSimScript:NotSupportedModelSim32'));
                end
            end

        end

        libInfo.dir=fullfile(matlabroot,'toolbox','edalink','extensions','modelsim',lfmLibArch);




        switch(lfmLibArch)
        case 'linux64'
            gcctag='tmwgcc';
        case 'windows32'
            gcctag='gcc421vc12';
        otherwise
            gcctag='tmwvs';
        end
        libInfo.server=['liblfmhdls_',gcctag,'.',soext];
        libInfo.client=['liblfmhdlc_',gcctag,'.',soext];

    end


    function tclInfo=l_GetIncisiveTclInfo(libInfo)

        if~isempty(libInfo.ldPreload)
            tclInfo.ldPreload=['set ::env(LD_PRELOAD) ',libInfo.ldPreload];
        else
            tclInfo.ldPreload='';
        end
        tclInfo.sltclcmdname='hdlsimulink';
        hdlserverbootstrap='simlinkserver';
        tclInfo.sllibarg=['-64bit -loadvpi \{',libInfo.dir,'/',libInfo.server,':',hdlserverbootstrap,'\}'];
        tclInfo.socketarg='+socket=';

        tclInfo.mlsotclcmdname='hdlsimmatlabsysobj';
        hdlserverbootstrap='matlabsysobjserver';
        tclInfo.mlsolibarg=['-64bit -loadvpi \{',libInfo.dir,'/',libInfo.server,':',hdlserverbootstrap,'\}'];
        tclInfo.socketarg='+socket=';

        tclInfo.mltclcmdname='hdlsimmatlab';
        hdlclientbootstrap='matlabclient';
        tclInfo.mllibarg=['-64bit -loadcfc \{',libInfo.dir,'/',libInfo.client,':',hdlclientbootstrap,'\}'];
        tclInfo.mlinput=' -input "{@proc nomatlabtb {args} {call nomatlabtb \$args}}"';
        tclInfo.mlinput=[tclInfo.mlinput,' -input "{@proc matlabtb {args} {call matlabtb \$args}}"'];
        tclInfo.mlinput=[tclInfo.mlinput,' -input "{@proc matlabcp {args} {call matlabcp \$args}}"'];
        tclInfo.mlinput=[tclInfo.mlinput,' -input "{@proc matlabtbeval {args} {call matlabtbeval \$args}}"'];
        tclInfo.mlinput=[tclInfo.mlinput,' -input "{@proc notifyMatlabServer {args} {call notifyMatlabServer \$args}}"'];
        tclInfo.libargclose='';

    end


    function tclInfo=l_GetModelSimTclInfo(libInfo)

        tclInfo.ldPreload='';

        tclInfo.sltclcmdname='vsimulink';
        hdlserverbootstrap='simlinkserver';
        tclInfo.sllibarg=['-foreign \{',hdlserverbootstrap,' \{',libInfo.dir,'/',libInfo.server,'\}'];
        tclInfo.socketarg=' \; -socket ';

        tclInfo.mlsotclcmdname='vsimmatlabsysobj';
        hdlserverbootstrap='matlabsysobjserver';
        tclInfo.mlsolibarg=['-foreign \{',hdlserverbootstrap,' \{',libInfo.dir,'/',libInfo.server,'\}'];
        tclInfo.socketarg=' \; -socket ';

        tclInfo.mltclcmdname='vsimmatlab';
        hdlclientbootstrap='matlabclient';
        tclInfo.mllibarg=['-foreign \{',hdlclientbootstrap,' \{',libInfo.dir,'/',libInfo.client,'\}'];
        tclInfo.mlinput='';

        tclInfo.libargclose='\}';

    end


    function simtclcmd=l_GenSimTclCmd(tclInfo)

        switch(pv.linkproduct)
        case 'Xcelium',tclbatchcmds=l_GenIncisiveSimBatchTclCmd;
        case 'ModelSim',tclbatchcmds=l_GenModelSimSimBatchTclCmd;
        end

        if(isempty(pv.socketsimulink))
            simtclcmd=['proc ',tclInfo.sltclcmdname,' {args} {',char(10),...
            tclInfo.ldPreload,char(10),...
            '  lappend sllibarg ',tclInfo.sllibarg,char(10),...
            '  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {',char(10),...
            '    set socket [lindex $args [expr {$idx + 1}]]',char(10),...
            '    set args [lreplace $args $idx [expr {$idx + 1}]]',char(10),...
            '    append socketarg "',tclInfo.socketarg,'" "$socket"',char(10),...
            '    lappend sllibarg $socketarg',char(10),...
            '  }',char(10),...
            tclbatchcmds{:},...
            '  lappend sllibarg ',tclInfo.libargclose,char(10),...
            '  set args [linsert $args 0 ',pv.hdlsimexe,']',char(10),...
            '  lappend args [join $sllibarg]',char(10),...
            '  uplevel 1 [join $args]',char(10),...
            '}',...
            ];%#ok<*CHARTEN> 


        else
            simtclcmd=['proc ',tclInfo.sltclcmdname,' {args} {',char(10),...
            tclInfo.ldPreload,char(10),...
            '  lappend sllibarg ',tclInfo.sllibarg,char(10),...
            '  set socket ',pv.socketsimulink,char(10),...
            '  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {',char(10),...
            '    set socket [lindex $args [expr {$idx + 1}]]',char(10),...
            '    set args [lreplace $args $idx [expr {$idx + 1}]]',char(10),...
            '  }',char(10),...
            tclbatchcmds{:},...
            '  append socketarg "',tclInfo.socketarg,'" "$socket"',char(10),...
            '  lappend sllibarg $socketarg',char(10),...
            '  lappend sllibarg ',tclInfo.libargclose,char(10),...
            '  set args [linsert $args 0 ',pv.hdlsimexe,']',char(10),...
            '  lappend args [join $sllibarg]',char(10),...
            '  uplevel 1 [join $args]',char(10),...
            '}',...
            ];
        end
    end


    function tclbatchcmds=l_GenIncisiveSimBatchTclCmd
        tclbatchcmds={['  set runmode "',pv.runmode,'"'],char(10),...
        '  if {$runmode == "Batch" || $runmode == "Batch with Xterm"} {',char(10),...
        '    lappend sllibarg " +batch"',char(10),...
        '    set runopt "-Batch -EXIT"',char(10),...
        '  } elseif {$runmode == "CLI"} {',char(10),...
        '    set runopt "-tcl"',char(10),...
        '  } else {',char(10),...
        '    set runopt "-gui"',char(10),...
        '  } ',char(10)};
    end

    function tclbatchcmds=l_GenModelSimSimBatchTclCmd
        tclbatchcmds={'  set runmode "',pv.runmode,'"',char(10),...
        '  if { $runmode == "Batch" || $runmode == "Batch with Xterm"} {',char(10),...
        '    lappend sllibarg " \; -batch"',char(10),...
        '  }',char(10)};
    end


    function matsotclcmd=l_GenMatSOTclCmd(tclInfo)

        switch(pv.linkproduct)
        case 'Xcelium',tclbatchcmds=l_GenIncisiveMatSOBatchTclCmd;
        case 'ModelSim',tclbatchcmds=l_GenModelSimMatSOBatchTclCmd;
        end

        if(isempty(pv.socketmatlabsysobj))
            matsotclcmd=['proc ',tclInfo.mlsotclcmdname,' {args} {',char(10),...
            tclInfo.ldPreload,char(10),...
            '  lappend sllibarg ',tclInfo.mlsolibarg,char(10),...
            '  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {',char(10),...
            '    set socket [lindex $args [expr {$idx + 1}]]',char(10),...
            '    set args [lreplace $args $idx [expr {$idx + 1}]]',char(10),...
            '    append socketarg "',tclInfo.socketarg,'" "$socket"',char(10),...
            '    lappend sllibarg $socketarg',char(10),...
            '  }',char(10),...
            tclbatchcmds{:},...
            '  lappend sllibarg ',tclInfo.libargclose,char(10),...
            '  set args [linsert $args 0 ',pv.hdlsimexe,']',char(10),...
            '  lappend args [join $sllibarg]',char(10),...
            '  uplevel 1 [join $args]',char(10),...
            '}',...
            ];


        else
            matsotclcmd=['proc ',tclInfo.mlsotclcmdname,' {args} {',char(10),...
            tclInfo.ldPreload,char(10),...
            '  lappend sllibarg ',tclInfo.mlsolibarg,char(10),...
            '  set socket ',pv.socketmatlabsysobj,char(10),...
            '  if {[catch {lsearch -exact $args -socket} idx]==0  && $idx >= 0} {',char(10),...
            '    set socket [lindex $args [expr {$idx + 1}]]',char(10),...
            '    set args [lreplace $args $idx [expr {$idx + 1}]]',char(10),...
            '  }',char(10),...
            tclbatchcmds{:},...
            '  append socketarg "',tclInfo.socketarg,'" "$socket"',char(10),...
            '  lappend sllibarg $socketarg',char(10),...
            '  lappend sllibarg ',tclInfo.libargclose,char(10),...
            '  set args [linsert $args 0 ',pv.hdlsimexe,']',char(10),...
            '  lappend args [join $sllibarg]',char(10),...
            '  uplevel 1 [join $args]',char(10),...
            '}',...
            ];
        end
    end


    function tclbatchcmds=l_GenIncisiveMatSOBatchTclCmd
        tclbatchcmds={['  set runmode "',pv.runmode,'"'],char(10),...
        '  if {$runmode == "Batch" || $runmode == "Batch with Xterm"} {',char(10),...
        '    lappend sllibarg " +batch"',char(10),...
        '    set runopt "-Batch -EXIT"',char(10),...
        '  } elseif {$runmode == "CLI"} {',char(10),...
        '    set runopt "-tcl"',char(10),...
        '  } else {',char(10),...
        '    set runopt "-gui"',char(10),...
        '  } ',char(10)};
    end

    function tclbatchcmds=l_GenModelSimMatSOBatchTclCmd
        tclbatchcmds={'  set runmode "',pv.runmode,'"',char(10),...
        '  if { $runmode == "Batch" || $runmode == "Batch with Xterm"} {',char(10),...
        '    lappend sllibarg " \; -batch"',char(10),...
        '  }',char(10)};
    end


    function mattclcmd=l_GenMatTclCmd(tclInfo)


        switch(pv.linkproduct)
        case 'Xcelium',tclbatchcmds=l_GenIncisiveMatBatchTclCmd;
        case 'ModelSim',tclbatchcmds=l_GenModelSimMatBatchTclCmd;
        end



        mattclcmd=['proc ',tclInfo.mltclcmdname,' {args} {',char(10),...
        tclInfo.ldPreload,char(10),...
        '  lappend mllibarg ',tclInfo.mllibarg,char(10),...
        '  lappend mllibarg ',tclInfo.libargclose,char(10),...
        '  lappend mlinput ',tclInfo.mlinput,char(10),...
        '  lappend mlinput [join $args]',char(10),...
        '  lappend mlinput [join $mllibarg]',char(10),...
        tclbatchcmds{:},...
        '  set mlinput [linsert $mlinput 0 ',pv.hdlsimexe,']',char(10),...
        '  uplevel 1 [join $mlinput]',char(10),...
        '}',...
        ];
    end



    function batchcmds=l_GenIncisiveMatBatchTclCmd
        batchcmds={['  set runmode "',pv.runmode,'"'],char(10),...
        '  if {$runmode == "Batch" || $runmode == "Batch with Xterm"} {',char(10),...
        '    set runopt "-Batch -EXIT"',char(10),...
        '  } elseif {$runmode == "CLI"} {',char(10),...
        '    set runopt "-tcl"',char(10),...
        '  } else {',char(10),...
        '    set runopt "-gui"',char(10),...
        '  } ',char(10)};
    end



    function batchcmds=l_GenModelSimMatBatchTclCmd
        batchcmds={' '};
    end


    function wraptclcmd=l_GenWrapTclCmd

        wraptclcmd=['proc wrapverilog {args} {',char(10),...
        char(10),...
        '  error "wrapverilog has been removed. HDL Verifier now supports Verilog models directly, without requiring a VHDL wrapper."',...
        '}',char(10)...
        ];
    end


    function gencdslib_tclcmd=l_GenCdsLibTclCmd %#ok

        gencdslib_tclcmd=['proc gencdslib {args} {',char(10),...
        '  set fname "cds.lib"',char(10),...
        '  set currdir [pwd]',char(10),...
        '  set fid [open $fname w]',char(10),...
        char(10),...
        '  if {$fid == -1} {',char(10),...
        '      error "** Error: (gencdslib) Cannot open file $fname"',char(10),...
        '  }',char(10),...
        char(10),...
        '  puts $fid "------- auto-generated cds.lib --------------------------------------"',char(10),...
        '  puts $fid "define worklib $currdir/INCA_libs/worklib"',char(10),...
        '  puts $fid "include \$CDS_INST_DIR/tools/inca/files/cds.lib"',char(10),...
        '  close $fid',char(10),...
        char(10),...
        '}',char(10)...
        ];
    end


    function genhdlvar_tclcmd=l_GenHdlVarTclCmd %#ok
        genhdlvar_tclcmd=['proc genhdlvar {args} {',char(10),...
        '  set fname "hdl.var"',char(10),...
        '  set fid [open $fname w]',char(10),...
        char(10),...
        '  if {$fid == -1} {',char(10),...
        '      error "** Error: (genhdlvar) Cannot open file $fname"',char(10),...
        '  }',char(10),...
        char(10),...
        '  puts $fid "------- auto-generated hdl.var --------------------------------------"',char(10),...
        '  puts $fid "define WORK worklib"',char(10),...
        '  puts $fid "include \$CDS_INST_DIR/tools/inca/files/hdl.var"',char(10),...
        '  close $fid',char(10),...
        char(10),...
        '}',char(10)...
        ];
    end


    function fixldpath_tclcmd=l_GenFixLdPathTclCmd %#ok


        fixldpath_tclcmd=['proc fixldpath {args} {',char(10),...
        '  set pvpair [split [join $args]]',char(10),...
        '  set pval   [lindex $pvpair 1]',char(10),...
        '  append newpval ',matlabroot,'/sys/os/',arch,' ":" $pval',char(10),...
        '  append setcmd { array set env [list LD_LIBRARY_PATH } " " $newpval " " ]',char(10),...
        '  uplevel 1 $setcmd',char(10),...
        '}',char(10)...
        ];
    end


    function launcherInfo=l_GetIncisiveLauncherInfo
        if(ispc)
            error(message('HDLLink:HDLSimScript:NonSupportedPlatformByXcelium'));
        end
        launcherInfo.launcher='tclsh';

        switch(pv.runmode)
        case 'GUI'
            execShell='xterm -e bash -e -c '' (echo Executing nclaunch tclstart commands... && tclsh ';
            cmdEnd=') || (echo ERROR  hit any key to exit xterm; read anykey;)''';
        case 'Batch'
            execShell=' tclsh ';
            cmdEnd='';
        case 'Batch with Xterm'
            execShell='xterm -e bash -e -c '' (echo executing nclaunch in batch mode. && tclsh ';
            cmdEnd=')''';
        case 'CLI'
            execShell='xterm -e bash -e -c '' tclsh ';
            cmdEnd='''';
        otherwise
            execShell='xterm -e bash -e -c '' (echo Executing nclaunch tclstart commands... && tclsh ';
            cmdEnd=') || (echo ERROR  hit any key to exit xterm; read anykey;)''';
        end
        launcherInfo.hdlsimcmd=[execShell,pv.startupfile,cmdEnd,' & '];
    end



    function launcherInfo=l_GetModelSimLauncherInfo
        if(libInfo.letMtiPrependLdPath)
            ldlibArg='';
        else
            ldlibArg='-noautoldlibpath';
        end
        if(ispc)

            pv.startupfile=strrep(pv.startupfile,'\','/');




            switch(pv.runmode)
            case{'Batch','CLI'}
                execShell='start ';
                launcher_args=[ldlibArg,' -c -do "do {',pv.startupfile,'}"'];
            otherwise
                execShell='';





                assert(isempty(regexp(pv.startupfile,'\s','once')),...
                message('HDLLink:HDLSimScript:InvalidFilePath',pv.startupfile));
                launcher_args=[' -do ',pv.startupfile];
            end
            switch(pv.runmode)
            case 'Batch'

                batfile=l_AdjustFileName('tmw_esl_vsim_launch.bat',pv.rundir,'tmw_esl_vsim_launch.bat');
                fidbat=fopen(batfile,'w');
                fprintf(fidbat,'vsim < "%s"\n',pv.startupfile);
                fprintf(fidbat,'exit\n');
                if isempty(pv.rundir)
                    launcherInfo.hdlsimcmd_vsim='start tmw_esl_vsim_launch.bat';
                else
                    abspath=regexprep(batfile,'tmw_esl_vsim_launch.bat$','');
                    launcherInfo.hdlsimcmd_vsim=['start /D"',abspath,'" tmw_esl_vsim_launch.bat'];
                end
                fclose(fidbat);
            otherwise
                launcherInfo.hdlsimcmd_vsim=[execShell,'vsim ',launcher_args];
            end
            launcherInfo.hdlsimcmd_modelsim=[execShell,'modelsim ',launcher_args];
            launcherInfo.hdlsimcmd_questasim=[execShell,'questasim ',launcher_args];
        else
            launcherInfo.launcher='vsim';
            switch(pv.runmode)
            case{'GUI'}
                modeArg='-gui';
                execShell='';
                cmdEnd='';
            case 'Batch'
                modeArg='-c';
                execShell='';
                cmdEnd='';
            case 'CLI'
                modeArg='-c';
                execShell='xterm -e bash -e -c ''';
                cmdEnd='''';
            case{'Batch with Xterm'}
                error(message('HDLLink:HDLSimScript:UnsupportedRunMode'));
            otherwise
                modeArg='-gui';
                execShell='';
                cmdEnd='';
            end


            if libInfo.use64BitSwitch

                bitMode=' -64';
            else
                bitMode='';
            end

            switch(pv.runmode)
            case 'Batch'
                launcherInfo.hdlsimcmd=...
                [execShell,' ',launcherInfo.launcher,' ',ldlibArg,' ',bitMode,' <"',pv.startupfile,'" ',' ',cmdEnd,' & '];
            otherwise
                launcherInfo.hdlsimcmd=...
                [execShell,' ',launcherInfo.launcher,' ',ldlibArg,' ',bitMode,' ',modeArg,' -do ',pv.startupfile,' ',cmdEnd,' & '];
            end
        end
    end


    function newName=l_AdjustFileName(oldName,rundir,defaultName)


        if(strcmpi(oldName,defaultName))
            if(isempty(rundir)),scriptbasedir=pwd;
            else scriptbasedir=rundir;
            end
            newName=[scriptbasedir,filesep,oldName];
        else
            newName=oldName;
        end



        pathpart=fileparts(newName);
        if(ispc)
            abspath=regexp(pathpart,'^[A-Za-z]{1}:|^\\\\');
        else
            abspath=regexp(pathpart,'^/','once');
        end
        if(isempty(abspath))
            newName=[pwd,filesep,newName];
        end
    end

end




function[iusVer,iusBits]=l_ParseNcsimVer(fullver)


    expr_tool='TOOL:\s{1,}';
    expr_ncsim='(xmsim)(\(64\))?\s{1,}';
    expr_majorver='\d{1,3}';
    expr_minorver='\.\d{1,2}';
    expr_rem='-[\w]{1,5}';


    pattern=['(?<=',expr_tool,expr_ncsim,')',expr_majorver,expr_minorver,expr_rem];
    iusVer=regexpi(fullver,pattern,'match','once');



    if(~isempty(iusVer))
        if(isempty(regexpi(fullver,'[xmsim]\(64\)','once')))
            iusBits='32';
        else
            iusBits='64';
        end
    else
        iusBits=[];
        iusVer='';
    end
end




function[iusBaseDir,tclBinDir]=l_ParseXmroot(xmroot)


    iusBaseDir=[];
    tclBinDir=[];

    matchedpaths=regexp(xmroot,'.+','match','dotexceptnewline');

    if(~isempty(matchedpaths))
        for m=1:numel(matchedpaths)
            tmpIusBaseDir=deblank(matchedpaths{m});
            tmpTclBinDir=[tmpIusBaseDir,'/tools/tcltk/tcl/bin'];

            if(exist(tmpIusBaseDir,'dir')==7)
                iusBaseDir=tmpIusBaseDir;
                if(exist(tmpTclBinDir,'dir')==7)
                    tclBinDir=tmpTclBinDir;
                end
                break;
            end
        end
    end
end



function[lfmBits,lfmVer]=l_ParseVsimVersion(fullver)











    if(strfind(fullver,'ModelSim ALTERA '))
        warning(message('HDLLink:HDLSimScript:UnsupportedModelSimAE'));
    elseif(strfind(fullver,'ModelSim XE '))
        warning(message('HDLLink:HDLSimScript:UnsupportedModelSimXE'));
    end


    expr_modelsim='(ModelSim\s+((\w*\s+)*)?\w*|Questa\s+Sim)';
    expr_bits='(?<bits>(-64)?)';
    expr_vsim='\s+vsim\s+';
    expr_ver='(?<ver>[0-9\.]{3,6})[a-zA-Z]?';


    pattern=[expr_modelsim,expr_bits,expr_vsim,expr_ver];
    vsimver=regexp(fullver,pattern,'names','once');

    if(isempty(vsimver))

        lfmVer='';
        if(~ispc)

            lfmBits=getenv('MTI_VCO_MODE');
            switch lfmBits
            case{'32','64'}
            otherwise
                error(message('HDLLink:HDLSimScript:ModelSimModeNotFound',fullver));
            end
        else


            warning(message('HDLLink:HDLSimScript:ModelSimModeNotFoundPC',fullver));
            lfmBits='32';
            return;
        end
    else
        if(isempty(vsimver.bits))
            lfmBits='32';
        else
            lfmBits='64';
        end
        if(~isempty(vsimver.ver))
            lfmVer=vsimver.ver;
        else
            lfmVer='';
        end
    end
end

function reqmsg=seeRequirementPage
    link='helpview(fullfile(docroot, ''toolbox'', ''hdlverifier'', ''helptargets.map''), ''ThirdPartyReqs'');';
    reqmsg=['See <a href="matlab:',link,'">product requirements</a>.'];
end













