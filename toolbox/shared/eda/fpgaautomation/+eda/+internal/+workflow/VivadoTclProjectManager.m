classdef VivadoTclProjectManager<eda.internal.workflow.FPGAProjectManager









    properties
        TopLevelEntityName='';
    end
    properties(SetAccess=protected)
mToolInfo
PARFile
mSkipSynthesis
FPGASystemClockFrequency
    end

    methods
        function h=VivadoTclProjectManager

            h.mToolInfo=eda.internal.workflow.VivadoInfo;




            key=cellfun(@(x)x{1},h.mToolInfo.FPGABuildProcess,'UniformOutput',false);
            val=cellfun(@(x)x{2},h.mToolInfo.FPGABuildProcess,'UniformOutput',false);
            h.ToolProcessMap=containers.Map(key,val);

            h.ProjectExt=h.mToolInfo.ProjectFileExt;
            h.mSkipSynthesis=false;
        end


        function initialize(h)
            h.TclCmdQueue=[];
            h.StatusMsg='';
            h.NewProject=[];
        end

        function result=get.PARFile(h)
            if isempty(h.ProjectName)
                result='';
            else
                result=[h.ProjectName,'.par'];
            end
        end

        function removeFiles(h,srcfiles,varargin)



            if~iscell(srcfiles)||~all(cellfun(@ischar,srcfiles))
                error(message('EDALink:ISETclProjectManager:InvalidFileInput'));
            end
            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Removed Source Files:';
                end
                h.addStatus(str,2);
            end

            for n=1:length(srcfiles)
                file=char(srcfiles(n));
                if h.DispStat
                    h.addStatus(file,3);
                end

                file=strrep(file,'\','/');
                file=h.addPathQuote(file);
                h.TclCmdQueue{end+1}=[h.TclPrefix,'remove_files ',file];
            end
        end

        function[result,projPath]=isExistingProject(h)




            h.validateProjectFile;

            result=false;projPath={};
            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.ProjectFileExt]);
            if exist(proj,'file')==2
                result=true;
                projPath{end+1}=proj;
            end
        end

        function deleteExistingProject(h)




            h.validateProjectFile;

            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.ProjectFileExt]);
            if exist(proj,'file')==2
                delete(proj);
            end
        end


        function createProject(h,varargin)
            h.validateProjectFile;
            h.parseProjParam(varargin{:});


            h.TclCmdQueue{end+1}=[h.TclPrefix,'create_project -force ',h.ProjectName,' .'];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property target_language VHDL [current_project]'];
            h.NewProject=true;

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Project:';
                end
                h.addStatus(str,2);
                h.addStatus('_PROJPATH__',3);
            end
        end

        function openProject(h,varargin)
            h.validateProjectFile;
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'open_project ',h.ProjectName];
            h.NewProject=false;

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Project:';
                end
                h.addStatus(str,2);
                h.addStatus('_PROJPATH__',3);
            end
        end

        function closeProject(h,varargin)
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'close_project'];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end

        function cleanProject(~,varargin)

        end


        function setTopLevel(h,entityName,varargin)
            validateattributes(entityName,{'char'},{'nonempty'});
            h.parseProjParam(varargin{:});
            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property top ',entityName,' [current_fileset]'];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end

        function setTargetDevice(h,target,varargin)
            validateattributes(target,{'struct'},{'nonempty'});
            h.parseProjParam(varargin{:});



            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Target Device:';
                end
                h.addStatus(str,2);
                familyName=getFPGAPartList(target.family,'customerName');
                h.addStatus([familyName,' '...
                ,target.device,target.speed,target.package],3);
            end
            device=[target.device,target.package,target.speed];

            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property part ',device,' [current_project]'];
        end

        function setProperties(h,prop,varargin)
            validateattributes(prop,{'struct'},{'nonempty'});
            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Property Settings:';
                end
                h.addStatus(str,2);
            end

            for n=1:length(prop)





            end
        end

        function setFPGASystemClockFrequency(h,FPGASystemClockFrequency)
            h.FPGASystemClockFrequency=FPGASystemClockFrequency;
        end

        function generateIP(h,boardObj)
            clkInFreq=sprintf('%.3f',boardObj.Component.SYSCLK.Frequency);
            DUTFreq=strtok(h.FPGASystemClockFrequency,'MHz');
            switch boardObj.Component.Communication_Channel
            case 'XlnxSGMII'

                h.mToolInfo.checkFPGATool(true);
                h.addStatus('Generating SGMII IP',2);
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name gig_ethernet_pcs_pma -vendor xilinx.com -library ip -module_name gig_ethernet_pcs_pma_1'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.SupportLevel {Include_Shared_Logic_in_Core} CONFIG.Standard {SGMII} CONFIG.Management_Interface {false}] [get_ips gig_ethernet_pcs_pma_1]'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clkmgr_sgmii'];






                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.PRIM_IN_FREQ {',clkInFreq,'} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {',DUTFreq,'}] [get_ips clkmgr_sgmii]'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'generate_target all [get_ips] -force'];
            case 'XlnxSGMII625MhzRef'







                h.mToolInfo.checkFPGATool(true);
                h.addStatus('Generating SGMII IP',2);
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name gig_ethernet_pcs_pma -vendor xilinx.com -library ip -module_name gig_ethernet_pcs_pma_1'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.SupportLevel {Include_Shared_Logic_in_Core} CONFIG.Standard {SGMII} CONFIG.Physical_Interface {LVDS} CONFIG.LvdsRefClk {625} CONFIG.Management_Interface {false} CONFIG.SGMII_PHY_Mode {true}] [get_ips gig_ethernet_pcs_pma_1]'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clkmgr_sgmii'];






                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.PRIM_IN_FREQ {',clkInFreq,'} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {',DUTFreq,'}] [get_ips clkmgr_sgmii]'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'generate_target all [get_ips] -force'];
            case 'RMII'


                h.addStatus('Generating RMII IP',2);
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name mii_to_rmii -vendor xilinx.com -library ip -module_name mii_to_rmii_0'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0'];

                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.PRIM_IN_FREQ {',clkInFreq,'} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {',DUTFreq,'} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50.000} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50.000} CONFIG.CLKOUT3_REQUESTED_PHASE {45.000}] [get_ips clk_wiz_0]'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'generate_target all [get_ips] -force'];
            case 'Digilent JTAG'



                h.addStatus('Generating Xilinx DCM and FIFO IP',2);
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0'];

                if strcmpi(boardObj.Component.SYSCLK.Type,'SINGLE_ENDED')
                    source_config='';
                else
                    source_config='CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} ';
                end
                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list ',source_config,' CONFIG.PRIM_IN_FREQ {',clkInFreq,'} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {',DUTFreq,'}] [get_ips clk_wiz_0]'];

                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name jtag_mac_fifo'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.Input_Data_Width {8} CONFIG.Input_Depth {4096} CONFIG.Read_Data_Count {true}  CONFIG.Use_Embedded_Registers {false} CONFIG.read_data_count_width {12} CONFIG.Almost_Full_Flag {true}] [get_ips jtag_mac_fifo]'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name simcycle_fifo'];
                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.Input_Data_Width {16} CONFIG.Input_Depth {16} CONFIG.Use_Embedded_Registers {false} ] [get_ips simcycle_fifo]'];

                h.TclCmdQueue{end+1}=[h.TclPrefix,'generate_target all [get_ips] -force'];
            end
        end


        function runHDLCompilation(h,varargin)
            if h.DispStat
                h.addStatus('Running HDL Compilation',1);
            end
            h.TclCmdQueue{end+1}=[h.TclPrefix,'launch_runs synth_1 -jobs ',num2str(feature('numthreads'))];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'wait_on_run synth_1'];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {  '];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'  error "ERROR: Synthesis failed" '];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'}'];
        end

        function runSynthesis(h,varargin)
            runProcess(h,'synth_1');
        end

        function runPlaceAndRoute(h,varargin)
            if h.DispStat
                h.addStatus('Running Implementation',1);
            end

            runProcess(h,'impl_1');
        end

        function runProcess(h,process)
            h.TclCmdQueue{end+1}=[h.TclPrefix,'launch_runs ',process,' -jobs ',num2str(feature('numthreads'))];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'wait_on_run ',process];
        end

        function runBitGeneration(h,varargin)
            if h.DispStat
                h.addStatus('Running BitGeneration',1);
            end
            runPlaceAndRoute(h);
            h.TclCmdQueue{end+1}=[h.TclPrefix,'open_run impl_1'];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'write_bitstream -force ',h.ProjectName];
        end

        function getTimingResult(h,rtnVar,varargin)
            validateattributes(rtnVar,{'char'},{'nonempty'});
            h.parseProjParam(varargin{:});

            if isempty(h.PARFile)
                error(message('EDALink:ISETclProjectManager:UndefinedPARFile'));
            end

            cmd=sprintf([...
'_#_open_run impl_1\n'...
            ,'_#_set par_str [report_timing_summary -return_string]\n'...
            ,'_#_set ',rtnVar,' ""\n'...
            ,'_#_set result [regexp {Timing constraints are not met} $par_str match]\n'...
            ,'_#_if {$result > 0} {\n'...
            ,'_#_	set ',rtnVar,' "Warning: Design does not meet all timing constraints."\n'...
            ,'_#_}\n']);
            h.TclCmdQueue{end+1}=strrep(cmd,'_#_',h.TclPrefix);

            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end
    end


    methods(Access=protected)

        function setProjectAction(h)
            h.initialize;
        end

        function addFullPathFiles_priv(h,filePath,fileType,fileLib,varargin)



            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Added Source Files:';
                end
                h.addStatus(str,2);
            end













            for n=1:length(filePath)
                if h.DispStat
                    h.addStatus(filePath{n},3);
                end

                file=strrep(filePath{n},'\','/');
                file=h.addPathQuote(file);


                if~strcmpi(fileType{n},'Tcl script')
                    file=['{',file,'}'];%#ok<AGROW> 
                end



                if strcmpi(fileType{n},'Tcl script')
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'source ',file];
                elseif~isempty(fileLib)&&~isempty(fileLib{n})
                    if strcmpi(fileType(n),'Verilog')
                        h.TclCmdQueue{end+1}=[h.TclPrefix,'read_verilog ',file];
                    else
                        h.TclCmdQueue{end+1}=[h.TclPrefix,'read_vhdl -library ',fileLib{n},' ',file];
                    end
                else
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'add_files -norecurse ',file];
                end
            end
        end


        function parseProcessParam(h,varargin)
            h.AssertProcErr=false;
            if mod(nargin,2)~=1
                error(message('EDALink:ISETclProjectManager:OddNumberInputArg'));
            end
            paramName='ProcessErrorAssertion';
            idx=find(strcmpi(paramName,varargin),1,'last');
            if~isempty(idx)

                if(mod(idx,2)~=1)
                    error(message('EDALink:ISETclProjectManager:ParamInEvenPos',paramName));
                end

                if~islogical(varargin{idx+1})
                    error(message('EDALink:ISETclProjectManager:InvalidParamValue',paramName));
                end

                h.AssertProcErr=varargin{idx+1};

                varargin(idx)=[];
                varargin(idx)=[];
            end
            h.parseProjParam(varargin{:});
        end

    end

end


