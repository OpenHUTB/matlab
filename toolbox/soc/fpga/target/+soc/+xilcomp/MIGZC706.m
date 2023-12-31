classdef MIGZC706<soc.xilcomp.MIGBase
    properties
    end

    methods
        function obj=MIGZC706(varargin)

            obj.Configuration={...
            'memPL_addr','0x00000000',...
            'memPL_range','0',...
            'mm_dw','32',...
            };

            if nargin>0
                obj.Configuration=varargin;
            end


            obj.addClk('mig_7series_0/SYS_CLK','InputClk')
            obj.addRst('mig_7series_0/sys_rst','InputRst');


            obj.ClkOutput.source='mig_7series_0/ui_clk';
            obj.ClkOutput.freq='200';
            obj.RstnOutput.source='mig_sys_reset/peripheral_aresetn';


            obj.addAXI4Slave('mig_7series_0/S_AXI','memPL','memPL',obj.Configuration.memPL_addr,obj.Configuration.memPL_range);


            obj.Instance=[...
            'create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk\n',...
            'set_property CONFIG.FREQ_HZ 200000000 [get_bd_intf_ports sys_clk]\n',...
            'create_bd_port -dir I -type rst   sys_rst\n',...
            'set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports sys_rst]\n',...
            'proc write_mig_file_design_1_mig_7series_0_0 { str_mig_prj_filepath } {\n',...
            '\n',...
            '   set mig_prj_file [open $str_mig_prj_filepath  w+]\n',...
            '\n',...
            '   puts $mig_prj_file {<?xml version=''1.0'' encoding=''UTF-8''?>}\n',...
            '   puts $mig_prj_file {<!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}\n',...
            '   puts $mig_prj_file {<Project NoOfControllers="1" >}\n',...
            '   puts $mig_prj_file {    <ModuleName>design_1_mig_7series_0_0</ModuleName>}\n',...
            '   puts $mig_prj_file {    <dci_inouts_inputs>1</dci_inouts_inputs>}\n',...
            '   puts $mig_prj_file {    <dci_inputs>1</dci_inputs>}\n',...
            '   puts $mig_prj_file {    <Debug_En>OFF</Debug_En>}\n',...
            '   puts $mig_prj_file {    <DataDepth_En>1024</DataDepth_En>}\n',...
            '   puts $mig_prj_file {    <LowPower_En>ON</LowPower_En>}\n',...
            '   puts $mig_prj_file {    <XADC_En>Enabled</XADC_En>}\n',...
            '   puts $mig_prj_file {    <TargetFPGA>xc7z045-ffg900/-2</TargetFPGA>}\n',...
            '   puts $mig_prj_file {    <Version>4.2</Version>}\n',...
            '   puts $mig_prj_file {    <SystemClock>Differential</SystemClock>}\n',...
            '   puts $mig_prj_file {    <ReferenceClock>Use System Clock</ReferenceClock>}\n',...
            '   puts $mig_prj_file {    <SysResetPolarity>ACTIVE HIGH</SysResetPolarity>}\n',...
            '   puts $mig_prj_file {    <BankSelectionFlag>FALSE</BankSelectionFlag>}\n',...
            '   puts $mig_prj_file {    <InternalVref>0</InternalVref>}\n',...
            '   puts $mig_prj_file {    <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}\n',...
            '   puts $mig_prj_file {    <dci_cascade>1</dci_cascade>}\n',...
            '   puts $mig_prj_file {    <Controller number="0" >}\n',...
            '   puts $mig_prj_file {        <MemoryDevice>DDR3_SDRAM/SODIMMs/MT8JTF12864HZ-1G6</MemoryDevice>}\n',...
            '   puts $mig_prj_file {        <TimePeriod>1250</TimePeriod>}\n',...
            '   puts $mig_prj_file {        <VccAuxIO>2.0V</VccAuxIO>}\n',...
            '   puts $mig_prj_file {        <PHYRatio>4:1</PHYRatio>}\n',...
            '   puts $mig_prj_file {        <InputClkFreq>200</InputClkFreq>}\n',...
            '   puts $mig_prj_file {        <UIExtraClocks>0</UIExtraClocks>}\n',...
            '   puts $mig_prj_file {        <MMCM_VCO>800</MMCM_VCO>}\n',...
            '   puts $mig_prj_file {        <MMCMClkOut0> 1.000</MMCMClkOut0>}\n',...
            '   puts $mig_prj_file {        <MMCMClkOut1>1</MMCMClkOut1>}\n',...
            '   puts $mig_prj_file {        <MMCMClkOut2>1</MMCMClkOut2>}\n',...
            '   puts $mig_prj_file {        <MMCMClkOut3>1</MMCMClkOut3>}\n',...
            '   puts $mig_prj_file {        <MMCMClkOut4>1</MMCMClkOut4>}\n',...
            '   puts $mig_prj_file {        <DataWidth>64</DataWidth>}\n',...
            '   puts $mig_prj_file {        <DeepMemory>1</DeepMemory>}\n',...
            '   puts $mig_prj_file {        <DataMask>1</DataMask>}\n',...
            '   puts $mig_prj_file {        <ECC>Disabled</ECC>}\n',...
            '   puts $mig_prj_file {        <Ordering>Normal</Ordering>}\n',...
            '   puts $mig_prj_file {        <CustomPart>FALSE</CustomPart>}\n',...
            '   puts $mig_prj_file {        <NewPartName></NewPartName>}\n',...
            '   puts $mig_prj_file {        <RowAddress>14</RowAddress>}\n',...
            '   puts $mig_prj_file {        <ColAddress>10</ColAddress>}\n',...
            '   puts $mig_prj_file {        <BankAddress>3</BankAddress>}\n',...
            '   puts $mig_prj_file {        <MemoryVoltage>1.5V</MemoryVoltage>}\n',...
            '   puts $mig_prj_file {        <C0_MEM_SIZE>1073741824</C0_MEM_SIZE>}\n',...
            '   puts $mig_prj_file {        <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}\n',...
            '   puts $mig_prj_file {        <PinSelection>}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="E10" SLEW="FAST" name="ddr3_addr[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="D6" SLEW="FAST" name="ddr3_addr[10]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="B7" SLEW="FAST" name="ddr3_addr[11]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="H12" SLEW="FAST" name="ddr3_addr[12]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="A10" SLEW="FAST" name="ddr3_addr[13]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="B9" SLEW="FAST" name="ddr3_addr[1]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="E11" SLEW="FAST" name="ddr3_addr[2]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="A9" SLEW="FAST" name="ddr3_addr[3]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="D11" SLEW="FAST" name="ddr3_addr[4]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="B6" SLEW="FAST" name="ddr3_addr[5]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="F9" SLEW="FAST" name="ddr3_addr[6]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="E8" SLEW="FAST" name="ddr3_addr[7]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="B10" SLEW="FAST" name="ddr3_addr[8]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="J8" SLEW="FAST" name="ddr3_addr[9]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="F8" SLEW="FAST" name="ddr3_ba[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="H7" SLEW="FAST" name="ddr3_ba[1]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="A7" SLEW="FAST" name="ddr3_ba[2]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="E7" SLEW="FAST" name="ddr3_cas_n" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15" PADName="F10" SLEW="FAST" name="ddr3_ck_n[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15" PADName="G10" SLEW="FAST" name="ddr3_ck_p[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="D10" SLEW="FAST" name="ddr3_cke[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="J11" SLEW="FAST" name="ddr3_cs_n[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="J3" SLEW="FAST" name="ddr3_dm[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="F2" SLEW="FAST" name="ddr3_dm[1]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="E1" SLEW="FAST" name="ddr3_dm[2]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="C2" SLEW="FAST" name="ddr3_dm[3]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="L12" SLEW="FAST" name="ddr3_dm[4]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="G14" SLEW="FAST" name="ddr3_dm[5]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="C16" SLEW="FAST" name="ddr3_dm[6]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="C11" SLEW="FAST" name="ddr3_dm[7]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="L1" SLEW="FAST" name="ddr3_dq[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="H6" SLEW="FAST" name="ddr3_dq[10]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="H3" SLEW="FAST" name="ddr3_dq[11]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="G1" SLEW="FAST" name="ddr3_dq[12]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="H2" SLEW="FAST" name="ddr3_dq[13]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="G5" SLEW="FAST" name="ddr3_dq[14]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="G4" SLEW="FAST" name="ddr3_dq[15]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E2" SLEW="FAST" name="ddr3_dq[16]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E3" SLEW="FAST" name="ddr3_dq[17]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D4" SLEW="FAST" name="ddr3_dq[18]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E5" SLEW="FAST" name="ddr3_dq[19]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="L2" SLEW="FAST" name="ddr3_dq[1]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="F4" SLEW="FAST" name="ddr3_dq[20]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="F3" SLEW="FAST" name="ddr3_dq[21]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D1" SLEW="FAST" name="ddr3_dq[22]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D3" SLEW="FAST" name="ddr3_dq[23]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="A2" SLEW="FAST" name="ddr3_dq[24]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B2" SLEW="FAST" name="ddr3_dq[25]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B4" SLEW="FAST" name="ddr3_dq[26]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B5" SLEW="FAST" name="ddr3_dq[27]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="A3" SLEW="FAST" name="ddr3_dq[28]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B1" SLEW="FAST" name="ddr3_dq[29]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="K5" SLEW="FAST" name="ddr3_dq[2]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="C1" SLEW="FAST" name="ddr3_dq[30]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="C4" SLEW="FAST" name="ddr3_dq[31]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="K10" SLEW="FAST" name="ddr3_dq[32]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="L9" SLEW="FAST" name="ddr3_dq[33]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="K12" SLEW="FAST" name="ddr3_dq[34]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="J9" SLEW="FAST" name="ddr3_dq[35]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="K11" SLEW="FAST" name="ddr3_dq[36]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="L10" SLEW="FAST" name="ddr3_dq[37]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="J10" SLEW="FAST" name="ddr3_dq[38]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="L7" SLEW="FAST" name="ddr3_dq[39]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="J4" SLEW="FAST" name="ddr3_dq[3]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="F14" SLEW="FAST" name="ddr3_dq[40]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="F15" SLEW="FAST" name="ddr3_dq[41]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="F13" SLEW="FAST" name="ddr3_dq[42]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="G16" SLEW="FAST" name="ddr3_dq[43]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="G15" SLEW="FAST" name="ddr3_dq[44]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E12" SLEW="FAST" name="ddr3_dq[45]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D13" SLEW="FAST" name="ddr3_dq[46]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E13" SLEW="FAST" name="ddr3_dq[47]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D15" SLEW="FAST" name="ddr3_dq[48]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E15" SLEW="FAST" name="ddr3_dq[49]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="K1" SLEW="FAST" name="ddr3_dq[4]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D16" SLEW="FAST" name="ddr3_dq[50]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="E16" SLEW="FAST" name="ddr3_dq[51]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="C17" SLEW="FAST" name="ddr3_dq[52]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B16" SLEW="FAST" name="ddr3_dq[53]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="D14" SLEW="FAST" name="ddr3_dq[54]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B17" SLEW="FAST" name="ddr3_dq[55]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B12" SLEW="FAST" name="ddr3_dq[56]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="C12" SLEW="FAST" name="ddr3_dq[57]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="A12" SLEW="FAST" name="ddr3_dq[58]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="A14" SLEW="FAST" name="ddr3_dq[59]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="L3" SLEW="FAST" name="ddr3_dq[5]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="A13" SLEW="FAST" name="ddr3_dq[60]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B11" SLEW="FAST" name="ddr3_dq[61]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="C14" SLEW="FAST" name="ddr3_dq[62]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="B14" SLEW="FAST" name="ddr3_dq[63]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="J5" SLEW="FAST" name="ddr3_dq[6]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="K6" SLEW="FAST" name="ddr3_dq[7]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="G6" SLEW="FAST" name="ddr3_dq[8]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15_T_DCI" PADName="H4" SLEW="FAST" name="ddr3_dq[9]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="K2" SLEW="FAST" name="ddr3_dqs_n[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="H1" SLEW="FAST" name="ddr3_dqs_n[1]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="D5" SLEW="FAST" name="ddr3_dqs_n[2]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="A4" SLEW="FAST" name="ddr3_dqs_n[3]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="K8" SLEW="FAST" name="ddr3_dqs_n[4]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="F12" SLEW="FAST" name="ddr3_dqs_n[5]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="E17" SLEW="FAST" name="ddr3_dqs_n[6]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="A15" SLEW="FAST" name="ddr3_dqs_n[7]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="K3" SLEW="FAST" name="ddr3_dqs_p[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="J1" SLEW="FAST" name="ddr3_dqs_p[1]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="E6" SLEW="FAST" name="ddr3_dqs_p[2]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="A5" SLEW="FAST" name="ddr3_dqs_p[3]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="L8" SLEW="FAST" name="ddr3_dqs_p[4]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="G12" SLEW="FAST" name="ddr3_dqs_p[5]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="F17" SLEW="FAST" name="ddr3_dqs_p[6]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="B15" SLEW="FAST" name="ddr3_dqs_p[7]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="G7" SLEW="FAST" name="ddr3_odt[0]" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="H11" SLEW="FAST" name="ddr3_ras_n" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="LVCMOS15" PADName="G17" SLEW="FAST" name="ddr3_reset_n" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {            <Pin VCCAUX_IO="HIGH" IOSTANDARD="SSTL15" PADName="F7" SLEW="FAST" name="ddr3_we_n" IN_TERM="" />}\n',...
            '   puts $mig_prj_file {        </PinSelection>}\n',...
            '   puts $mig_prj_file {        <System_Clock>}\n',...
            '   puts $mig_prj_file {            <Pin PADName="H9/G9(CC_P/N)" Bank="34" name="sys_clk_p/n" />}\n',...
            '   puts $mig_prj_file {        </System_Clock>}\n',...
            '   puts $mig_prj_file {        <System_Control>}\n',...
            '   puts $mig_prj_file {            <Pin PADName="No connect" Bank="Select Bank" name="sys_rst" />}\n',...
            '   puts $mig_prj_file {            <Pin PADName="No connect" Bank="Select Bank" name="init_calib_complete" />}\n',...
            '   puts $mig_prj_file {            <Pin PADName="No connect" Bank="Select Bank" name="tg_compare_error" />}\n',...
            '   puts $mig_prj_file {        </System_Control>}\n',...
            '   puts $mig_prj_file {        <TimingParameters>}\n',...
            '   puts $mig_prj_file {            <Parameters twtr="7.5" trrd="6" trefi="7.8" tfaw="30" trtp="7.5" tcke="5" trfc="110" trp="13.75" tras="35" trcd="13.75" />}\n',...
            '   puts $mig_prj_file {        </TimingParameters>}\n',...
            '   puts $mig_prj_file {        <mrBurstLength name="Burst Length" >8 - Fixed</mrBurstLength>}\n',...
            '   puts $mig_prj_file {        <mrBurstType name="Read Burst Type and Length" >Sequential</mrBurstType>}\n',...
            '   puts $mig_prj_file {        <mrCasLatency name="CAS Latency" >11</mrCasLatency>}\n',...
            '   puts $mig_prj_file {        <mrMode name="Mode" >Normal</mrMode>}\n',...
            '   puts $mig_prj_file {        <mrDllReset name="DLL Reset" >No</mrDllReset>}\n',...
            '   puts $mig_prj_file {        <mrPdMode name="DLL control for precharge PD" >Slow Exit</mrPdMode>}\n',...
            '   puts $mig_prj_file {        <emrDllEnable name="DLL Enable" >Enable</emrDllEnable>}\n',...
            '   puts $mig_prj_file {        <emrOutputDriveStrength name="Output Driver Impedance Control" >RZQ/7</emrOutputDriveStrength>}\n',...
            '   puts $mig_prj_file {        <emrMirrorSelection name="Address Mirroring" >Disable</emrMirrorSelection>}\n',...
            '   puts $mig_prj_file {        <emrCSSelection name="Controller Chip Select Pin" >Enable</emrCSSelection>}\n',...
            '   puts $mig_prj_file {        <emrRTT name="RTT (nominal) - On Die Termination (ODT)" >RZQ/6</emrRTT>}\n',...
            '   puts $mig_prj_file {        <emrPosted name="Additive Latency (AL)" >0</emrPosted>}\n',...
            '   puts $mig_prj_file {        <emrOCD name="Write Leveling Enable" >Disabled</emrOCD>}\n',...
            '   puts $mig_prj_file {        <emrDQS name="TDQS enable" >Enabled</emrDQS>}\n',...
            '   puts $mig_prj_file {        <emrRDQS name="Qoff" >Output Buffer Enabled</emrRDQS>}\n',...
            '   puts $mig_prj_file {        <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh" >Full Array</mr2PartialArraySelfRefresh>}\n',...
            '   puts $mig_prj_file {        <mr2CasWriteLatency name="CAS write latency" >8</mr2CasWriteLatency>}\n',...
            '   puts $mig_prj_file {        <mr2AutoSelfRefresh name="Auto Self Refresh" >Enabled</mr2AutoSelfRefresh>}\n',...
            '   puts $mig_prj_file {        <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate" >Normal</mr2SelfRefreshTempRange>}\n',...
            '   puts $mig_prj_file {        <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)" >Dynamic ODT off</mr2RTTWR>}\n',...
            '   puts $mig_prj_file {        <PortInterface>AXI</PortInterface>}\n',...
            '   puts $mig_prj_file {        <AXIParameters>}\n',...
            '   puts $mig_prj_file {            <C0_C_RD_WR_ARB_ALGORITHM>ROUND_ROBIN</C0_C_RD_WR_ARB_ALGORITHM>}\n',...
            '   puts $mig_prj_file {            <C0_S_AXI_DATA_WIDTH>',obj.Configuration.mm_dw,'</C0_S_AXI_DATA_WIDTH>}\n',...
            '   puts $mig_prj_file {            <C0_S_AXI_ID_WIDTH>8</C0_S_AXI_ID_WIDTH>}\n',...
            '   puts $mig_prj_file {            <C0_S_AXI_SUPPORTS_NARROW_BURST>1</C0_S_AXI_SUPPORTS_NARROW_BURST>}\n',...
            '   puts $mig_prj_file {        </AXIParameters>}\n',...
            '   puts $mig_prj_file {    </Controller>}\n',...
            '   puts $mig_prj_file {</Project>}\n',...
            '   close $mig_prj_file\n',...
            '}\n',...
            '# End of write_mig_file_design_1_mig_7series_0_0()\n',...
            '\n',...
            '\n',...
            '  # Create interface ports\n',...
            '  set DDR3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3 ]\n',...
            '\n',...
            '  # Create ports\n',...
            '\n',...
            '  # Create instance: mig_7series_0, and set properties\n',...
            '  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]\n',...
            '\n',...
            '  # Generate the PRJ File for MIG\n',...
            '  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]\n',...
            '  set str_mig_file_name mig_a.prj\n',...
            '  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}\n',...
            '\n',...
            '  write_mig_file_design_1_mig_7series_0_0 $str_mig_file_path\n',...
            '\n',...
            '  set_property -dict [ list \\\n',...
            'CONFIG.BOARD_MIG_PARAM {Custom} \\\n',...
            'CONFIG.RESET_BOARD_INTERFACE {Custom} \\\n',...
            'CONFIG.XML_INPUT_FILE {mig_a.prj} \\\n',...
            ' ] $mig_7series_0\n',...
            '\n',...
            '\n',...
            '  # Create instance: mig_sys_reset, and set properties\n',...
            '  set mig_sys_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 mig_sys_reset ]\n',...
            '\n',...
            '  # Create interface connections\n',...
            '  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports DDR3] [get_bd_intf_pins mig_7series_0/DDR3]\n',...
            '\n',...
            '  # Create port connections\n',...
            '\n',...
            '  connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins mig_7series_0/mmcm_locked] [get_bd_pins mig_sys_reset/dcm_locked]\n',...
            '  connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins mig_sys_reset/slowest_sync_clk]\n',...
            '  connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins mig_7series_0/ui_clk_sync_rst] [get_bd_pins mig_sys_reset/ext_reset_in]\n',...
            '  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins mig_7series_0/aresetn] [get_bd_pins mig_sys_reset/peripheral_aresetn]\n',...
            ];

            obj.Constraint='set_property slave_banks {34} [get_iobanks 33]';
        end
    end
end