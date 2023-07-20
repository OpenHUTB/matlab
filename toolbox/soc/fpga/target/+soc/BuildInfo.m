classdef BuildInfo<handle




    properties
ProjectDir
Board
        ComponentList={}
Connections
SystemClk
SystemRstn
IPCoreClk
IPCoreRstn
MemPSClk
MemPSRstn
MemPLClk
MemPLRstn
ExternalIO
TopSystemName
SystemName
BitName
DUTName
MemPS
MemPL
DesignTclFile
ConstraintFile
        PreTclFile={'hsb_xil.tcl'}
Diagnostics
DiagnosticMode
TraceLogDepth
PS7
HPS
        FMCIO={}
        CustomIP={}
Vendor
ToolVersion
        ATGs={}
SynOption
IntfInfo
DiagMasterdw
MemMap
NumJobs
CustomBoardParams
FPGADesign
HasReferenceDesign
    end

    properties(Dependent)
InputClk
InputRst
Interconnect
Interrupt
    end

    methods

        function obj=BuildInfo(refSys,topSys,dut,prj_dir,varargin)

            p=inputParser;
            addParameter(p,'TopInfo',struct('comps',{}));
            addParameter(p,'Verbose',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            addParameter(p,'IntfInfo',containers.Map);
            addParameter(p,'MemMap','');
            addParameter(p,'NumJobs','');
            addParameter(p,'HasReferenceDesign',false);
            parse(p,varargin{:});

            top_comps=p.Results.TopInfo.comps;
            top_sys=p.Results.TopInfo.sys;
            verbose=p.Results.Verbose;
            obj.Vendor=soc.internal.getVendor(topSys);
            obj.IntfInfo=p.Results.IntfInfo;
            obj.MemMap=p.Results.MemMap;
            obj.NumJobs=p.Results.NumJobs;
            obj.HasReferenceDesign=p.Results.HasReferenceDesign;

            if isempty(refSys)
                sys=topSys;
            else
                sys=refSys;
            end
            obj.TopSystemName=topSys;
            obj.SystemName=sys;
            obj.DUTName=dut;
            obj.ProjectDir=prj_dir;
            if obj.HasReferenceDesign
                obj.Board.BoardID='';
                obj.Board.Name=get_param(obj.TopSystemName,'HardwareBoard');
            else

                obj.getConfigSet;

                switch obj.Vendor
                case 'Xilinx'
                    obj.BitName=[regexprep(obj.TopSystemName,'[\W]*','_'),'-',obj.Board.BoardID,'.bit'];
                case 'Intel'
                    obj.BitName=[regexprep(obj.TopSystemName,'[\W]*','_'),'-',obj.Board.BoardID,'.sof'];
                end


                obj.getClock(sys);

                obj.getMemPS(sys);

                obj.getMemPL(sys);

                obj.getCustomIP(sys);

                obj.getFMCIO(sys);

                obj.getProcessorSys(sys);
            end

            obj.ComponentList=top_comps;

            obj.getComponentList(sys,dut,top_sys);

            obj.ExternalIO=soc.util.getExternalIO(topSys,sys,obj.Board,verbose);
            if~obj.HasReferenceDesign

                obj.Connections=soc.util.getConnections(obj.Vendor,sys,dut,obj.IntfInfo);

                obj.addPerfMon(verbose);

                obj.updateIRQ;
            end
        end

        function getConfigSet(obj)
            cs=getActiveConfigSet(obj.TopSystemName);
            obj.FPGADesign=codertarget.data.getParameterValue(cs,'FPGADesign');


            boardName=get_param(obj.TopSystemName,'HardwareBoard');
            switch boardName
            case 'Artix-7 35T Arty FPGA evaluation kit'
                obj.Board=soc.xilboard.Arty;
            case 'Xilinx Zynq ZC706 evaluation kit'
                obj.Board=soc.xilboard.ZC706;
            case 'Xilinx Kintex-7 KC705 development board'
                obj.Board=soc.xilboard.KC705;
            case 'ZedBoard'
                obj.Board=soc.xilboard.ZedBoard;
            case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
                obj.Board=soc.xilboard.ZCU102;
            case 'Altera Arria 10 SoC development kit'
                obj.Board=soc.intelboard.Arria10SoC;
            case 'Altera Cyclone V SoC development kit'
                obj.Board=soc.intelboard.CycloneVSoC;
            case codertarget.internal.getCustomHardwareBoardNamesForSoC
                obj.CustomBoardParams=soc.internal.getCustomBoardParams(boardName);

                obj.Board=l_portBoardInfo(obj.CustomBoardParams);
            otherwise
                error(message('soc:msgs:customFPGANotSupportCheckGen'));
            end




            I2C_Master=find_system(obj.SystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hwlogiciolib/I2C Master');
            if(~isempty(I2C_Master))
                obj.SynOption='Global';
            else
                obj.SynOption='OOC';
            end


            switch obj.Vendor
            case 'Xilinx'
                obj.ConstraintFile='constr.xdc';
                if isempty(obj.CustomBoardParams)
                    obj.ToolVersion=soc.internal.getSupportedToolVersion('xilinx');
                else
                    obj.ToolVersion=obj.CustomBoardParams.fdesObj.SupportedToolVersion;
                end
                obj.DesignTclFile='system_bd.tcl';
            case 'Intel'
                obj.ConstraintFile.timingConstr='timing_constr.sdc';
                obj.ConstraintFile.pinConstr='pin_constr.tcl';
                obj.DesignTclFile.qsys='qsys_create_system.tcl';
                obj.DesignTclFile.quartus='quartus_create_prj.tcl';
                if isempty(obj.CustomBoardParams)
                    obj.ToolVersion=soc.internal.getSupportedToolVersion('intel');
                else
                    obj.ToolVersion=obj.CustomBoardParams.fdesObj.SupportedToolVersion;
                end
            end


            obj.Diagnostics=obj.FPGADesign.IncludeAXIInterconnectMonitor;

            obj.TraceLogDepth=obj.FPGADesign.NumberOfTraceEvents;

        end

        function getProcessorSys(obj,sys)

            if obj.FPGADesign.IncludeProcessingSystem
                memPS_addr=obj.MemMap.controllerInfo.memPSBaseAddr;
                memPS_range=obj.MemMap.controllerInfo.memPSRange;
                switch obj.Vendor
                case 'Xilinx'
                    hasHDMI=num2str(any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),obj.FMCIO)));
                    if isempty(obj.CustomBoardParams)
                        obj.PS7=soc.xilcomp.PS7(...
                        'board_name',obj.Board.Name,...
                        'memPS_addr',memPS_addr,...
                        'memPS_range',[memPS_range{:}],...
                        'hasMemPS',num2str(~isempty(obj.MemPS)),...
                        'hasHDMI',hasHDMI...
                        );
                    else
                        obj.PS7=l_portPSInfo(obj.CustomBoardParams,memPS_addr,[memPS_range{:}],~isempty(obj.MemPS));
                    end
                    if~isempty(obj.MemPS)
                        obj.MemPS.AXI4Slave=obj.PS7.AXI4Slave;
                    end
                case 'Intel'
                    if isempty(obj.CustomBoardParams)
                        switch obj.Board.BoardID
                        case 'c5soc'
                            obj.HPS=soc.intelcomp.CycloneVSoCHPS(...
                            'memPS_addr',memPS_addr,...
                            'memPS_range',[memPS_range{:}],...
                            'hasMemPS',num2str(~isempty(obj.MemPS))...
                            );
                        case 'a10soc'
                            obj.HPS=soc.intelcomp.Arria10SoCHPS(...
                            'memPS_addr',memPS_addr,...
                            'memPS_range',[memPS_range{:}],...
                            'hasMemPS',num2str(~isempty(obj.MemPS))...
                            );
                        end
                    else
                        obj.HPS=l_portHPSInfo(obj.CustomBoardParams,memPS_addr,[memPS_range{:}],~isempty(obj.MemPS));
                    end
                    if~isempty(obj.MemPS)
                        obj.MemPS.AXI4Slave=obj.HPS.AXI4Slave;
                    end

                end
            end
        end

        function getClock(obj,sys)

            obj.SystemClk.freq=num2str(obj.FPGADesign.AXILiteClock);
            obj.IPCoreClk.freq=num2str(obj.FPGADesign.AXIHDLUserLogicClock);

            switch obj.Vendor
            case 'Xilinx'

                obj.SystemClk.source='clkgen/clk_out1';
                obj.IPCoreClk.source='clkgen/clk_out2';
                obj.SystemRstn.source='sys_rstgen/peripheral_aresetn';
                obj.IPCoreRstn.source='ipcore_rstgen/peripheral_aresetn';
            case 'Intel'
                obj.SystemClk.source='altera_pll.outclk0';
                obj.IPCoreClk.source='altera_pll.outclk1';
                if isempty(obj.CustomBoardParams)
                    obj.SystemRstn.source=obj.InputRst.interface;
                    obj.IPCoreRstn.source=obj.InputRst.interface;
                else
                    obj.SystemRstn.source='sys_clk.clk_reset';
                    obj.IPCoreRstn.source='sys_clk.clk_reset';
                end
            end
        end

        function getMemPS(obj,sys)

            obj.MemPSClk.source='';
            obj.MemPSClk.freq='0';
            obj.MemPSRstn.source='';



            memBlkVec=[find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib_internal/Memory Controller');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4-Stream to Software');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Software to AXI4-Stream');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Random Access Memory');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Video Frame Buffer')];
            ATGBlks=find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Referenceblock','socmemlib/Memory Traffic Generator');
            memBlkVec=[memBlkVec;ATGBlks(strcmpi(get_param(ATGBlks,'ShowMemoryControllerPorts'),'off'))];

            memSelVec=get_param(memBlkVec,'MemorySelection');
            memPSPosVec=strcmpi(memSelVec,'PS memory');
            if any(memPSPosVec)
                obj.MemPS.Clk.freq=num2str(obj.FPGADesign.AXIMemorySubsystemClockPS);
                obj.MemPS.DataWidth=num2str(obj.FPGADesign.AXIMemorySubsystemDataWidthPS);
            else


                memCtrlBlkVec=find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller');
                memSelVec=get_param(memCtrlBlkVec,'MemorySelection');
                memPSPosVec=strcmpi(memSelVec,'PS memory');

                if any(memPSPosVec)

                    if nnz(memPSPosVec)>1
                        error('Only 1 PS memory allowed for targetting');
                    end

                    memPSPos=find(memPSPosVec);
                    memCtrlBlk=memCtrlBlkVec{memPSPos};
                    obj.MemPS.Clk.freq=soc.util.getValueString(memCtrlBlk,'ControllerFrequency');
                    obj.MemPS.DataWidth=soc.util.getValueString(memCtrlBlk,'ControllerDataWidth');
                else
                    return;
                end
            end

            switch obj.Vendor
            case 'Xilinx'
                obj.MemPS.Clk.source='clkgen/clk_out3';
                obj.MemPS.Rstn.source='mem_rstgen/peripheral_aresetn';
            case 'Intel'
                obj.MemPS.Clk.source='altera_pll.outclk2';
                if isempty(obj.CustomBoardParams)
                    obj.MemPS.Rstn.source=obj.InputRst.interface;
                else
                    obj.MemPS.Rstn.source='sys_clk.clk_reset';
                end
            end

            obj.MemPSClk=obj.MemPS.Clk;
            obj.MemPSRstn=obj.MemPS.Rstn;
        end

        function getMemPL(obj,sys)

            obj.MemPLClk.source='';
            obj.MemPLClk.freq='0';
            obj.MemPLRstn.source='';



            memBlkVec=[find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib_internal/Memory Controller');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4-Stream to Software');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Software to AXI4-Stream');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Random Access Memory');...
            find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/AXI4 Video Frame Buffer')];
            ATGBlks=find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Referenceblock','socmemlib/Memory Traffic Generator');
            memBlkVec=[memBlkVec;ATGBlks(strcmpi(get_param(ATGBlks,'ShowMemoryControllerPorts'),'off'))];

            memSelVec=get_param(memBlkVec,'MemorySelection');
            memPLPosVec=strcmpi(memSelVec,'PL memory');
            if any(memPLPosVec)
                mm_freq=num2str(obj.FPGADesign.AXIMemorySubsystemClockPL);
                mm_dw=num2str(obj.FPGADesign.AXIMemorySubsystemDataWidthPL);
            else


                memCtrlBlkVec=find_system(obj.TopSystemName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller');
                memSelVec=get_param(memCtrlBlkVec,'MemorySelection');
                memPLPosVec=strcmpi(memSelVec,'PL memory');

                if any(memPLPosVec)

                    if nnz(memPLPosVec)>1
                        error('Only 1 PL memory allowed for targetting');
                    end

                    memPLPos=find(memPLPosVec);
                    memCtrlBlk=memCtrlBlkVec{memPLPos};
                    mm_freq=soc.util.getValueString(memCtrlBlk,'ControllerFrequency');
                    mm_dw=soc.util.getValueString(memCtrlBlk,'ControllerDataWidth');
                else
                    return;
                end
            end


            memPL_addr=obj.MemMap.controllerInfo.memPLBaseAddr;
            memPL_range=obj.MemMap.controllerInfo.memPLRange;

            if isempty(obj.CustomBoardParams)

                switch obj.Board.BoardID
                case 'arty'
                    obj.MemPL=soc.xilcomp.MIGArty(...
                    'memPL_addr',memPL_addr,...
                    'memPL_range',[memPL_range{:}],...
                    'mm_dw',mm_dw...
                    );
                case 'zc706'
                    obj.MemPL=soc.xilcomp.MIGZC706(...
                    'memPL_addr',memPL_addr,...
                    'memPL_range',[memPL_range{:}],...
                    'mm_dw',mm_dw...
                    );
                case 'kc705'
                    obj.MemPL=soc.xilcomp.MIGKC705(...
                    'memPL_addr',memPL_addr,...
                    'memPL_range',[memPL_range{:}],...
                    'mm_dw',mm_dw...
                    );
                case 'zedboard'
                    error(message('soc:msgs:enablePSToUseExternalMemOnZedboard'))
                case 'zcu102'
                    obj.MemPL=soc.xilcomp.MIGZCU102(...
                    'memPL_addr',memPL_addr,...
                    'memPL_range',[memPL_range{:}],...
                    'mm_dw',mm_dw...
                    );
                case 'a10soc'
                    obj.MemPL=soc.intelcomp.Arria10SoCDDR4(...
                    'memPL_addr',memPL_addr,...
                    'memPL_range',[memPL_range{:}],...
                    'toolVersion',obj.ToolVersion,...
                    'topEntity','system_top'...
                    );
                    obj.SystemRstn.source=obj.InputRst.interface;
                    obj.IPCoreRstn.source=obj.InputRst.interface;
                case 'c5soc'
                    obj.MemPL=soc.intelcomp.CycloneVSoCDDR3(...
                    'memPL_addr',memPL_addr,...
                    'memPL_range',[memPL_range{:}],...
                    'toolVersion',obj.ToolVersion,...
                    'topEntity','system_top'...
                    );
                    obj.SystemRstn.source=obj.InputRst.interface;
                    obj.IPCoreRstn.source=obj.InputRst.interface;
                otherwise
                    error(message('soc:msgs:unableGetBoardName'));
                end
            else

                switch lower(obj.Vendor)
                case 'xilinx'
                    obj.MemPL=l_portMIGInfo(obj.CustomBoardParams,memPL_addr,[memPL_range{:}],mm_dw);
                case 'intel'
                    obj.MemPL=l_portEMIFInfo(obj.CustomBoardParams,memPL_addr,[memPL_range{:}]);
                end

            end

            obj.MemPLClk=obj.MemPL.ClkOutput;
            obj.MemPLRstn=obj.MemPL.RstnOutput;

        end

        function getCustomIP(obj,sys)





            [cstmIPBlks,internalCstmIPBlks]=soc.internal.findUniqueCustomIPBlks(sys);

            numClkOuts=0;
            if~isempty(cstmIPBlks)
                for nn=1:numel(cstmIPBlks)
                    fpgacomp=soc.xilcomp.CustomIP(internalCstmIPBlks{nn},obj.MemMap);
                    obj.CustomIP{end+1}=fpgacomp;
                    if~isempty(fpgacomp.CustomIPOutClk)
                        numClkOuts=numClkOuts+1;
                        obj.IPCoreClk.source=fpgacomp.CustomIPOutClk;

                        if~isempty(obj.MemPS)
                            obj.MemPSClk.source='clkgen/clk_out2';
                        end
                    end
                end
            end

            if numClkOuts>1
                error(message('soc:msgs:OneClkOutWithCustomIPs'));
            end
        end

        function getFMCIO(obj,sys)

            topSys=obj.TopSystemName;



            ad9361Rx_blk=find_system(topSys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReferenceBlock','xilinxsocad9361lib/AD9361Rx');
            ad9361Tx_blk=find_system(topSys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReferenceBlock','xilinxsocad9361lib/AD9361Tx');
            if isempty(ad9361Rx_blk)&&isempty(ad9361Tx_blk)&&~isempty(sys)


                ad9361Rx_blk=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'ReferenceBlock','xilinxsocad9361lib/AD9361Rx');
                ad9361Tx_blk=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'ReferenceBlock','xilinxsocad9361lib/AD9361Tx');
            end
            if(~isempty(ad9361Rx_blk)||~isempty(ad9361Tx_blk))

                [ad9361_addr,ad9361_range]=soc.memmap.getComponentAddress(obj.MemMap,'AD9361/S_AXI_AD9361');
                [ad9361i2c_addr,ad9361i2c_range]=soc.memmap.getComponentAddress(obj.MemMap,'AD9361/S_AXI_IIC');

                fpgacomp=soc.xilcomp.AD9361(...
                'board_name',obj.Board.Name,...
                'ad9361_addr',ad9361_addr,...
                'ad9361_range',[ad9361_range{:}],...
                'ad9361i2c_addr',ad9361i2c_addr,...
                'ad9361i2c_range',[ad9361i2c_range{:}]...
                );
                obj.FMCIO{end+1}=fpgacomp;

                obj.IPCoreClk.freq='61.44';
                obj.IPCoreClk.source='AD9361/clk';
                if~isempty(obj.MemPS)
                    obj.MemPSClk.source='clkgen/clk_out2';
                end
            end



            HDMIBlks=find_system(topSys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxsocvisionlib/HDMI Rx');
            if isempty(HDMIBlks)&&~isempty(sys)


                HDMIBlks=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxsocvisionlib/HDMI Rx');
            end
            if~isempty(HDMIBlks)

                [hdmi_addr,hdmi_range]=soc.memmap.getComponentAddress(obj.MemMap,'HDMI/S_AXI');
                [vtc_addr,vtc_range]=soc.memmap.getComponentAddress(obj.MemMap,'HDMI/ctrl');
                [s2mm_addr,s2mm_range]=soc.memmap.getComponentAddress(obj.MemMap,'axi_vdma_s2mm_2/s_axi');
                [mm2s_addr,mm2s_range]=soc.memmap.getComponentAddress(obj.MemMap,'axi_vdma_mm2s_2/s_axi');

                fpgacomp=soc.xilcomp.HDMIRx(...
                'board_name',obj.Board.Name,...
                'hdmi_addr',hdmi_addr,...
                'hdmi_range',[hdmi_range{:}],...
                'vtc_addr',vtc_addr,...
                'vtc_range',[vtc_range{:}],...
                'mm2s_addr',mm2s_addr,...
                'mm2s_range',[mm2s_range{:}],...
                's2mm_addr',s2mm_addr,...
                's2mm_range',[s2mm_range{:}],...
                'blkPath',HDMIBlks{1}...
                );
                obj.FMCIO{end+1}=fpgacomp;

                obj.IPCoreClk.freq=obj.FMCIO{1}.PixelClkFreq;
                obj.IPCoreClk.source='HDMI/hdmi_rx_clk';
                if~isempty(obj.MemPS)
                    obj.MemPS.Clk.source='clkgen/clk_out2';
                    obj.MemPSClk.source='clkgen/clk_out2';
                else
                    obj.MemPS.Clk.freq=num2str(obj.FPGADesign.AXIMemorySubsystemClockPS);
                    obj.MemPS.DataWidth=num2str(obj.FPGADesign.AXIMemorySubsystemDataWidthPS);
                    obj.MemPS.Clk.source='clkgen/clk_out2';
                    obj.MemPS.Rstn.source='mem_rstgen/peripheral_aresetn';
                    obj.MemPSClk=obj.MemPS.Clk;
                    obj.MemPSRstn=obj.MemPS.Rstn;
                end
            end



            rfDCBlk=find_system(topSys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxrfsoclib/RF Data Converter');
            if~isempty(rfDCBlk)
                [dev_addr,dev_range]=soc.memmap.getComponentAddress(obj.MemMap,'RFDataConverter/s_axi');
                fpgacomp=soc.xilcomp.RFDataConverter(...
                'board_name',obj.Board.Name,...
                'dev_addr',dev_addr,...
                'dev_range',[dev_range{:}]...
                );
                fpgacomp.Init(rfDCBlk{1},obj.ProjectDir);
                obj.FMCIO{end+1}=fpgacomp;

                obj.IPCoreClk.freq=num2str(fpgacomp.IPConfigInfo.streamClkFreq);
                obj.IPCoreClk.source='rfDCStreamClkGen/clk_out1';
                if~isempty(obj.MemPS)
                    obj.MemPSClk.source='clkgen/clk_out2';
                end
            end




            adau1761_blk=find_system(topSys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxsocaudiocodeclib/ADAU1761 Codec');
            if isempty(adau1761_blk)&&~isempty(sys)
                adau1761_blk=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxsocaudiocodeclib/ADAU1761 Codec');
            end
            if~isempty(adau1761_blk)
                fpgacomp=soc.xilcomp.SoC_ADAU1761('board_name',obj.Board.Name);
                obj.FMCIO{end+1}=fpgacomp;
            end



        end

        function getComponentList(obj,sys,dut,top_sys)
            if~isempty(dut)

                hsblib_blks=[...
                find_system(sys,'SearchDepth',1,'regexp','on','ReferenceBlock','^hsblib_beta2');...
                find_system(sys,'SearchDepth',1,'regexp','on','ReferenceBlock','^hsbhdllib');...
                find_system(sys,'SearchDepth',1,'regexp','on','ReferenceBlock','^hwlogicconnlib');...
                find_system(sys,'SearchDepth',1,'regexp','on','ReferenceBlock','^hwlogiciolib')];
                for i=1:numel(hsblib_blks)
                    this_comp=soc.util.blk2fpgacomp(obj.MemMap,obj.Vendor,hsblib_blks{i});
                    if~isempty(this_comp)
                        obj.ComponentList{end+1}=this_comp;
                    end
                end


                DutDatawidth=[];
                for i=1:numel(dut)
                    ipcore_name=soc.util.getIPCoreName([sys,'/',dut{i}]);
                    ipcore_ver=soc.util.getIPCoreVersion([sys,'/',dut{i}]);


                    if strcmpi(obj.Vendor,'xilinx')
                        this_dut_comp=soc.xilcomp.DUT(ipcore_name,ipcore_ver);
                        this_dut_comp.BlkName=[sys,'/',dut{i}];
                        [dev_addr,dev_range]=soc.memmap.getComponentAddress(obj.MemMap,get_param(this_dut_comp.BlkName,'name'));
                        this_dut_comp.addAXI4Slave([ipcore_name,'/AXI4_Lite'],'reg','ipcore',dev_addr,[dev_range{:}]);
                    else
                        this_dut_comp=soc.intelcomp.DUT(ipcore_name,ipcore_ver);
                        this_dut_comp.BlkName=[sys,'/',dut{i}];
                        [dev_addr,dev_range]=soc.memmap.getComponentAddress(obj.MemMap,get_param(this_dut_comp.BlkName,'name'));
                        this_dut_comp.addAXI4Slave([ipcore_name,'.s_axi'],'reg','ipcore',dev_addr);
                    end

                    this_blk=[sys,'/',dut{i}];
                    inp=find_system(this_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
                    outp=find_system(this_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
                    dut_ports=[inp;outp];
                    dutPortH=get_param(this_blk,'porthandles');
                    dutInOutPortH=[dutPortH.Inport,dutPortH.Outport];
                    m_axi_list={};
                    dut_intf_list={};
                    intf_dw={};
                    intf_memtype={};

                    for ii=1:numel(dut_ports)
                        if isKey(obj.IntfInfo,dut_ports{ii})
                            thisPortIntfInfo=obj.IntfInfo(dut_ports{ii});
                            port_intf=thisPortIntfInfo.interface;
                            if~isempty(port_intf)
                                if contains(port_intf,'AXI4 Master')
                                    intf_name=strrep(port_intf,' Read','');
                                    intf_name=strrep(intf_name,' Write','');
                                    intf_name=regexprep(intf_name,' ','_');
                                    intf_dw{end+1}=thisPortIntfInfo.dataWidth;%#ok<AGROW> 
                                    intf_memtype{end+1}=thisPortIntfInfo.memType;%#ok<AGROW> 


                                    if strcmpi(obj.Vendor,'xilinx')
                                        m_axi_list{end+1}=[ipcore_name,'/',intf_name];%#ok<AGROW>
                                    else
                                        m_axi_list{end+1}=[ipcore_name,'.',intf_name];%#ok<AGROW>
                                    end
                                    dut_intf_list{end+1}=port_intf;%#ok<AGROW>
                                elseif contains(port_intf,'AXI4-Stream')
                                    dut_intf_list{end+1}=port_intf;%#ok<AGROW>
                                end
                            end
                            if~isempty(thisPortIntfInfo.interfacePort)&&strcmpi(thisPortIntfInfo.interfacePort,'interrupt')
                                portName=get_param(dut_ports{ii},'name');
                                portName=regexprep(portName,'[\W]*','_');
                                if strcmpi(obj.Vendor,'xilinx')
                                    this_dut_comp.addInterrupt([ipcore_name,'/',portName]);
                                else
                                    this_dut_comp.addInterrupt([ipcore_name,'.',portName]);
                                end
                                if numel(this_dut_comp.Interrupt)~=1
                                    error(message('soc:msgs:OneIntrPortPerDUT',this_dut_comp.BlkName));
                                end
                                this_dut_comp.Interrupt.irq_num=thisPortIntfInfo.intrChPortNum;
                                this_dut_comp.Interrupt.triggerType=thisPortIntfInfo.triggerType;
                            end
                        end
                    end

                    [m_axi_list,idx]=unique(m_axi_list);
                    intf_dw=intf_dw(idx);
                    intf_memtype=intf_memtype(idx);
                    for ii=1:numel(m_axi_list)
                        this_dut_comp.addAXI4Master(m_axi_list{ii},intf_memtype{ii},'ipcore');
                        DutDatawidth=[DutDatawidth,str2double(intf_dw{ii})];
                    end
                    this_dut_comp.AXIInterface=unique(dut_intf_list);
                    obj.ComponentList{end+1}=this_dut_comp;
                end
            end


            cs=getActiveConfigSet(bdroot(top_sys));
            if codertarget.data.getParameterValue(cs,'FPGADesign.IncludeJTAGMaster')
                if strcmpi(obj.Vendor,'xilinx')
                    fpgacomp=soc.xilcomp.JTAGMaster;
                else
                    fpgacomp=soc.intelcomp.JTAGMaster;
                end
                obj.ComponentList{end+1}=fpgacomp;
            end


            if obj.Diagnostics

                [fastest_clock,freq]=obj.getFastestClock;
                obj.DiagMasterdw=[];
                dutIndx=0;
                for componentIndex=1:numel(obj.ComponentList)
                    if(~isempty(obj.ComponentList{componentIndex}.Configuration)&&...
                        ~isempty(obj.ComponentList{componentIndex}.AXI4Master))
                        fieldNames=fieldnames(obj.ComponentList{componentIndex}.Configuration);
                        Index=find(contains(fieldNames,'mm_dw'));
                        for interfaceIndex=1:length(Index)
                            memInterface=fieldNames{Index(interfaceIndex)};
                            if any(strcmpi(obj.ComponentList{componentIndex}.AXI4Master(interfaceIndex).usage,{'memPS','memPL'}))
                                obj.DiagMasterdw=[obj.DiagMasterdw,str2double(obj.ComponentList{componentIndex}.Configuration.(memInterface))];
                            end
                        end
                    elseif(~isempty(obj.ComponentList{componentIndex}.AXI4Master))&&any(contains(fieldnames(obj.ComponentList{componentIndex}),'AXIInterface'))
                        for ii=1:numel(obj.ComponentList{componentIndex}.AXI4Master)
                            dutIndx=dutIndx+1;
                            obj.DiagMasterdw=[obj.DiagMasterdw,DutDatawidth(dutIndx)];
                        end
                    end
                end
                if strcmpi(obj.Vendor,'xilinx')
                    [dev_addr,dev_range]=soc.memmap.getComponentAddress(obj.MemMap,'APM');
                    fpgacomp=soc.xilcomp.APM(...
                    'dev_addr',dev_addr,...
                    'dev_range',[dev_range{:}],...
                    'clock',[fastest_clock,'Clk'],...
                    'rstn',[fastest_clock,'Rstn'],...
                    'fifo_size',num2str(obj.TraceLogDepth)...
                    );
                    fpgacomp.SlotDw=obj.DiagMasterdw;
                    fpgacomp.CoreFrequency=freq;
                else
                    [dev_addr,dev_range]=soc.memmap.getComponentAddress(obj.MemMap,'APM');
                    fpgacomp=soc.intelcomp.APM(...
                    'dev_addr',dev_addr,...
                    'dev_range',[dev_range{:}],...
                    'clock',[fastest_clock,'Clk'],...
                    'rstn',[fastest_clock,'Rstn'],...
                    'fifo_size',num2str(obj.TraceLogDepth)...
                    );
                    fpgacomp.SlotDw=obj.DiagMasterdw;
                    fpgacomp.CoreFrequency=freq;
                end
                obj.ComponentList{end+1}=fpgacomp;
            end
        end

        function[fastest_clock,freq]=getFastestClock(obj)
            clocks={'MemPL','MemPS','System','IPCore'};
            clkFreqs=zeros(numel(clocks),1);
            for nn=1:numel(clocks)
                clkFreqs(nn)=str2num(obj.([clocks{nn},'Clk']).freq);%#ok<ST2NM>
            end
            [~,maxClkIdx]=max(clkFreqs);
            fastest_clock=char(clocks(maxClkIdx));
            freq=num2str(clkFreqs(maxClkIdx));
        end

        function result=get.InputClk(obj)
            result=obj.Board.InputClk;
        end
        function result=get.InputRst(obj)
            result=obj.Board.InputRst;
        end
        function result=get.Interconnect(obj)
            switch obj.Vendor
            case 'Xilinx'
                result.slave=struct('name',{},'usage',{},'clk_rstn',{},'offset',{},'range',{});
                result.master=struct('name',{},'usage',{},'clk_rstn',{});
                for i=1:numel(obj.ComponentList)
                    result.slave=[result.slave,obj.ComponentList{i}.AXI4Slave];
                end
                if~isempty(obj.MemPL)
                    result.slave=[result.slave,obj.MemPL.AXI4Slave];
                end
                if~isempty(obj.FMCIO)
                    for nn=1:numel(obj.FMCIO)
                        result.slave=[result.slave,obj.FMCIO{nn}.AXI4Slave];
                    end
                end

                if~isempty(obj.CustomIP)
                    for nn=1:numel(obj.CustomIP)
                        result.slave=[result.slave,obj.CustomIP{nn}.AXI4Slave];
                    end
                end


                for i=1:numel(obj.ComponentList)
                    result.master=[result.master,obj.ComponentList{i}.AXI4Master];
                end
                if~isempty(obj.PS7)
                    result.master=[result.master,obj.PS7.AXI4Master];
                end
            case 'Intel'
                result.slave=struct('name',{},'usage',{},'clkRstn',{},'offset',{});
                result.master=struct('name',{},'usage',{},'clkRstn',{});
                for i=1:numel(obj.ComponentList)
                    result.slave=[result.slave,obj.ComponentList{i}.AXI4Slave];
                end
                if~isempty(obj.MemPL)
                    result.slave=[result.slave,obj.MemPL.AXI4Slave];
                end
                for i=1:numel(obj.ComponentList)
                    result.master=[result.master,obj.ComponentList{i}.AXI4Master];
                end
                if~isempty(obj.HPS)
                    result.master=[result.master,obj.HPS.AXI4Master];
                    result.slave=[result.slave,obj.HPS.AXI4Slave];
                end
            end
            if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),obj.FMCIO))
                for nn=1:numel(obj.FMCIO)
                    if isa(obj.FMCIO{nn},'soc.xilcomp.HDMIRx')
                        result.master=[result.master,obj.FMCIO{nn}.AXI4Master];
                    end
                end
            end
        end
        function result=get.Interrupt(obj)
            result=struct('name',{},'irq_num',{},'triggerType',{});
            for i=1:numel(obj.ComponentList)
                result=[result,obj.ComponentList{i}.Interrupt];
            end
            for i=1:numel(obj.FMCIO)
                result=[result,obj.FMCIO{i}.Interrupt];
            end
        end
        function result=get.ATGs(obj)
            result={};
            for nn=1:numel(obj.ComponentList)
                this_comp=obj.ComponentList{nn};
                if isa(this_comp,'soc.xilcomp.ATG')
                    result{end+1}=this_comp;%#ok<AGROW>
                end
            end
        end
        function addPerfMon(obj,verbose)
            if obj.Diagnostics

                perMonIdx=cellfun(@(x)isa(x,'soc.xilcomp.APM')||isa(x,'soc.intelcomp.APM'),obj.ComponentList);
                perfMonComp=obj.ComponentList{perMonIdx};

                for i=1:numel(obj.ComponentList)
                    for j=1:numel(obj.ComponentList{i}.AXI4Master)
                        if any(strcmpi(obj.ComponentList{i}.AXI4Master(j).usage,{'memPS','memPL'}))

                            obj.ComponentList{i}.AXI4Master(j).name=addSlot(perfMonComp,obj.ComponentList{i}.AXI4Master(j),...
                            obj.ComponentList{i}.Configuration,verbose);
                        end
                    end
                end
            end
        end
        function updateIRQ(obj)




            if~isempty(obj.PS7)||~isempty(obj.HPS)
                intrCnt=0;

                intrCnt=intrCnt+any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),obj.FMCIO));

                dmaCnctInfo=containers.Map;
                indx=find(cellfun(@(x)isa(x,'soc.xilcomp.DMAWrite')||isa(x,'soc.xilcomp.DMARead')||...
                isa(x,'soc.intelcomp.DMAWrite')||isa(x,'soc.intelcomp.DMARead'),obj.ComponentList));

                hwDMAIndx=arrayfun(@(x)strcmpi(get_param(obj.ComponentList{x}.BlkName,'ChannelType'),'AXI4-Stream FIFO'),indx);
                indx(hwDMAIndx)=[];

                for i=1:numel(indx)
                    if ismember(get_param(obj.ComponentList{indx(i)}.BlkName,'Referenceblock'),{'socmemlib/Memory Channel'})
                        if isa(obj.ComponentList{indx(i)},'soc.xilcomp.DMAWrite')||isa(obj.ComponentList{indx(i)},'soc.intelcomp.DMAWrite')
                            memChPortName='rdEvent';
                        else
                            memChPortName='wrEvent';
                        end
                    else
                        memChPortName='event';
                    end
                    [memChEvntDstBlk,portName]=soc.util.getMemChEvDst(obj.ComponentList{indx(i)}.BlkName,memChPortName);
                    if~isempty(memChEvntDstBlk)
                        if strcmpi(get_param(memChEvntDstBlk,'blocktype'),'SubSystem')
                            blkLibInfo=libinfo(memChEvntDstBlk,'searchdepth',0);
                            portNum=str2double(get_param([memChEvntDstBlk,'/',portName],'port'));
                            dmaCnctInfo(obj.ComponentList{indx(i)}.BlkName)=struct('blkRef',blkLibInfo.ReferenceBlock,'portNum',portNum);
                        elseif strcmpi(get_param(memChEvntDstBlk,'blocktype'),'Terminator')

                            dmaCnctInfo(obj.ComponentList{indx(i)}.BlkName)=struct('blkRef','proctasklib/Task Manager','portNum',[]);
                        else
                            error(message('soc:msgs:InvalidMemChEvntConn',[obj.ComponentList{indx(i)}.BlkName,'/',memChPortName]));
                        end
                    else

                        dmaCnctInfo(obj.ComponentList{indx(i)}.BlkName)=struct('blkRef','proctasklib/Task Manager','portNum',[]);
                    end
                end


                for i=1:numel(indx)
                    obj.ComponentList{indx(i)}=obj.ComponentList{indx(i)};
                    if strcmpi(dmaCnctInfo(obj.ComponentList{indx(i)}.BlkName).blkRef,'proctasklib/Task Manager')
                        obj.ComponentList{indx(i)}.Interrupt.irq_num=intrCnt;
                        intrCnt=intrCnt+1;
                    end
                end


                for i=1:numel(indx)
                    obj.ComponentList{indx(i)}=obj.ComponentList{indx(i)};
                    if strcmpi(dmaCnctInfo(obj.ComponentList{indx(i)}.BlkName).blkRef,'socmemlib/Interrupt Channel')
                        obj.ComponentList{indx(i)}.Interrupt.irq_num=intrCnt+dmaCnctInfo(obj.ComponentList{indx(i)}.BlkName).portNum-1;
                    end
                end


                for i=1:numel(obj.ComponentList)
                    if~isa(obj.ComponentList{i},'soc.xilcomp.DMAWrite')&&...
                        ~isa(obj.ComponentList{i},'soc.xilcomp.DMARead')&&...
                        ~isa(obj.ComponentList{i},'soc.intelcomp.DMAWrite')&&...
                        ~isa(obj.ComponentList{i},'soc.intelcomp.DMARead')&&...
                        ~isempty(obj.ComponentList{i}.Interrupt)
                        obj.ComponentList{i}.Interrupt.irq_num=intrCnt+obj.ComponentList{i}.Interrupt.irq_num-1;
                    end
                end
            end
        end
    end
