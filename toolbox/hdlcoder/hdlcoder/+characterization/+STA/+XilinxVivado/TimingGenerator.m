classdef TimingGenerator<handle





    properties
        m_expDir;
        m_modelInfo;
        m_targetInfo;
        m_regSuffix;
        m_reportFile;
        m_csvFile;
    end


    methods

        function self=TimingGenerator()
            self.m_expDir={};
            self.m_modelInfo=struct();
            self.m_targetInfo=struct();
            self.m_regSuffix='*';
            self.m_reportFile='mathworks_report_timing_groups.log';
            self.m_csvFile='timing_info.txt';
        end

        function init(self,targetInfo,runToolFolder,modelInfo)
            self.m_expDir=runToolFolder;
            self.m_modelInfo=modelInfo;
            self.m_targetInfo=targetInfo;
            self.m_regSuffix='*';
            self.m_reportFile='mathworks_report_timing_groups.log';
            self.m_csvFile='timing_info.txt';
        end

        function[status,logTxt,timingInfo]=runToolAndGetDelay(self)
            timingInfo=[];
            cd(self.m_expDir);





            self.generateToolScripts();


            [status,logTxt]=self.synthesizeRTL();

            if(status==1)
                timingInfo=self.buildTimingInfo();
            end

        end

        function generateToolScripts(self)
            self.generateRunTclScript();
            self.generatePreCreateTclScript();
            self.generateLibraryTcl();
            self.generatePreSynthesisTclScript();
            self.generateReportTimingTclScript();
        end

        function generateRunTclScript(self)
            cfile=fopen('run.tcl','w');
            fprintf(cfile,'source PreCreate.tcl\n');
            fprintf(cfile,'\n');
            fprintf(cfile,'foreach filename $hdl_files {\n');
            fprintf(cfile,'    read_vhdl  $filename\n');
            fprintf(cfile,'    puts "Reading file $filename."\n');
            fprintf(cfile,'}\n');
            fprintf(cfile,'\n');
            fprintf(cfile,'set temp [open mathworks_report_timing_groups.log w ]\n');
            fprintf(cfile,'close $temp\n');
            fprintf(cfile,'\n');
            fprintf(cfile,'synth_design -top $myTopLevelEntry -part $mypart\n');
            fprintf(cfile,'source PreSynthesis.tcl\n');
            fprintf(cfile,'source ReportTimingGroups.tcl\n');
            fclose(cfile);
        end

        function generatePreCreateTclScript(self)

            cfile=fopen('PreCreate.tcl','w');
            fprintf(cfile,['set mypart ',self.m_targetInfo.deviceFullName,'\n']);
            fprintf(cfile,['set myTopLevelEntry ',self.m_modelInfo.topSubsystem,'\n']);
            filelist=self.getRTLFileList();
            filestr=[];

            for i=1:numel(filelist)
                filestr=[filestr,' ',filelist{i}];

            end
            fprintf(cfile,['set hdl_files [list ',filestr,']\n']);

            fclose(cfile);

        end

        function generateLibraryTcl(self)

            cfile=fopen('library.tcl','w');
            fprintf(cfile,'proc remove_list {il y} {\n');
            fprintf(cfile,'  set x [lsort $il ]\n');
            fprintf(cfile,'  set y [lsort $y ]\n');
            fprintf(cfile,'  foreach e $y {\n');
            fprintf(cfile,'    set idx [lsearch -exact  $x $e]\n');
            fprintf(cfile,'    set len [llength $x]\n');
            fprintf(cfile,'    #puts "index : $idx and length $len"\n');
            fprintf(cfile,'    if { $idx < $len } {\n');
            fprintf(cfile,'      if { $idx != -1 } {\n');
            fprintf(cfile,'        set x [lreplace $x $idx $idx]\n');
            fprintf(cfile,'      }\n');
            fprintf(cfile,'    }\n');
            fprintf(cfile,'  }\n');
            fprintf(cfile,'\n');
            fprintf(cfile,'  set rval $x\n');
            fprintf(cfile,'  #set len [llength $x]\n');
            fprintf(cfile,'  #puts "return list size $len"\n');
            fprintf(cfile,'  return $rval\n');
            fprintf(cfile,'}\n');
            fprintf(cfile,'\n');
            fprintf(cfile,'proc handle_path { tpath fname  } {\n');
            fprintf(cfile,'    if { [llength $tpath] == 0 } {\n');
            fprintf(cfile,'        puts  $fname ", inf"\n');
            fprintf(cfile,'    } else {\n');
            fprintf(cfile,'        set tpath_t  [lindex $tpath 0 ]\n');
            fprintf(cfile,'        set delay_t [get_property DATAPATH_DELAY $tpath_t]\n');
            fprintf(cfile,'        puts  $fname ", $delay_t"\n');
            fprintf(cfile,'    }\n');
            fprintf(cfile,'}\n');
            fclose(cfile);
        end

        function generatePreSynthesisTclScript(self)

            cfile=fopen('PreSynthesis.tcl','w');
            fprintf(cfile,'set myclk_ports [list [get_ports clk] ]\n');
            fprintf(cfile,'if { [ llength $myclk_ports ] > 0 } {\n');
            fprintf(cfile,'   create_clock -name named_clock [get_ports clk] -period 100\n');
            fprintf(cfile,'}');
            fclose(cfile);
        end

        function generateReportTimingTclScript(self)

            rfile=fopen('ReportTimingGroups.tcl','w');
            tfile='$tf';

            fprintf(rfile,['source library.tcl\n']);
            fprintf(rfile,'set tf [open timing_info.txt w]\n');
            fprintf(rfile,'set mw_all_registers [get_cells  -filter { IS_SEQUENTIAL && IS_PRIMITIVE }] \n');

            intRegsCmd=['[ get_cells -hierarchical -regexp { .*',self.m_modelInfo.blockSubsystem,'/.* } -filter { IS_SEQUENTIAL && IS_PRIMITIVE } ]'];

            fprintf(rfile,'set mw_internal_registers %s \n',intRegsCmd);

            inregs_var={};
            input_regs=self.m_modelInfo.portRegisters.in.values;
            for idx=1:numel(input_regs)

                inregName=input_regs{idx};
                nt=regexp(inregName,'.*_(?<portid>\d+)_RED$','names');
                portId=str2double(nt.portid);

                inregs_var{portId+1}=['mw_inport_',int2str(portId)];
                fprintf(rfile,'set %s [list ]\n',inregs_var{portId+1});
                fprintf(rfile,'set %s [concat $%s [get_cells %s%s] ] \n',inregs_var{portId+1},inregs_var{portId+1},inregName,self.m_regSuffix);
            end

            outregs_var={};
            output_regs=self.m_modelInfo.portRegisters.out.values;
            for idx=1:numel(output_regs)

                outregName=output_regs{idx};
                nt=regexp(outregName,'.*_(?<portid>\d+)_RED$','names');
                portId=str2double(nt.portid);

                outregs_var{portId+1}=['mw_outport_',int2str(portId)];
                fprintf(rfile,'set %s [list ]\n',outregs_var{portId+1});
                fprintf(rfile,'set %s [concat $%s [get_cells %s%s]] \n',outregs_var{portId+1},outregs_var{portId+1},outregName,self.m_regSuffix);


            end
            self.print_path_details('mw_internal_registers','mw_internal_registers',rfile,tfile);

            for idx=1:numel(inregs_var)

                if isempty(inregs_var{idx})
                    error(' Incorrect port names for in script geneation');
                end
                self.print_path_details(inregs_var{idx},'mw_internal_registers',rfile,tfile);

            end

            for idx=1:numel(outregs_var)

                if isempty(outregs_var{idx})
                    error(' Incorrect port names for in script geneation');
                end
                self.print_path_details('mw_internal_registers',outregs_var{idx},rfile,tfile);

            end

            for iidx=1:numel(inregs_var)

                for oidx=1:numel(outregs_var)

                    self.print_path_details(inregs_var{iidx},outregs_var{oidx},rfile,tfile);

                end
            end

            fprintf(rfile,'close $tf\n');
            fclose(rfile);
        end

        function filelist=getRTLFileList(self)

            dir_contents=dir('./*.vhd');
            dir_vect=~[dir_contents(:).isdir];
            filelist={dir_contents(dir_vect).name};

        end

        function print_path_details(self,src_cells,dest_cells,sfile,rfile)

            fprintf(sfile,'puts -nonewline %s "DelayInfo, %s, %s"\n',rfile,src_cells,dest_cells);
            fprintf(sfile,'set mw_path [list ]\n');
            fprintf(sfile,'if { [llength $%s] > 0 && [llength $%s] > 0 } { \n ',src_cells,dest_cells);
            fprintf(sfile,'     set mw_path [get_timing_paths -delay_type max -from $%s -to $%s -nworst 1 -max_paths 1]\n',src_cells,dest_cells);
            fprintf(sfile,'     report_timing -from $%s -to $%s >> mathworks_report_timing_groups.log \n',src_cells,dest_cells);
            fprintf(sfile,'}\n');
            fprintf(sfile,'handle_path $mw_path %s\n',rfile);


        end

        function[status,logTxt]=synthesizeRTL(self)

            scriptName=fullfile(pwd,'run.tcl');
            cmdString=['vivado -mode batch -source ',scriptName];
            [status,logTxt]=system(cmdString);

            if status==0
                status=1;
            else
                status=0;
            end

        end

        function timingInfo=buildTimingInfo(self)
            timingLogReader=characterization.STA.XilinxVivado.TimingLogReader();
            timingInfo=timingLogReader.parseReport(self.m_csvFile);



            for i=1:numel(timingInfo)
                pt=timingInfo(i);

                if pt.ports(1)~=characterization.STA.Characterization.RegisterPort
                    regName=[self.m_modelInfo.portRegisters.in(pt.ports(1)+1)...
                    ,self.m_regSuffix];
                    regName=regexprep(regName,'\*','');

                    d=self.getCQTime(regName);

                    if(d>0)
                        pt.delay=pt.delay-d;

                        if(pt.delay<0)
                            error('Negative delay');
                        end
                    end
                end


                if pt.ports(2)~=characterization.STA.Characterization.RegisterPort
                    regName=[self.m_modelInfo.portRegisters.out(pt.ports(2)+1)...
                    ,self.m_regSuffix];
                    regName=regexprep(regName,'\*','');

                    d=self.getSetupTime(regName);

                    if(d>0)
                        pt.delay=pt.delay-d;

                        if(pt.delay<0)
                            error('Negative delay');
                        end
                    end
                end
                timingInfo(i)=pt;
            end


        end

        function delay=getSetupTime(self,regName)

            delay=-1;
            entryRegExp='^\s*(?<name>[^\s]+)\s+\((?<desc>[^\)]+)?\)?\s+(?<delay>[\d\.]+)\s+(?<cdelay>[\d\.]+)\s+([rf])?\s+(?<compname>[^\s]+)$';
            fid=fopen(self.m_reportFile,'r');

            cline=fgets(fid);

            while ischar(cline)

                cline=strtrim(cline);
                matched=regexp(cline,entryRegExp,'match');

                if(~isempty(matched))
                    dEntry=regexp(cline,entryRegExp,'names');
                    matched=regexp(dEntry.compname,['^\s*([^\/\s]*)',regName,'([^\s\/]*)$'],'match');
                    if~isempty(matched)

                        cline=fgets(fid);
                        if ischar(cline)
                            cline=strtrim(cline);
                            matched=regexp(cline,'^([\s-]+)$','match');
                            if(isempty(matched))
                                continue;
                            end
                        end

                        if(~ischar(cline))
                            continue;
                        end

                        delay=str2double(dEntry.delay);
                        fclose(fid);
                        return;
                    end
                end
                cline=fgets(fid);
            end
            fclose(fid);
        end

        function delay=getCQTime(self,regName)

            delay=-1;
            entryRegExp='^\s*(?<name>[^\s]+)\s+\((?<desc>[^\)]+)?\)?\s+(?<delay>[\d\.]+)\s+(?<cdelay>[\d\.]+)\s+([rf])?\s+(?<compname>[^\s]+)$';
            fid=fopen(self.m_reportFile,'r');

            cline=fgets(fid);

            while ischar(cline)

                cline=strtrim(cline);
                matched=regexp(cline,entryRegExp,'match');

                if(~isempty(matched))
                    dEntry=regexp(cline,entryRegExp,'names');
                    matched=regexp(dEntry.compname,['^\s*([^\/\s]*)',regName,'([^\s\/]*)/Q$'],'match');
                    if~isempty(matched)
                        delay=str2double(dEntry.delay);
                        fclose(fid);
                        return;
                    end
                end
                cline=fgets(fid);
            end
            fclose(fid);
        end

    end
end
