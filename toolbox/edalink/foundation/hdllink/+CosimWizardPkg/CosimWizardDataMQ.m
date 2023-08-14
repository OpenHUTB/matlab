


classdef CosimWizardDataMQ<CosimWizardPkg.CosimWizardData
    properties(Constant)
        WorkflowOptions={'Simulink','MATLAB','MATLAB System Object'};
        DefaultLoadOptions='-t 1ns -voptargs=+acc ';
        DefaultElabOptions='';
        DoFileName='hdlverifier_compile_design.do';
        Simulator='ModelSim';
        FileTypes={'Verilog','VHDL','ModelSim macro file','Unknown'};
        delimiter='/';
    end

    methods
        function this=CosimWizardDataMQ
        end
        function genCompileCommand(obj)
            [numFiles,~]=size(obj.HdlFiles);
            compileCmd=['# Create design library',char(10)];
            compileCmd=[compileCmd,'vlib work',char(10)];
            compileCmd=[compileCmd,'# Create and open project',char(10)];
            compileCmd=[compileCmd,'project new . compile_project',char(10)];
            compileCmd=[compileCmd,'project open compile_project',char(10)];
            compileCmd=[compileCmd,'# Add source files to project',char(10)];

            sourceCmd='';
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
                compileCmd=[compileCmd,'set SRC',num2str(m),' "',pathName,'"',char(10)];
            end

            for m=1:numFiles
                filename=['$SRC',num2str(ic(m)),'/',FileNames{m}];
                switch(obj.HdlFiles{m,2})
                case{0,1}
                    compileCmd=[compileCmd,'project addfile "',filename,'"',char(10)];%#ok<AGROW>
                case 2
                    sourceCmd=[sourceCmd,'if [catch {do "',filename,'"}] {',char(10)];%#ok<AGROW>
                    sourceCmd=[sourceCmd,'    exit -code 1',char(10)];%#ok<AGROW>
                    sourceCmd=[sourceCmd,'}',char(10)];%#ok<AGROW>
                otherwise
                    error(message('HDLLink:CosimWizard:UnknownFileType'));
                end
            end
            compileCmd=[compileCmd,'# Calculate compilation order',char(10)];
            compileCmd=[compileCmd,'project calculateorder',char(10)];
            compileCmd=[compileCmd,'set compcmd [project compileall -n]',char(10)];
            compileCmd=[compileCmd,'# Close project',char(10)];
            compileCmd=[compileCmd,'project close',char(10)];
            compileCmd=[compileCmd,'# Compile all files and report error',char(10)];
            compileCmd=[compileCmd,'if [catch {eval $compcmd}] {',char(10)];
            compileCmd=[compileCmd,'    exit -code 1',char(10)];
            compileCmd=[compileCmd,'}',char(10)];

            obj.GeneratedCompileCmd=[compileCmd,sourceCmd];
        end

        function cmd=getMlCompileCommand(obj)
            cmd=sprintf('[s, r] = system([''vsim < %s''],''-echo'');\n',obj.DoFileName);
            cmd=[cmd,'if (s ~= 0)',char(10)];
            cmd=[cmd,'    error(message(''HDLLink:CosimWizard:CompilationError'',r));',char(10)];
            cmd=[cmd,'end',char(10)];
        end

        function runCompilation(obj)
            if(~obj.UseSysPath)
                savedPath=getenv('PATH');

                restorePathObj=onCleanup(@()setenv('PATH',savedPath));

                setenv('PATH',[obj.HdlPath,pathsep,getenv('PATH')]);
            end


            fid=fopen(obj.DoFileName,'w','n','utf-8');
            fwrite(fid,obj.CompileCmd,'char');
            fclose(fid);

            execCmd=getMlCompileCommand(obj);
            eval(execCmd);

            [isexist,vdirpath]=simplewhich(obj,'vsim');
            if isexist
                vdircmd=['"',fullfile(vdirpath,'vdir'),'" -lib work'];
            else
                vdircmd='vdir -lib work';
            end

            [s,r]=system(vdircmd);
            if s
                warning(message('HDLLink:CosimWizard:VdirFailureWarning',r));
                obj.ModulesFound={};
                return;
            end
            ModuleNames=regexp(r,'(?<=MODULE\s+)\w+','match');
            EntityNames=regexp(r,'(?<=ENTITY\s+)\w+','match');
            obj.ModulesFound=unique([ModuleNames,EntityNames]);
        end

        function launchHdl(obj,logFile)
            loadCmd=sprintf('vsimulink %s %s',obj.TopLevelName,obj.LoadOptions);
            errMsg='Loading simulation and HDL Verifier library failed.';


            tclcmd={sprintf('onElabError {echo "%s"; quit -f}',errMsg),...
            sprintf('transcript file "%s"',logFile),...
            sprintf(['if { [catch {%s } errmsg] } {\n'...
            ,'    echo "%s"; \n'...
            ,'    echo $errmsg; \n'...
            ,'    quit -f; \n'...
            ,'}'],loadCmd,errMsg)};

            params={'tclstart',tclcmd,...
            'runmode','Batch'};
            if(obj.useSocket)

                obj.SocketPort=getAvailableSocketPort;
                params=[params,{'socketsimulink',obj.SocketPort}];
            end

            if(~obj.UseSysPath)
                params=[params,{'vsimdir',obj.HdlPath}];
            end
            vsim(params{:});
        end
        function driverCmds=genPreSimTclCmd(obj)
            hdlTimeUnit=getHdlTimeUnitName(obj);
            if(strcmpi(hdlTimeUnit,'s'))
                hdlTimeUnit='sec';
            end

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
                clkName=['/',obj.ModuleName,'/',obj.ClkList{m}.Name];
                onePeriod=obj.ClkList{m}.Period;
                halfPeriod=num2str(str2double(obj.ClkList{m}.Period)/2);

                driverCmds{m}=['force ',clkName,' ',startvalue,' 0 ',hdlTimeUnit,', '...
                ,endvalue,' ',halfPeriod,' ',hdlTimeUnit...
                ,' -repeat ',onePeriod,' ',hdlTimeUnit,';'];
            end
            for m=1:numRst
                rstIndx=m+numClk;

                rstName=['/',obj.ModuleName,'/',obj.RstList{m}.Name];
                durationStr=num2str(obj.RstList{m}.Duration);
                switch(obj.RstList{m}.Initial)
                case '0'
                    beginStr='0';
                    endStr='1';
                case '1'
                    beginStr='1';
                    endStr='0';
                end

                driverCmds{rstIndx}=['force ',rstName,' ',beginStr,' 0 ',hdlTimeUnit,', '...
                ,endStr,' ',durationStr,' ',hdlTimeUnit,';'];
            end
            driverCmds=sprintf('%s\n',driverCmds{:});
        end
        function driverCmds=genPostSimTclCmd(obj)
            numClk=numel(obj.ClkList);
            numRst=numel(obj.RstList);
            driverCmds=cell(1,numClk+numRst);
            for m=1:numClk
                clkName=['/',obj.ModuleName,'/',obj.ClkList{m}.Name];
                driverCmds{m}=['noforce ',clkName,';'];
            end
            for m=1:numRst
                rstIndx=m+numClk;
                rstName=['/',obj.ModuleName,'/',obj.RstList{m}.Name];
                driverCmds{rstIndx}=['noforce ',rstName,';'];
            end
            driverCmds{end+1}='puts "done";';
            driverCmds=sprintf('%s\n',driverCmds{:});
        end

        function scriptName=genSlLaunchScript(obj)
            if strcmpi(obj.Workflow,'Simulink')
                vsimcmd='vsimulink';
            else
                vsimcmd='vsimmatlabsysobj';
            end
            tclDefBegin='tclcmd = { ...';
            elabCmd=['''',vsimcmd,' ',obj.TopLevelName,' ',obj.LoadOptions];

            if obj.useSocket
                elabCmd=[elabCmd,' -socket ',num2str(obj.SocketPort),';'', ...'];
            else
                elabCmd=[elabCmd,';'', ...'];
            end

            addWaveCmd=['''add wave ',obj.ModuleName,'/*;'', ...'];
            tclDefEnd='};';
            if(obj.UseSysPath)
                vsimcmd='vsim(''tclstart'',tclcmd);';
            else
                vsimcmd=['vsim(''tclstart'',tclcmd,''vsimdir'',''',obj.HdlPath,''')'];
            end

            Script=[{tclDefBegin},{elabCmd},{addWaveCmd},{tclDefEnd},{vsimcmd}];
            scriptName=writeLaunchScript(obj,Script,false);
        end


        function scriptName=genMlLaunchScript(obj,LaunchHdl)
            headerComments=...
            ['% Run this script to launch HDL simulator for verification with MATLAB',char(10)...
            ,'% Generated by Cosimulation Wizard',char(10)];

            if obj.useSocket
                startHdlDaemon=[...
                '% Start MATLAB server',char(10)...
                ,'commInfo = hdldaemon(''socket'',0);'];
                addSocketCmd=''' -socket '', commInfo.ipc_id ';
            else
                startHdlDaemon=[...
                '% Start MATLAB server',char(10)...
                ,'commInfo = hdldaemon;'];
                addSocketCmd='';
            end


            tclDefBegin=[...
            '% Load HDL design and associate MATLAB components with HDL modules',char(10)...
            ,'tclcmd = { ...'];

            elabCmd=['''vsimmatlab ',obj.TopLevelName,' ',obj.LoadOptions,';'', ...'];

            callbackCmds=cell(1,numel(obj.MatlabCb));
            for m=1:numel(obj.MatlabCb)
                callbackCmds{m}=['[''',obj.MatlabCb{m}.FullCmd,''', ',addSocketCmd,''';''], ...'];
            end

            tclDefEnd='};';

            if(obj.UseSysPath)
                vsimcmd='vsim(''tclstart'',tclcmd);';
            else
                vsimcmd=['vsim(''tclstart'',tclcmd,''vsimdir'',''',obj.HdlPath,''')'];
            end
            vsimcmd=['% Launch HDL simulator for use with MATLAB',char(10),vsimcmd];

            Script=[{headerComments},{startHdlDaemon},{tclDefBegin},{elabCmd},callbackCmds,{tclDefEnd},{vsimcmd}];
            scriptName=writeLaunchScript(obj,Script,LaunchHdl);
        end

        function genParameterConfigFile(obj)
            obj.parameterConfigFile=['parameter_',obj.ModuleName,'.cfg'];
            str2add=['-f ',obj.parameterConfigFile];
            if~contains(obj.LoadOptions,str2add)
                paraFile=fopen(obj.parameterConfigFile,'w');
                fprintf(paraFile,obj.defaultParameterConfigCommand);
                for m=1:length(obj.ParameterList)
                    switch(obj.ParameterList{m}.Type)
                    case "UnsupportedType"
                        configCommand=char(strcat('#-G',obj.delimiter,...
                        obj.ParameterList{m}.FullName,...
                        '=','(N/A)','\n'));
                    case{"Double","Integer","Enum"}
                        configCommand=char(strcat('#-G',obj.delimiter,...
                        obj.ParameterList{m}.FullName,...
                        '=',num2str(obj.ParameterList{m}.defaultValue),'\n'));
                    case{"String"}
                        configCommand=char(strcat('#-G',obj.delimiter,...
                        obj.ParameterList{m}.FullName,...
                        '=''',num2str(obj.ParameterList{m}.defaultValue),'''\n'));
                    case "Time"
                        configCommand=char(strcat('#-G',obj.delimiter,...
                        obj.ParameterList{m}.FullName,...
                        '=',num2str(obj.ParameterList{m}.defaultValue),'ns\n'));
                    end
                    fprintf(paraFile,configCommand);
                end
                fclose(paraFile);
                obj.LoadOptions=[obj.LoadOptions,' ',str2add];
            end
        end

        function[isexist,path]=simplewhich(~,inFileName)







            isexist=false;
            path='';



            [filePath,~,fileExt]=fileparts(inFileName);
            if isempty(fileExt)&&ispc
                inFileName=[inFileName,'.exe'];
            end


            if~isempty(filePath)
                if exist(inFileName,'file');
                    isexist=true;
                    path=filePath;
                end
                return;
            end


            envPath=getenv('PATH');
            envPathSep=regexp(envPath,['\s*',pathsep,'\s*'],'split');


            for ii=1:length(envPathSep)
                aPath=envPathSep{ii};

                if exist(aPath,'dir')
                    searchStr=fullfile(aPath,inFileName);
                    if exist(searchStr,'file');
                        isexist=true;
                        path=aPath;
                        return;
                    end
                end
            end
        end
    end
end