end



function ret=l_portBoardInfo(customBoardInfo)

    ret.Name=customBoardInfo.fdevObj.BoardName;
    ret.BoardID=matlab.lang.makeValidName(ret.Name);
    ret.DeviceFamily=customBoardInfo.fdevObj.FPGAFamily;
    ret.Device=customBoardInfo.fdevObj.FPGAPartNumber;
    if numel(customBoardInfo.fdevObj.ExternalClockSource.FPGAPins)==2
        clockType='diff';
    else
        clockType='single';
    end
    ret.InputClk=struct(...
    'source',customBoardInfo.fdevObj.ExternalClockSource.Name,...
    'freq',num2str(customBoardInfo.fdevObj.ExternalClockSource.Frequency),...
    'type',clockType,...
    'std',customBoardInfo.fdevObj.ExternalClockSource.IOPadConstraints,...
    'pin',{customBoardInfo.fdevObj.ExternalClockSource.FPGAPins});
    ret.InputRst=struct(...
    'source',customBoardInfo.fdevObj.ExternalResetSource.Name,...
    'interface',[ret.InputClk.source,'.clk_reset'],...
    'polarity',customBoardInfo.fdevObj.ExternalResetSource.Polarity,...
    'std',customBoardInfo.fdevObj.ExternalResetSource.IOPadConstraints,...
    'pin',customBoardInfo.fdevObj.ExternalResetSource.FPGAPins);
    for i=1:numel(customBoardInfo.fdevObj.externalIOInterfaces)

        numIOs=numel(customBoardInfo.fdevObj.externalIOInterfaces(i).FPGAPins);
        descStr=cell(1,numIOs);
        padStr=cell(1,numIOs);
        if numel(customBoardInfo.fdevObj.externalIOInterfaces(i).Name)~=numIOs
            if numel(customBoardInfo.fdevObj.externalIOInterfaces(i).Name)==1
                for j=1:numIOs
                    descStr{j}=[customBoardInfo.fdevObj.externalIOInterfaces(i).Name{1},'_',num2str(j-1)];
                end
            else
                error('number of IO names does not match number of pins')
            end
        else
            descStr=customBoardInfo.fdevObj.externalIOInterfaces(i).Name;
        end

        if numel(customBoardInfo.fdevObj.externalIOInterfaces(i).IOPadConstraints)~=numIOs
            if numel(customBoardInfo.fdevObj.externalIOInterfaces(i).IOPadConstraints)==1
                for j=1:numIOs
                    padStr{j}=customBoardInfo.fdevObj.externalIOInterfaces(i).IOPadConstraints{1};
                end
            else
                error('number of IO Pad Constraints does not match number of pins')
            end
        else
            padStr=customBoardInfo.fdevObj.externalIOInterfaces(i).IOPadConstraints;
        end

        switch customBoardInfo.fdevObj.externalIOInterfaces(i).Kind
        case 'LEDs'
            pv='LED';
        case 'PushButtons'
            pv='PushButton';
        case 'DIPSwitches'
            pv='DIPSwitch';
        case 'Custom'
        end
        ret.(pv)=struct(...
        'desc',descStr,...
        'std',padStr,...
        'pin',customBoardInfo.fdevObj.externalIOInterfaces(i).FPGAPins);
    end
    if isfield(customBoardInfo.fdevObj.ExternalMemorySize,'PSMemSize')
        ret.PSDDRSize=customBoardInfo.fdevObj.ExternalMemorySize.PSMemSize;
    else
        ret.PSDDRSize=[];
    end
