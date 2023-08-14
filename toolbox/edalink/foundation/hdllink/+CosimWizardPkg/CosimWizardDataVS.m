



classdef CosimWizardDataVS<CosimWizardPkg.CosimWizardData
    properties(Constant)
        WorkflowOptions={'Simulink','MATLAB System Object'};
        DefaultLoadOptions='';
        DefaultElabOptions='';
        Simulator='Vivado Simulator';
        FileTypes={'Verilog','VHDL'};
        delimiter='.';

        DefaultLangOpt='Verilog';
        DefaultDbgOpt='off';
        DefaultPrecOpt='1ps';

        TclQueryFile='hdlverifier_tcl_query_info.txt';




        ProjectDir='hdlverifier_wizard_project';
        ProjectName='wizprj';




        CompilationScriptFile='hdlverifier_compile.tcl';
        CompilationBlueBoxFunctionFile='hdlverifier_compile.m';



        LaunchScriptFile='hdlverifier_gendll.tcl';
        LaunchBlueBoxFunctionFile='hdlverifier_gendll_$TOP.m';













    end
    properties
        TclQueryInfo;
        CompilationBlueBoxFunctionName;
        LaunchCmd;
        LaunchBlueBoxFunctionName;
        HdlDebug;
    end
    methods(Static)
        function elabOptions=createElabOptions(langOpt,dbgOpt,precOpt)
            dbgCmd=['set_property -name {xelab.debug_level} -value {',lower(dbgOpt),'} -objects [get_filesets sim_1]'];
            switch langOpt
            case 'VHDL'
                timeprec=[' --timeprecision_vhdl ',precOpt,' '];
            case 'Verilog'
                timeprec=[' --timescale ',precOpt,'/',precOpt,' --override_timeprecision '];
            end
            precCmd=['set_property -name {xelab.more_options} -value {',timeprec,'} -objects [get_filesets sim_1]'];
            dllCmd='set_property -name {xelab.dll} -value {1} -objects [get_filesets sim_1]';
            snapCmd='set_property -name {xelab.snapshot} -value {design} -objects [get_filesets sim_1]';
            elabOptions=sprintf('%s\n',dbgCmd,precCmd,dllCmd,snapCmd);
        end
    end
    methods
        function this=CosimWizardDataVS
            this.LoadOptions=this.DefaultLoadOptions;
            this.ElabOptions=this.createElabOptions(this.DefaultLangOpt,this.DefaultDbgOpt,this.DefaultPrecOpt);
            this.HdlResolution=this.precStrToExp(this.DefaultPrecOpt);
            this.HdlDebug=this.DefaultDbgOpt;
        end


        function genCompileCommand(obj)
            [numFiles,~]=size(obj.HdlFiles);
            createProj={
'# ======== Create Project ======== '
            ['create_project -force ',obj.ProjectName,' ',obj.ProjectDir]
''
            };

            compSourceFiles='';

            FilePaths=obj.HdlFiles(:,1);
            [FolderPaths,names,exts]=fileparts(FilePaths);
            if ischar(FolderPaths)


                FolderPaths={FolderPaths};
                names={names};
                exts={exts};
            end
            [uniquePath,~,ic]=unique(FolderPaths);
            FileNames=strcat(names,exts);
            for m=1:length(uniquePath)
                pathName=strrep(uniquePath{m},'\','/');
                pathName=regexprep(pathName,'\s+','\\ ');
                compSourceFiles=[compSourceFiles,'set SRC',num2str(m),' {',pathName,'}',newline];%#ok<AGROW> 
            end

            for m=1:numFiles
                filename=['$SRC',num2str(ic(m)),'/',FileNames{m}];
                compSourceFiles=[compSourceFiles,'add_file "',filename,'"',newline];%#ok<AGROW>
            end

            addSources={
'# ======== Add source files to project ========'
compSourceFiles
            };

            elabOptions={
'# ======== Elaboration options ========'
'set_property -name {xelab.snapshot} -value {mwcosim_query} -objects [get_filesets sim_1]'
''
            };

            compAndElabMain={
'# ======== Compile and Elaborate ========'
'# Compile, elaborate, and start a sim image in order to auto determine'
'# the top module and its interface information.'
'set_property source_mgmt_mode All [current_project]'
'set_property SOURCE_SET sources_1 [get_filesets sim_1]'
'update_compile_order -fileset sim_1'
'launch_simulation'
''
            };

            gatherInfo={
'# ======== Gather Design Info ========'
'# DO NOT EDIT.  Needed for gathering top-level design information.'
'set TOP_MODULE [get_property top [get_fileset sim_1]]'
'set INPORT_NAMES [get_objects -filter { type == in_port }]'
'set OUTPORT_NAMES [get_objects -filter { type == out_port }]'
            ['report_scope [current_scope] > ',obj.TclQueryFile]
            ['foreach {port} [concat $INPORT_NAMES $OUTPORT_NAMES] { report_object $port >> ',obj.TclQueryFile,'}']
''
            };

            fullScript=[createProj(:);
            addSources(:);
            elabOptions(:);
            compAndElabMain(:);
            gatherInfo(:)];
            fullScriptStr=sprintf('%s\n',fullScript{:});
            obj.GeneratedCompileCmd=fullScriptStr;
        end

        function runCompilation(obj)
            obj.CompilationBlueBoxFunctionName=obj.createSimScriptAndMATLABCallingFunction('compilation');
            eval(obj.CompilationBlueBoxFunctionName);

            obj.parseTclQueryInfo();
            obj.ModulesFound={obj.TclQueryInfo.TopModule};
        end



        function launchHdl(obj,logFile)
            elabForXsimkLib={
            ['open_project ',obj.ProjectDir,'/',obj.ProjectName,'.xpr']
            obj.ElabOptions
'launch_simulation'
''
'# The xsim.dir must be co-located with the model.'
'# - save off existing xsim.dir'
'if {[file exists xsim.dir] == 1} {'
'    set mtime [file mtime xsim.dir]'
'    set mtimestamp [clock format $mtime -format %Y%m%d_%H%M%S]'
'    set xsim_savefile "xsim.dir.$mtimestamp"'
'    file rename xsim.dir $xsim_savefile'
'}'
'# - copy up newly elaborated xsim.dir area from project to the current working directory.'
            ['set proj_xsim_dir {',obj.ProjectDir,'/',obj.ProjectName,'.sim/sim_1/behav/xsim/xsim.dir}']
'set proj_mtime [file mtime "$proj_xsim_dir/design"]'
'file copy -force $proj_xsim_dir .'
'file mtime xsim.dir $proj_mtime'
''
            };
            obj.LaunchCmd=sprintf('%s\n',elabForXsimkLib{:});

            obj.LaunchBlueBoxFunctionName=obj.createSimScriptAndMATLABCallingFunction('launch');
            eval(obj.LaunchBlueBoxFunctionName);
        end







        function funcName=genCompileScript(obj)

            funcName=obj.CompilationBlueBoxFunctionName;
        end

        function autoFill(obj)

            obj.InPortList={};
            obj.OutPortList={};
            pit=obj.TclQueryInfo.PortInfo;
            insTable=pit(strcmp(pit.PortDirection,'Input'),'PortName');
            outsTable=pit(strcmp(pit.PortDirection,'Output'),'PortName');

            cellfun(@(x)(obj.addPort(x,1)),insTable{:,:});
            cellfun(@(x)(obj.addPort(x,2)),outsTable{:,:});



            possibleNames={'fs','ps','ns','us','ms','s'};
            lowestIndx=floor((obj.HdlResolution+15)/3)+1;
            if(lowestIndx>6)
                lowestIndx=6;
            elseif(lowestIndx<1)
                lowestIndx=1;
            end
            obj.HdlTimeUnitNames=possibleNames(lowestIndx:end);
            obj.HdlTimeUnit=obj.HdlTimeUnitNames{1};

        end

        function autoFillAllModulesParameters(obj)
            obj.ParameterList={};
        end

        function genParameterConfigFile(obj)

        end

        function driverCmds=genPreSimTclCmd(obj)
            driverCmds='';
        end

        function driverCmds=genPostSimTclCmd(~)
            driverCmds='';
        end

        function funcName=genSlLaunchScript(obj)

            funcName=obj.LaunchBlueBoxFunctionName;
        end

        function funcName=genMlLaunchScript(obj,LaunchHdl)
            error('This function is not yet implemented.')
            funcName='not_done_yet.xxx';
        end





        function dbg=getDebugValue(obj)

            tok=regexp(obj.ElabOptions,'xelab.debug_level} -value {(\w+)}','tokens');
            if~isempty(tok)
                dbg=tok{1}{1};
            else
                dbg='off';
            end
        end



        function cmd=getMlCompileCommand(obj)
            cmd=sprintf('[s, r] = system([''vivado -mode tcl < %s''],''-echo'');\n',obj.CompilationScriptFile);
            cmd=[cmd,'if (s ~= 0)',newline];
            cmd=[cmd,'    error(message(''HDLLink:CosimWizard:CompilationError'',r));',newline];
            cmd=[cmd,'end',newline];
        end


        function wrapperFuncName=createSimScriptAndMATLABCallingFunction(obj,compOrLaunch)
            switch compOrLaunch
            case 'compilation'
                scriptFileName=obj.CompilationScriptFile;
                scriptContents=obj.CompileCmd;
                wrapperFileName=obj.CompilationBlueBoxFunctionFile;
                scriptErrorId='HDLLink:CosimWizard:CompilationError';
            case 'launch'
                scriptFileName=obj.LaunchScriptFile;
                scriptContents=obj.LaunchCmd;
                wrapperFileName=obj.LaunchBlueBoxFunctionFile;
                scriptErrorId='HDLLink:CosimWizard:ElaborationFailed';
            otherwise,error('(internal) unknown compOrLaunch option');
            end


            fid=fopen(scriptFileName,'w','n','utf-8');
            fwrite(fid,scriptContents,'char');
            fclose(fid);


            if ispc
                if(obj.UseSysPath)
                    [s,r]=system('where.exe vivado');
                    if s,error('Vivado not found on path.');end
                    paths=split(r);
                    hdlsimpath=fileparts(strtrim(paths{1}));
                else
                    hdlsimpath=obj.HdlPath;
                end
                libpath=fullfile(hdlsimpath,'..','lib','win64.o');
                libpathvar='PATH';
                libext='dll';
            else
                if(obj.UseSysPath)
                    [s,r]=system('which vivado');
                    if s,error('Vivado not found on path.');end
                    hdlsimpath=fileparts(strtrim(r));
                else
                    hdlsimpath=obj.HdlPath;
                end
                libpath=fullfile(hdlsimpath,'..','lib','lnx64.o');
                libpathvar='LD_LIBRARY_PATH';
                libext='so';
            end

            kernellib=[libpath,filesep,'librdi_simulator_kernel.',libext];
            if(~exist(kernellib,"file"))
                warning('Could not find simulator kernel library at ''%s''.  Continuing but you may not be able to run a cosimulation.',kernellib);
            end



            adjustedWrapperFileName=regexprep(wrapperFileName,'\$TOP',obj.ModuleName);
            adjustedWrapperFileName=regexprep(adjustedWrapperFileName,'[^.\w]','');
            [~,wrapperFuncName,~]=fileparts(adjustedWrapperFileName);


            header={
            ['function ',wrapperFuncName]
            ['% ',wrapperFuncName,' is a MATLAB calling wrapper for compiling/elaborating the HDL design']
            ['% Generated by Cosimulation Wizard on ',datestr(now)]
''
            };
            setpaths={
'% ---- set path info for Vivado executables and kernel libs'
            ['lutils(''PathPrepend'', ''',libpathvar,''', ''',libpath,''');']
            ['lutils(''PathPrepend'', ''PATH'', ''',hdlsimpath,''');']
''
            };
            syscmd={
'% ---- make system call to Vivado script'
            sprintf('[s, r] = system([''vivado -mode tcl < %s''],''-echo'');\n',scriptFileName)
'if (s ~= 0)'
            ['    error(message(''',scriptErrorId,''',r));']
'end'
            };

            fullWrapper=[header(:);
            setpaths(:);
            syscmd(:)];
            obj.l_WriteStrCellArrayToFile(fullWrapper,adjustedWrapperFileName,false);
        end

        function parseTclQueryInfo(obj)
            tqi=readtable(obj.TclQueryFile,...
            'ReadVariableNames',false,...
            'Delimiter',{'\t','\b',' '},...
            'ConsecutiveDelimitersRule','join',...
            'LeadingDelimitersRule','ignore',...
            'TrailingDelimitersRule','ignore');
            assert(size(tqi,2)==3,['(internal) could not parse ',obj.TclQueryFile,' in order to get design meta-information.']);
            obj.TclQueryInfo.TopLanguage=tqi.Var1{1};
            obj.TclQueryInfo.TopModule=regexprep(tqi.Var3{1},'[/{}]','');


            tqi(1,:)=[];





            foo=tqi.Var2;
            PortName=cell(size(foo));
            idx=0;
            for foo1=foo'
                idx=idx+1;
                foo2=regexp(foo1{1},'{(\w+)[\[}]','tokens');
                PortName(idx)=foo2;
            end
            tqi=[tqi,cell2table(PortName)];



            foo=tqi.Var1;
            PortDirection=cell(size(foo));
            idx=0;
            for foo1=foo'
                idx=idx+1;
                foo2={regexprep(foo1{1},'In:','Input')};
                foo3={regexprep(foo2{1},'Out:','Output')};
                PortDirection(idx)=foo3;
            end
            tqi=[tqi,cell2table(PortDirection)];



            foo=tqi.Var2;
            PortDimensions=cell(size(foo));
            idx=0;
            for foo1=foo'
                idx=idx+1;

                foo2=regexp(foo1{1},'(\[.*\])','tokens');
                if isempty(foo2),foo2={'[0:0]'};end
                foo3=split(foo2{:},{']',',','['});
                foo4=foo3(cellfun(@(x)(~isempty(x)),foo3));
                foo5=split(foo4,':');
                if(iscolumn(foo5)),foo5=foo5';end
                PortDimensions(idx)={...
                cellfun(@(x)(abs(str2double(x{1})-str2double(x{2}))+1),...
                arrayfun(@(x)(foo5(x,:)),(1:size(foo5,1)),'UniformOutput',false))...
                };
            end
            tqi=[tqi,cell2table(PortDimensions)];




            PortDatatype=repmat({'Logic'},[size(tqi,1),1]);
            tqi=[tqi,cell2table(PortDatatype)];

            obj.TclQueryInfo.PortInfo=tqi(:,4:end);
        end
        function[xsiPV,blkPV,sysobjRawClkInfo]=genBlockAndObjParamValues(obj,timingScaleFactor,timingMode)
            xsimk='xsim.dir/design/xsimk';
            lmap=containers.Map({'Verilog','VHDL'},{'vlog','vhdl'});
            lang=lmap(obj.TclQueryInfo.TopLanguage);

            prec=obj.precExpToStr(obj.HdlResolution);






            tsf=str2double(timingScaleFactor);
            tsu=10^(obj.precStrToExp(['1',timingMode]));
            sl2hdlTimescale=tsf*tsu;
            hdl2slTimescale=1/sl2hdlTimescale;
            clkrstTimeUnit=10^(obj.precStrToExp(['1',obj.HdlTimeUnit]));


            if~isempty(obj.ClkList)
                cmmap=containers.Map({'Falling','Rising'},{1,2});
                cn=cellfun(@(x)(sprintf(['/',obj.ModuleName,'/%s'],x.Name)),obj.ClkList,'UniformOutput',false);
                cm=cellfun(@(x)(cmmap(x.Edge)),obj.ClkList,'UniformOutput',false);
                cp=cellfun(@(x)(x.Period),obj.ClkList,'UniformOutput',false);
                clknames=cn;
                clkmodes=cm;

                clkpersraw=cellfun(@(x)({str2double(x)}),cp);
                clkpersHDLTime={cellfun(@(x)(x*clkrstTimeUnit),clkpersraw)};

            else
                clknames={};
                clkmodes={};
                clkpersraw={};
                clkpersHDLTime={};

            end


            if~isempty(obj.RstList)
                rn=cellfun(@(x)(sprintf(['/',obj.ModuleName,'/%s'],x.Name)),obj.RstList,'UniformOutput',false);
                rstnames=rn;

                ri=cellfun(@(x)(x.Initial),obj.RstList,'UniformOutput',false);
                rstvals=cellfun(@(x)({str2double(x)}),ri);
                initvalToMaskEnum=containers.Map({0,1},{4,3});
                rstmodes=cellfun(@(x)({initvalToMaskEnum(x)}),rstvals);

                rd=cellfun(@(x)(x.Duration),obj.RstList,'UniformOutput',false);
                rstdursraw=cellfun(@(x)({str2double(x)}),rd);
                rstdursHDLTime={cellfun(@(x)(x*clkrstTimeUnit),rstdursraw)};

            else
                rstnames={};
                rstmodes={};
                rstdursraw={};
                rstdursHDLTime={};

            end


            clkrstNames=[clknames,rstnames];
            clkrstModes=[clkmodes,rstmodes];

            clkrstTimes=[clkpersHDLTime,rstdursHDLTime];




            pit=obj.TclQueryInfo.PortInfo;
            allNames=pit.PortName(:);
            allTypes=pit.PortDatatype(:);
            allDims=pit.PortDimensions(:);



            if~iscell(allDims)
                allDims=num2cell(allDims);
            end

            allUsedNames=cellfun(@(x)(x.Name),[obj.UsedInPortList,obj.UsedOutPortList],'UniformOutput',false);
            keepIndx=arrayfun(@(x)(any(strcmp(allNames(x),allUsedNames))),(1:length(allNames)));

            blkIfTypes=allTypes(keepIndx);
            blkIfDims=allDims(keepIndx);

            xsiPV={...
            'design',xsimk,...
            'lang',lang,...
            'prec',prec,...
            'types',blkIfTypes,...
            'dims',blkIfDims...
            };

            blkPV={...
            'ClockPaths',sprintf('%s;',clkrstNames{:}),...
            'ClockModes',['[',sprintf('%d ',clkrstModes{:}),']'],...
            'ClockTimes',['[',sprintf('%g ',clkrstTimes{:}),']'];
            };


            sysobjRawClkInfo={clkrstNames,clkrstModes,[clkpersraw,rstdursraw]};


        end
    end
end







