



classdef CosimWizardDataIN<CosimWizardPkg.CosimWizardData
    properties(Constant)
        WorkflowOptions={'Simulink','MATLAB','MATLAB System Object'};
        DefaultLoadOptions=' -64bit ';
        DefaultElabOptions=' -64bit -access +wc ';
        Simulator='Xcelium';
        FileTypes={'Verilog','VHDL','Shell script','Unknown'};
        delimiter='.';
        compilationScriptFile='hdlverifier_incisive_compile.sh';
    end
    methods
        function this=CosimWizardDataIN
            this.LoadOptions=this.DefaultLoadOptions;
        end


        function cmd=getMlCompileCommand(obj)
            cmd=sprintf(['[s, r] = system([''sh "',obj.compilationScriptFile,'"''],''-echo'');\n']);
            cmd=[cmd,'if (s ~= 0)',char(10)];
            cmd=[cmd,'    error(message(''HDLLink:CosimWizard:CompilationError'',r));',char(10)];
            cmd=[cmd,'end',char(10)];
        end

        function genCompileCommand(obj)
            vhdlFiles='';
            vlogFiles='';
            shCmds='';
            [numFiles,~]=size(obj.HdlFiles);
            compileCmd='';
            FolderPathenv='';
            FilePaths=obj.HdlFiles(:,1);
            [FolderPaths,names,exts]=fileparts(FilePaths);
            if ischar(FolderPaths)


                FolderPaths={FolderPaths};
                names={names};
                exts={exts};
            end
            [uniquePath,~,ic]=unique(FolderPaths);
            FileNames=strcat(names,exts);
            for m=1:size(uniquePath)
                pathName=strrep(uniquePath{m},'\','/');
                FolderPathenv=[FolderPathenv,'SRC',num2str(m),'="',pathName,'"',char(10)];
            end
            compileCmd=[compileCmd,'#Define Source Folders',char(10)];
            for m=1:numFiles
                filename=['$SRC',num2str(ic(m)),'/',FileNames{m}];
                switch(obj.HdlFiles{m,2})
                case 0
                    vlogFiles=[vlogFiles,'"',filename,'" '];
                case 1
                    vhdlFiles=[vhdlFiles,'"',filename,'" '];
                case 2
                    shCmds=[shCmds,'sh "',filename,'"',char(10)];%#ok<AGROW>
                otherwise
                    error(message('HDLLink:CosimWizard:UnknownFileType'));
                end
            end

            compileCmd=[compileCmd,FolderPathenv,char(10)];
            compileCmd=[compileCmd,'#Compilation',char(10)];
            if~isempty(vlogFiles)
                if strcmp(exts,'.sv')
                    svFlag='-sv';
                else
                    svFlag='';
                end
                compileCmd=[compileCmd,'xmvlog -64bit ',svFlag,' ',vlogFiles,char(10)];
            end
            if~isempty(vhdlFiles)
                compileCmd=[compileCmd,'xmvhdl -64bit -v93 -smartlib ',vhdlFiles,char(10)];
            end

            compileCmd=[compileCmd,shCmds];

            obj.GeneratedCompileCmd=compileCmd;
        end

        function runCompilation(obj)
            if(~obj.UseSysPath)
                savedPath=getenv('PATH');

                restorePathObj=onCleanup(@()setenv('PATH',savedPath));

                setenv('PATH',[obj.HdlPath,pathsep,getenv('PATH')]);
            end

            fid=fopen(obj.compilationScriptFile,'w','n','utf-8');
            fwrite(fid,obj.CompileCmd,'char');
            fclose(fid);


            execCmd=getMlCompileCommand(obj);
            eval(execCmd);


            obj.ModulesFound={};
            [s,r]=system('xmls -64bit -module -verilog');
            if(~s)
                ModuleName=regexp(r,'(?<=(module\s+)\w+\.)\w+(?=:)','match');
                if(~isempty(ModuleName))
                    obj.ModulesFound=[obj.ModulesFound,ModuleName];
                end
            end
            [s,r]=system('xmls -64bit -entity -vhdl -no_std_ieee');
            if(~s)
                ModuleName=regexp(r,'(?<=(\s+entity\s+(\w+)\.))(?<!(NCINTERNAL|NCMODELS|XMINTERNAL|XMMODELS)\.)\w+(?=\s+)','match');
                if(~isempty(ModuleName))
                    obj.ModulesFound=[obj.ModulesFound,ModuleName];
                end
            end
            obj.ModulesFound=unique(obj.ModulesFound);
        end

        function launchHdl(obj,logFile)


            if(~obj.UseSysPath)
                savedPath=getenv('PATH');

                restorePathObj=onCleanup(@()setenv('PATH',savedPath));

                setenv('PATH',[obj.HdlPath,pathsep,getenv('PATH')]);
            end

            disp('### Elaborating HDL design');
            elabCmd=sprintf('xmelab %s %s',obj.ElabOptions,obj.TopLevelName);
            disp(['### Elaboration command: ',elabCmd]);
            [r,s]=system(elabCmd,'-echo');
            assert(r==0,sprintf('Elaboration failed with error message: %s',s));


            tclcmd=[sprintf('if { [catch {hdlsimulink -log xmsim.log %s %s -input "exit"} errmsg] } {',obj.LoadOptions,obj.TopLevelName),char(10)...
            ,sprintf('    set fid [ open %s w];',logFile),char(10),...
            '    puts $fid "Loading simulation and HDL Verifier library failed.";',char(10),...
            '    puts $fid $errmsg;',char(10)...
            ,'    close $fid;',char(10)...
            ,'}'];

            params={'tclstart',tclcmd,...
            'runmode','Batch with Xterm'};
            if(obj.useSocket)

                obj.SocketPort=getAvailableSocketPort;
                params=[params,{'socketsimulink',obj.SocketPort}];
            end

            if(~obj.UseSysPath)
                params=[params,{'hdlsimdir',obj.HdlPath}];
            end
            nclaunch(params{:});
        end
        function driverCmds=genPreSimTclCmd(obj)
            hdlTimeUnit=getHdlTimeUnitName(obj);

            numClk=numel(obj.ClkList);
            numRst=numel(obj.RstList);
            driverCmds=cell(1,numClk+numRst);
            for m=1:numClk
                switch obj.ClkList{m}.Edge
                case 'Rising'
                    startvalue='0';
                    endvalue='1';
                case 'Falling'
                    startvalue='1';
                    endvalue='0';
                end
                onePeriod=obj.ClkList{m}.Period;
                halfPeriod=num2str(str2double(obj.ClkList{m}.Period)/2);

                if(obj.TopRegionKind==2)
                    clkName=[':',obj.ClkList{m}.Name];


                    driverCmds{m}=['force ',clkName,' B"',startvalue,'" -after 0',hdlTimeUnit...
                    ,' B"',endvalue,'" -after ',halfPeriod,hdlTimeUnit...
                    ,' -repeat ',onePeriod,hdlTimeUnit,';'];
                else
                    clkName=[obj.ModuleName,'.',obj.ClkList{m}.Name];
                    driverCmds{m}=['force ',clkName,' ',startvalue,' -after 0',hdlTimeUnit,' '...
                    ,endvalue,' -after ',halfPeriod,hdlTimeUnit...
                    ,' -repeat ',onePeriod,hdlTimeUnit,';'];
                end
            end
            for m=1:numRst
                rstIndx=m+numClk;

                durationStr=num2str(obj.RstList{m}.Duration);
                switch(obj.RstList{m}.Initial)
                case '0'
                    beginStr='0';
                    endStr='1';
                case '1'
                    beginStr='1';
                    endStr='0';
                end
                if(obj.TopRegionKind==2)
                    rstName=[':',obj.RstList{m}.Name];
                    driverCmds{rstIndx}=['force ',rstName,' B"',beginStr,'" -after 0',hdlTimeUnit...
                    ,' B"',endStr,'" -after ',durationStr,hdlTimeUnit,';'];
                else
                    rstName=[obj.ModuleName,'.',obj.RstList{m}.Name];
                    driverCmds{rstIndx}=['force ',rstName,' ',beginStr,' -after 0',hdlTimeUnit...
                    ,' ',endStr,' -after ',durationStr,hdlTimeUnit,';'];
                end

            end


            driverCmds=sprintf('%s\n',driverCmds{:});
        end

        function driverCmds=genPostSimTclCmd(~)
            driverCmds={'puts "done";'};
            driverCmds=sprintf('%s\n',driverCmds{:});
        end

        function genParameterConfigFile(obj)
            obj.parameterConfigFile=['parameter_',obj.ModuleName,'.cfg'];
            str2add=['-File ',obj.parameterConfigFile];



            if~contains(obj.ElabOptions,str2add)
                obj.parameterConfigFile=['parameter_',obj.ModuleName,'.cfg'];
                paraFile=fopen(obj.parameterConfigFile,'w');
                fprintf(paraFile,obj.defaultParameterConfigCommand);
                for m=1:length(obj.ParameterList)
                    switch(obj.ParameterList{m}.Type)
                    case "UnsupportedType"
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>','(N/A)','"\n'));
                    case "String"
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>\\"',num2str(obj.ParameterList{m}.defaultValue),'\\""\n'));
                    case "Double"
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>',num2str(obj.ParameterList{m}.defaultValue),'"\n'));
                    case{"Integer"}
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>',num2str(int32(obj.ParameterList{m}.defaultValue)),'"\n'));
                    case{"Logic"}
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>',num2str(obj.ParameterList{m}.defaultValue),'"\n'));
                    case{"Enum"}
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>\\"',num2str(obj.ParameterList{m}.defaultValue),'\\""\n'));

                    case "Time"
                        configCommand=char(strcat('#-gpg "',...
                        obj.ParameterList{m}.FullName,...
                        '=>',num2str(int64(obj.ParameterList{m}.defaultValue)),' fs"\n'));
                    end
                    fprintf(paraFile,configCommand);
                end
                fclose(paraFile);
                obj.ElabOptions=[obj.ElabOptions,' ',str2add];
            end
        end

        function scriptName=genSlLaunchScript(obj)
            if strcmpi(obj.Workflow,'Simulink')
                hdlsimcmd='hdlsimulink';
            else
                hdlsimcmd='hdlsimmatlabsysobj';
            end

            tclDefBegin='tclcmd = { ...';

            if(obj.TopRegionKind==2)
                topSymbol=':';
            else
                topSymbol=obj.ModuleName;
            end

            if obj.useSocket
                socketCmd=[' -socket ',num2str(obj.SocketPort),''', ...'];
            else
                socketCmd=''', ...';
            end


            loadCmd={
            ['''exec xmelab ',obj.ElabOptions,' ',obj.TopLevelName,''''],...
            ['[''',hdlsimcmd,' ',obj.TopLevelName,' ',obj.LoadOptions,socketCmd],...
            ''' -input "{@simvision {set w \[waveform new\]}}"'', ...',...
            [''' -input "{@simvision {waveform add -using \$w -signals ',topSymbol,'}}"'', ...'],...
            [''' -input "{@probe -create -shm ',topSymbol,'}"'',... '],...
            ''' -input "{@database -open waves -into waves.shm -default}"'',... ',...
            };
            tclDefEnd=']};';

            if(obj.UseSysPath)
                ncsimcmd='nclaunch(''tclstart'',tclcmd);';
            else
                ncsimcmd=['nclaunch(''tclstart'',tclcmd,''hdlsimdir'',''',obj.HdlPath,''')'];
            end

            Script=[{tclDefBegin},loadCmd,{tclDefEnd},{ncsimcmd}];
            scriptName=writeLaunchScript(obj,Script,false);
        end

        function scriptName=genMlLaunchScript(obj,LaunchHdl)
            if obj.useSocket
                startHdlDaemon='commInfo = hdldaemon(''socket'',0);';
                addSocketCmd=' -socket '' '' commInfo.ipc_id ''';
            else
                startHdlDaemon='commInfo = hdldaemon;';
                addSocketCmd='';
            end

            tclDefBegin='tclcmd = { ...';
            elabCmd={['''exec xmelab ',obj.ElabOptions,' ',obj.TopLevelName,''',...'],...
            ['[''hdlsimmatlab ',obj.TopLevelName,' ',obj.LoadOptions,''', ...']};

            callbackCmds=cell(1,numel(obj.MatlabCb));
            for m=1:numel(obj.MatlabCb)
                callbackCmds{m}=[''' -input "{@',obj.MatlabCb{m}.FullCmd,addSocketCmd,'''}"'', ...'];
            end

            tclDefEnd=']};';

            if(obj.UseSysPath)
                vsimcmd='nclaunch(''tclstart'',tclcmd);';
            else
                vsimcmd=['nclaunch(''tclstart'',tclcmd,''hdlsimdir'',''',obj.HdlPath,''')'];
            end

            Script=[{startHdlDaemon},{tclDefBegin},elabCmd,callbackCmds,{tclDefEnd},{vsimcmd}];
            scriptName=writeLaunchScript(obj,Script,LaunchHdl);
        end
    end
end