end

function ret=l_portPSInfo(customBoardInfo,memPS_addr,memPS_range,hasMemPS)
    p=inputParser;
    addParameter(p,'TclFile',@ischar);
    addParameter(p,'ConstraintFile',@ischar);
    addParameter(p,'PSToPLInterface',@ischar);
    addParameter(p,'PSToPLInterfaceClock',@ischar);
    addParameter(p,'PSToPLInterfaceReset',@ischar);
    addParameter(p,'PLToPSInterface',@ischar);
    addParameter(p,'PLToPSInterfaceClock',@ischar);
    addParameter(p,'PLToPSInterfaceReset',@ischar);
    addParameter(p,'InterruptInterface',@ischar);
    addParameter(p,'ClockOutputPort',@ischar);
    addParameter(p,'ClockOutputFrequency',@isnumeric);
    addParameter(p,'ResetOutputPort',@ischar);
    parse(p,customBoardInfo.fdesObj.CustomDesignTclHooks.ProcessingSystem{:});
    ret.AXI4Master=struct('name',p.Results.PSToPLInterface,'usage','reg','clk_rstn','sys');
    if~isempty(p.Results.PLToPSInterface)
        ret.AXI4Slave=struct('name',p.Results.PLToPSInterface,'usage','memPS','clk_rstn','memPS','offset',memPS_addr,'range',memPS_range);
    end
    tclFile=soc.internal.replaceToken(p.Results.TclFile,customBoardInfo.fdevObj.BoardName);
    ret.Instance=[strrep(fileread(tclFile),'\','\\'),newline];
    constrFile=soc.internal.replaceToken(p.Results.ConstraintFile,customBoardInfo.fdevObj.BoardName);
    if~isempty(constrFile)
        ret.Constraint=[strrep(fileread(constrFile),'\','\\'),newline];
    else
        ret.Constraint='';
    end
    ret.InterruptInterface=p.Results.InterruptInterface;
    ret.InstancePost='';
    ret.Clk=struct('name',p.Results.PSToPLInterfaceClock,'driver','SystemClk');
    ret.Rst='';
    if~isempty(p.Results.PLToPSInterfaceClock)
        if hasMemPS
            ret.Clk=[ret.Clk,struct('name',p.Results.PLToPSInterfaceClock,'driver','MemPSClk')];
        else
            ret.Clk=[ret.Clk,struct('name',p.Results.PLToPSInterfaceClock,'driver','SystemClk')];
        end
    end
    ret.ClockOutputPort=p.Results.ClockOutputPort;
    ret.ClockOutputFrequency=p.Results.ClockOutputFrequency;
    ret.ResetOutputPort=p.Results.ResetOutputPort;
end

function ret=l_portMIGInfo(customBoardInfo,memPL_addr,memPL_range,mm_dw)
    p=inputParser;
    addParameter(p,'TclFile',@ischar);
    addParameter(p,'ConstraintFile',@ischar);
    addParameter(p,'AXI4SlaveInterface',@ischar);
    addParameter(p,'AXI4SlaveInterfaceReset',@ischar);
    addParameter(p,'AXI4SlaveInterfaceFrequency',@ischar);

    addParameter(p,'MemoryInterfaceClockOutput',@ischar);
    addParameter(p,'MemoryInterfaceResetOutput',@ischar);
    addParameter(p,'MemorySize',@ischar);

    parse(p,customBoardInfo.fdesObj.CustomDesignTclHooks.MemoryController{:});

    ret.Configuration.mm_dw=mm_dw;
    ret.ClkOutput.source=p.Results.MemoryInterfaceClockOutput;
    ret.ClkOutput.freq=num2str(p.Results.AXI4SlaveInterfaceFrequency,'%6.10f');
    ret.RstnOutput.source='mig_sys_reset/peripheral_aresetn';
    ret.AXI4Slave=struct('name',p.Results.AXI4SlaveInterface,'usage','memPL','clk_rstn','memPL','offset',memPL_addr,'range',memPL_range);
    tclFile=soc.internal.replaceToken(p.Results.TclFile,customBoardInfo.fdevObj.BoardName);
    ret.Instance=['set MEMCTRLDW ',mm_dw,newline];
    ret.Instance=[ret.Instance,strrep(fileread(tclFile),'\','\\'),newline];
    ret.Instance=[...
    ret.Instance...
    ,'  # Create instance: mig_sys_reset, and set properties\n',...
    '  set mig_sys_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 mig_sys_reset ]\n',...
    '  hsb_connect mig_sys_reset/slowest_sync_clk ',p.Results.MemoryInterfaceClockOutput,'\n',...
    '  hsb_connect mig_sys_reset/ext_reset_in ',p.Results.MemoryInterfaceResetOutput,'\n',...
    '  hsb_connect mig_sys_reset/peripheral_aresetn ',p.Results.AXI4SlaveInterfaceReset,'\n',...
    '\n',...
    ];
    xdcFile=soc.internal.replaceToken(p.Results.ConstraintFile,customBoardInfo.fdevObj.BoardName);
    if isfile(xdcFile)
        ret.Constraint=[strrep(fileread(xdcFile),'\','\\'),newline];
    else
        ret.Constraint='';
    end
    ret.Clk='';
    ret.Rst='';
end

function ret=l_portHPSInfo(customBoardInfo,memPS_addr,memPS_range,hasMemPS)
    p=inputParser;
    addParameter(p,'TclFile',@ischar);
    addParameter(p,'ConstraintFile',@ischar);
    addParameter(p,'PSToPLInterface',@ischar);
    addParameter(p,'PSToPLInterfaceClock',@ischar);
    addParameter(p,'PSToPLInterfaceReset',@ischar);
    addParameter(p,'PLToPSInterface',@ischar);
    addParameter(p,'PLToPSInterfaceClock',@ischar);
    addParameter(p,'PLToPSInterfaceReset',@ischar);
    addParameter(p,'InterruptInterface',@ischar);
    parse(p,customBoardInfo.fdesObj.CustomDesignTclHooks.ProcessingSystem{:});
    ret.AXI4Master=struct('name',p.Results.PSToPLInterface,'usage','reg','clkRstn','sys');
    if hasMemPS
        ret.AXI4Slave=struct('name',p.Results.PLToPSInterface,'usage','memPS','clkRstn','memPS','offset',memPS_addr);
    end
    tclFile=soc.internal.replaceToken(p.Results.TclFile,customBoardInfo.fdevObj.BoardName);
    ret.Instance=[strrep(fileread(tclFile),'\','\\'),newline];
    xdcFile=soc.internal.replaceToken(p.Results.ConstraintFile,customBoardInfo.fdevObj.BoardName);
    if isfile(xdcFile)
        ret.Constraint=[strrep(fileread(xdcFile),'\','\\'),newline];
    else
        ret.Constraint='';
    end
    ret.InterruptInterface=p.Results.InterruptInterface;
    ret.InstancePost='';
    ret.Clk=struct('name',p.Results.PSToPLInterfaceClock,'driver','SystemClk');
    ret.Rst=struct('name',p.Results.PSToPLInterfaceReset,'driver','SystemRstn');
    if~isempty(p.Results.PLToPSInterfaceClock)
        if hasMemPS
            ret.Clk=[ret.Clk,struct('name',p.Results.PLToPSInterfaceClock,'driver','MemPSClk')];
            ret.Rst=[ret.Rst,struct('name',p.Results.PLToPSInterfaceReset,'driver','MemPSRstn')];
        else
            ret.Clk=[ret.Clk,struct('name',p.Results.PLToPSInterfaceClock,'driver','SystemClk')];
            ret.Rst=[ret.Rst,struct('name',p.Results.PLToPSInterfaceReset,'driver','SystemRstn')];
        end
    end
end

function ret=l_portEMIFInfo(customBoardInfo,memPL_addr,memPL_range)
    p=inputParser;
    addParameter(p,'TclFile',@ischar);
    addParameter(p,'ConstraintFile',@ischar);
    addParameter(p,'AXI4SlaveInterface',@ischar);
    addParameter(p,'AXI4SlaveInterfaceReset',@ischar);
    addParameter(p,'AXI4SlaveInterfaceFrequency',@ischar);

    addParameter(p,'MemoryInterfaceClockOutput',@ischar);
    addParameter(p,'MemoryInterfaceResetOutput',@ischar);
    addParameter(p,'MemorySize',@ischar);

    parse(p,customBoardInfo.fdesObj.CustomDesignTclHooks.MemoryController{:});

    ret.ClkOutput.source=p.Results.MemoryInterfaceClockOutput;
    ret.ClkOutput.freq=num2str(p.Results.AXI4SlaveInterfaceFrequency);
    ret.RstnOutput.source='sys_clk.clk_reset';
    ret.AXI4Slave=struct('name',p.Results.AXI4SlaveInterface,'usage','memPL','clkRstn','memPL','offset',memPL_addr);
    tclFile=soc.internal.replaceToken(p.Results.TclFile,customBoardInfo.fdevObj.BoardName);
    ret.Instance=[strrep(fileread(tclFile),'\','\\'),newline];
    xdcFile=soc.internal.replaceToken(p.Results.ConstraintFile,customBoardInfo.fdevObj.BoardName);
    if isfile(xdcFile)
        ret.Constraint=[strrep(fileread(xdcFile),'\','\\'),newline];
    else
        ret.Constraint='';
    end
    ret.Clk='';
    ret.Rst=struct('name',p.Results.AXI4SlaveInterfaceReset,'driver','InputRst');
end

function blk=getConnBlkInTop(sys,fpgaPortName)
    blk='';
    [fpgaModelBlock,~]=soc.util.getHSBSubsystem(sys);

    if~isempty(fpgaModelBlock)

        hsbSubsysTop=fpgaModelBlock;
        mdlRefParent=get_param(fpgaModelBlock,'Parent');
        if~strcmp(mdlRefParent,sys)
            hsbSubsysTop=mdlRefParent;
            blkPortH=get_param(hsbSubsysTop,'porthandles');
            portName=get_param(fpgaPortName,'name');
            portType=get_param(fpgaPortName,'blocktype');
            hsbSubSysPorts=find_system(hsbSubsysTop,'Searchdepth',1,'lookundermasks','on','blocktype',portType);
            hsbSubSysPortNames=strtrim(get_param(hsbSubSysPorts,'name'));
            variantPort=hsbSubSysPorts(strcmp(hsbSubSysPortNames,portName));
            portNum=str2double(get_param(variantPort,'port'));

            if strcmpi(portType,'Inport')
                blk=soc.util.getSrcBlk(get_param(blkPortH.Inport(portNum),'line'));
            elseif strcmpi(portType,'Outport')
                blk=soc.util.getDstBlk(get_param(blkPortH.Outport(portNum),'line'));
            end
        else
            blkPortH=get_param(hsbSubsysTop,'porthandles');
            portNum=str2double(get_param(fpgaPortName,'port'));
            portType=get_param(fpgaPortName,'blocktype');
            if strcmpi(portType,'Inport')
                blk=soc.util.getSrcBlk(get_param(blkPortH.Inport(portNum),'line'));
            elseif strcmpi(portType,'Outport')
                blk=soc.util.getDstBlk(get_param(blkPortH.Outport(portNum),'line'));
            end
        end
    end
end
