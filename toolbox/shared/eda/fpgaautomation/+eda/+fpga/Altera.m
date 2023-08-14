classdef Altera<eda.internal.component.FPGA





    properties(Transient)



        RGMII_TX_PhaseShift=0;
    end

    methods

        function this=Altera(varargin)
            this.HDL=this.hdlcodeinit;

            this.FPGASpeed='';
            this.FPGAPackage='';
            this.RGMII_TX_PhaseShift=0;
        end

        function hdlcode=hdlcodeinit(this)%#ok<MANU>
            hdlcode.entity_comment='';
            hdlcode.entity_library=' LIBRARY altera_mf;\n USE altera_mf.altera_mf_components.all;\n USE altera_mf.all;\n\n';
            hdlcode.entity_package='';
            hdlcode.entity_decl='';
            hdlcode.entity_generic='';
            hdlcode.entity_ports='';
            hdlcode.entity_portdecls='';
            hdlcode.entity_end='';
            hdlcode.arch_comment='';
            hdlcode.arch_decl='';
            hdlcode.arch_component_decl='';
            hdlcode.arch_component_config='';
            hdlcode.arch_functions='';
            hdlcode.arch_typedefs='';
            hdlcode.arch_constants='';
            hdlcode.arch_signals='';
            hdlcode.arch_begin='';
            hdlcode.arch_body_component_instances='';
            hdlcode.arch_body_blocks='';
            hdlcode.arch_body_output_assignments='';
            hdlcode.arch_end='';
            hdlcode.entity_comment='';
        end

        function ActSynthFreq=getMIISynthFreq(~,SysClkFreq,OrigSynthFreq)
            if OrigSynthFreq>SysClkFreq
                ActSynthFreq=SysClkFreq;
            else
                ActSynthFreq=OrigSynthFreq;
            end
        end

        function hC=ClkMgr_MII(this,SYSCLK,SynthFreq,varargin)
            hC=eda.internal.component.WhiteBox(...
            {'RESET_IN','INPUT','boolean',...
            'CLK_IN','INPUT','boolean',...
            'TXCLK_IN','INPUT','boolean',...
            'RXCLK_IN','INPUT','boolean',...
            'TXCLK_OUT','OUTPUT','boolean',...
            'RXCLK_OUT','OUTPUT','boolean',...
            'DUTCLK','OUTPUT','boolean',...
            'RESET_OUT','OUTPUT','boolean'});

            hC.Partition.Device.PartInfo.FPGAVendor='Altera';
            hC.UniqueName='MWClkMgr';
            hC.addprop('enableCodeGen');
            hC.flatten=false;

            tmp_rxclk=hC.signal('Name','tmp_rxclk','FiType','boolean');
            tmp_txclk=hC.signal('Name','tmp_rxclk','FiType','boolean');

            hC.assign(hC.TXCLK_IN,tmp_txclk);
            hC.assign(tmp_txclk,hC.TXCLK_OUT);

            hC.assign(hC.RXCLK_IN,tmp_rxclk);
            hC.assign(tmp_rxclk,hC.RXCLK_OUT);

            SynthFreq=this.getMIISynthFreq(SYSCLK.Frequency,SynthFreq);

            tmpclk2=hC.signal('Name','tmpclk3','FiType','boolean');
            tmpclk3=hC.signal('Name','tmpclk3','FiType','boolean');
            this.dcm(hC,SYSCLK.Frequency,SynthFreq,0,0,...
            hC.CLK_IN,hC.DUTCLK,tmpclk2,tmpclk3,'"0"');

        end
        function hC=ClkMgr_RGMII(this,SYSCLK,SynthFreq)
            hC=eda.internal.component.WhiteBox(...
            {'CLK_IN','INPUT','ClockPort',...
            'RESET_IN','INPUT','boolean',...
            'RXCLK_IN','INPUT','boolean',...
            'DUTCLK','OUTPUT','boolean',...
            'MACRXCLK','OUTPUT','boolean',...
            'MACTXCLK','OUTPUT','boolean',...
            'TXCLK','OUTPUT','boolean',...
            'RESET_OUT','OUTPUT','boolean'});

            hC.Partition.Device.PartInfo.FPGAVendor='Altera';
            hC.UniqueName='MWClkMgr';
            hC.addprop('enableCodeGen');
            hC.flatten=false;

            TxclkShift=sprintf('"%d"',this.RGMII_TX_PhaseShift);
            this.dcm(hC,SYSCLK.Frequency,SynthFreq,125,125,hC.CLK_IN,hC.DUTCLK,hC.MACTXCLK,hC.TXCLK,TxclkShift)

            rxClk_internal=hC.signal('Name','rxClk_internal','FiType','boolean');
            hC.assign(hC.RXCLK_IN,rxClk_internal);
            hC.assign(rxClk_internal,hC.MACRXCLK);

        end

        function hC=ClkMgr_GMII(this,SYSCLK,SynthFreq)
            hC=eda.internal.component.WhiteBox(...
            {'CLK_IN','INPUT','ClockPort',...
            'RESET_IN','INPUT','boolean',...
            'RXCLK_IN','INPUT','boolean',...
            'DUTCLK','OUTPUT','boolean',...
            'MACRXCLK','OUTPUT','boolean',...
            'MACTXCLK','OUTPUT','boolean',...
            'TXCLK','OUTPUT','boolean',...
            'RESET_OUT','OUTPUT','boolean'});

            hC.Partition.Device.PartInfo.FPGAVendor='Altera';
            hC.UniqueName='MWClkMgr';
            hC.addprop('enableCodeGen');
            hC.flatten=false;

            this.dcm(hC,SYSCLK.Frequency,SynthFreq,125,125,...
            hC.CLK_IN,hC.DUTCLK,hC.MACTXCLK,hC.TXCLK,'"0"');

            tmp=hC.signal('Name','tmp','FiType','boolean');
            hC.assign(hC.RXCLK_IN,tmp);
            hC.assign(tmp,hC.MACRXCLK);

        end

        function numclkin=getPllNumClkIn(~)
            numclkin='5';
        end

        function dcm(this,hC,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,clkin,clkout0,clkout1,clkout2,outputClk2Phase)
            if nargin<11
                outputClk2Phase='"2000"';
            end


            locked=hC.signal('Name','locked','FiType','boolean');
            notLocked=hC.signal('Name','notLocked','FiType','boolean');
            if strcmpi(this.FPGAFamily,'Arria 10')||strcmpi(this.FPGAFamily,'Cyclone 10 GX')||strcmpi(this.FPGAFamily,'Stratix 10')

                hC.component(...
                'Name','dcm',...
                'Component',eda.intel.iopll(this.FPGAFamily,this.FPGADevice,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,outputClk2Phase),...
                'refclk',clkin,...
                'rst',hC.RESET_IN,...
                'outclk_0',clkout0,...
                'outclk_1',clkout1,...
                'outclk_2',clkout2,...
                'locked',locked);
            else

                outputClkWidth=getPllNumClkIn(this);


                clk0=hC.signal('Name','clk0','FiType','boolean');
                clk1=hC.signal('Name','clk1','FiType','boolean');
                clk2=hC.signal('Name','clk2','FiType','boolean');
                clkin_vec=hC.signal('Name','clkin_vec','FiType','std2');
                clkout_vec=hC.signal('Name','clkout_vec','FiType',['std',outputClkWidth]);
                zero=hC.signal('Name','zero','FiType','boolean');
                clkin_tmp=hC.signal('Name','clkin_tmp','FiType','boolean');


                hC.component(...
                'Name','dcm',...
                'Component',eda.intel.altpll(outputClkWidth,inputClkFreq,outputClk0Freq,outputClk1Freq,outputClk2Freq,outputClk2Phase),...
                'inclk',clkin_vec,...
                'areset',hC.RESET_IN,...
                'clk',clkout_vec,...
                'locked',locked);


                hC.assign(clkin,clkin_tmp)
                hC.assign('fi(0,0,1,0)',zero);
                hC.assign('bitconcat(zero, clkin_tmp)',clkin_vec);


                hC.assign('bitsliceget(clkout_vec,0)',clk0);
                hC.assign('bitsliceget(clkout_vec,1)',clk1);
                hC.assign('bitsliceget(clkout_vec,2)',clk2);
                hC.assign(clk0,clkout0);
                hC.assign(clk1,clkout1);
                hC.assign(clk2,clkout2);
            end


            hC.assign(' ~ locked',notLocked);
            hC.assign(notLocked,hC.RESET_OUT);
        end

        function multiBitIddr(this,hC,clk,rst,in,out_h,out_l,dataWidth)%#ok<INUSL>
            iddr=hC.component(...
            'UniqueName','ALTDDIO_IN',...
            'InstName','ALTDDIO_IN',...
            'Component',eda.internal.component.BlackBox({...
            'datain','INPUT','boolean',...
            'inclock','INPUT','boolean',...
            'dataout_h','OUTPUT',['std',num2str(dataWidth)],...
            'dataout_l','OUTPUT',['std',num2str(dataWidth)]}),...
            'datain',in,...
            'inclock',clk,...
            'dataout_h',out_h,...
            'dataout_l',out_l);

            iddr.Partition.Device.PartInfo.FPGAVendor='Altera';
            iddr.addprop('generic');
            iddr.generic=generics('width','integer',num2str(dataWidth));
            iddr.addprop('compDeclNotNeeded');
            iddr.addprop('NoHDLFiles');
            iddr.addprop('wrapperFileNotNeeded');
        end

        function multiBitOddr(~,hC,clk,rst,in_l,in_h,out,dataWidth)
            oddr=hC.component(...
            'UniqueName','ALTDDIO_OUT',...
            'InstName','ALTDDIO_OUT',...
            'Component',eda.internal.component.BlackBox({...
            'aclr','INPUT','boolean',...
            'datain_h','INPUT',['std',num2str(dataWidth)],...
            'datain_l','INPUT',['std',num2str(dataWidth)],...
            'outclock','INPUT','boolean',...
            'dataout','OUTPUT',['std',num2str(dataWidth)]}),...
            'aclr',rst,...
            'datain_h',in_h,...
            'datain_l',in_l,...
            'outclock',clk,...
            'dataout',out);

            oddr.Partition.Device.PartInfo.FPGAVendor='Altera';
            oddr.addprop('generic');
            oddr.generic=generics('width','integer',num2str(dataWidth));
            oddr.addprop('compDeclNotNeeded');
            oddr.addprop('NoHDLFiles');
            oddr.addprop('wrapperFileNotNeeded');
        end

        function bufg(this,hC,in,out)%#ok<INUSD>    
        end

        function ibufg(this,~,in,out)
            this.assign(in,out);
        end

        function iobuf(~,hC,in,oe,out,io)


            bidir=hC.component(...
            'UniqueName','altiobuf_bidir',...
            'InstName','altiobuf_bidir',...
            'Component',eda.internal.component.BlackBox({...
            'datain','INPUT','boolean',...
            'oe','INPUT','boolean',...
            'dataout','OUTPUT','boolean',...
            'dataio','INOUT','boolean'}),...
            'datain',in,...
            'oe',oe,...
            'dataout',out,...
            'dataio',io);
            bidir.Partition.Device.PartInfo.FPGAVendor='Altera';
            bidir.addprop('NoHDLFiles');
            bidir.addprop('compDeclNotNeeded');
            bidir.addprop('wrapperFileNotNeeded');
        end

        function constraintFile(this,BuildInfo,hC)

            if nargin<3
                hC=this;
            end

            dir=hdlGetCodegendir(true);
            hC.SynConstraintFile{end+1}=[BuildInfo.FPGAProjectName,'.qsf'];
            hC.SynConstraintFile{end+1}=[BuildInfo.FPGAProjectName,'.sdc'];

            boardObj=BuildInfo.BoardObj;
            boardObj.setPIN(1);




            qsfFile=fopen(fullfile(dir,[BuildInfo.FPGAProjectName,'.qsf']),'w');

            if(strcmpi(boardObj.Component.SYSCLK.Type,'DIFF'))
                constraint=l_setPinAndIOStandard(boardObj,'sysclk_p');
                constraint=[constraint,l_setPinAndIOStandard(boardObj,'sysclk_n')];
            else
                constraint=l_setPinAndIOStandard(boardObj,'sysclk');
            end

            constraint=[constraint,l_setPinAndIOStandard(boardObj,'sysrst')];

            interface=boardObj.getInterface;
            signalNames=interface.getSignalNames;
            for m=1:numel(signalNames)
                sgName=signalNames{m};
                constraint=[constraint,l_setPinAndIOStandard(boardObj,sgName)];%#ok<AGROW>
            end

            fprintf(qsfFile,constraint);


            if qsfFile>0
                fclose(qsfFile);
            end






            SYSFreq=boardObj.Component.SYSCLK.Frequency;

            SynthFreq=str2double(strrep(BuildInfo.FPGASystemClockFrequency,'MHz',''));

            SYSClkPeriod=num2str(round(1000./SYSFreq));
            dutyCycle=['0.000ns ',num2str(round(1000./(2*SYSFreq))),'.000ns'];

            [N,D]=rat(125/SYSFreq,0.01);
            MULT125=sprintf('%5d',N);
            DIV125=sprintf('%5d',D);

            [N,D]=rat(SynthFreq/SYSFreq,0.01);
            MULTSYN=sprintf('%5d',N);
            DIVSYN=sprintf('%5d',D);

            sdcFile=fopen(fullfile(dir,[BuildInfo.FPGAProjectName,'.sdc']),'w');

            if(strcmpi(boardObj.Component.SYSCLK.Type,'DIFF'))

                constraint=[...
                'create_clock -name sysclk -period ',SYSClkPeriod,' -waveform {',dutyCycle,'} [get_ports {sysclk_p}]\n'];
                clock_pin='sysclk_p';
            else
                constraint=[...
                'create_clock -name sysclk -period ',SYSClkPeriod,' -waveform {',dutyCycle,'} [get_ports {sysclk}]\n'];
                clock_pin='sysclk';
            end

            if strcmpi(boardObj.Component.Communication_Channel,'MII')


                SynthFreq=this.getMIISynthFreq(SYSFreq,SynthFreq);
                D=round(SYSFreq/SynthFreq);
                N=1;
                MULTSYN=sprintf('%5d',N);
                DIVSYN=sprintf('%5d',D);

                constraint=[constraint,...
                'create_clock -name ETH_RXCLK -period 40ns -waveform {0.000ns 20.000ns} [get_ports {ETH_RXCLK}]\n',...
                'create_clock -name ETH_TXCLK -period 40ns -waveform {0.000ns 20.000ns} [get_ports {ETH_TXCLK}]\n'];
                constraint=[constraint,'\n\n## Generate clocks ## \n',...
                'create_generated_clock -name dut_clk -source ',clock_pin,' -divide_by ',DIVSYN,' -multiply_by ',MULTSYN,' -duty_cycle 50.00 { u_ClockManager|u_dcm|auto_generated|pll1|clk[0]} \n'];

                constraint=[constraint,'\n\n## False Path ## \n',...
                'set_false_path -from [get_clocks ETH_RXCLK]   -to [get_clocks ETH_TXCLK]\n',...
                'set_false_path -from [get_clocks ETH_TXCLK]   -to [get_clocks ETH_RXCLK]\n',...
                'set_false_path -from [get_clocks ETH_RXCLK]   -to [get_clocks dut_clk]\n',...
                'set_false_path -from [get_clocks dut_clk]     -to [get_clocks ETH_RXCLK]\n',...
                'set_false_path -from [get_clocks dut_clk]     -to [get_clocks ETH_TXCLK]\n',...
                'set_false_path -from [get_clocks ETH_TXCLK]   -to [get_clocks dut_clk]\n',...
                'derive_pll_clocks -create_base_clocks\n',...
                'derive_clock_uncertainty\n'];
            elseif strcmpi(boardObj.Component.Communication_Channel,'RGMII')
                constraint=[constraint,...
                'create_clock -name ETH_RXCLK -period 8ns -waveform {0.000 4.000} [get_ports {ETH_RXCLK}]\n'];

                constraint=[constraint,...
                '## Virtual clock for input signals ##\n',...
                'create_clock -name virtual_clk -period 8 -waveform {2.000 6.000}\n',...
                'set_input_delay 0 -clock  [get_clocks virtual_clk] -add_delay [get_ports ETH_RXD*]\n',...
                'set_input_delay 0 -clock  [get_clocks virtual_clk] -clock_fall -add_delay [get_ports ETH_RXD*]\n',...
                'set_input_delay 0 -clock  [get_clocks virtual_clk] -add_delay [get_ports ETH_RX_CTL]\n',...
                'set_input_delay 0 -clock  [get_clocks virtual_clk] -clock_fall -add_delay [get_ports ETH_RX_CTL]\n',...
                '# Set false paths for altddio_in\n',...
                'set_false_path -fall_from [get_clocks virtual_clk] -rise_to [get_clocks ETH_RXCLK] -setup\n',...
                'set_false_path -rise_from [get_clocks virtual_clk] -fall_to [get_clocks ETH_RXCLK] -setup\n',...
                'set_false_path -fall_from [get_clocks virtual_clk] -fall_to [get_clocks ETH_RXCLK] -hold\n',...
                'set_false_path -rise_from [get_clocks virtual_clk] -rise_to [get_clocks ETH_RXCLK] -hold\n'];

                constraint=[constraint,'## Derive clocks ##\n',...
                'derive_pll_clocks -create_base_clocks\n',...
                'derive_clock_uncertainty\n'];

                switch boardObj.Component.PartInfo.FPGAFamily
                case{'Cyclone V','Arria V'}
                    clocks={'u_ClockManager|u_dcm|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk',...
                    'u_ClockManager|u_dcm|auto_generated|generic_pll2~PLL_OUTPUT_COUNTER|divclk',...
                    'ETH_RXCLK'};
                otherwise
                    clocks={'u_ClockManager|u_dcm|auto_generated|pll1|clk[0]',...
                    'u_ClockManager|u_dcm|auto_generated|pll1|clk[1]',...
                    'ETH_RXCLK'};
                end

                constraint=[constraint,'## Set clock groups ##\n'];
                constraint=[constraint,l_getClockGroups(clocks),char(10)];

            else
                constraint=[constraint,...
                'create_clock -name ETH_RXCLK -period 8ns -waveform {2.000ns 6.000ns} [get_ports {ETH_RXCLK}]\n'];

                constraint=[constraint,'\n\n## Generate clocks ## \n',...
                'create_generated_clock -name dut_clk      -source ',clock_pin,' -divide_by ',DIVSYN,' -multiply_by ',MULTSYN,' -duty_cycle 50.00 { u_ClockManager|u_dcm|auto_generated|pll1|clk[0]} \n',...
                'create_generated_clock -name gmii_tx_clk  -source ',clock_pin,' -divide_by ',DIV125,' -multiply_by ',MULT125,' -duty_cycle 50.00 { u_ClockManager|u_dcm|auto_generated|pll1|clk[1]} \n',...
                'create_generated_clock -name ETH_TXCLK    -source ',clock_pin,' -divide_by ',DIV125,' -multiply_by ',MULT125,' -duty_cycle 50.00 { u_ClockManager|u_dcm|auto_generated|pll1|clk[2]} \n'];

                constraint=[constraint,'\n\n## False Path ## \n',...
                'set_false_path -from [get_clocks ETH_RXCLK]   -to [get_clocks gmii_tx_clk]\n',...
                'set_false_path -from [get_clocks gmii_tx_clk] -to [get_clocks ETH_RXCLK]\n',...
                'set_false_path -from [get_clocks ETH_RXCLK]   -to [get_clocks dut_clk]\n',...
                'set_false_path -from [get_clocks dut_clk]     -to [get_clocks ETH_RXCLK]\n',...
                'set_false_path -from [get_clocks dut_clk]     -to [get_clocks gmii_tx_clk]\n',...
                'set_false_path -from [get_clocks gmii_tx_clk] -to [get_clocks dut_clk]\n',...
                'derive_pll_clocks -create_base_clocks\n',...
                'derive_clock_uncertainty\n'];

            end
            fprintf(sdcFile,constraint);


            if sdcFile>0
                fclose(sdcFile);
            end


        end
        function ibufgds(~,hC,diff_n,diff_p,out)
            ibufgds=hC.component(...
            'UniqueName','cycloneiv_io_ibuf',...
            'InstName','ibufa',...
            'Component',eda.internal.component.BlackBox({...
            'I','INPUT','boolean',...
            'IBAR','INPUT','boolean',...
            'O','OUTPUT','boolean'}),...
            'I',diff_p,...
            'IBAR',diff_n,...
            'O',out);
            ibufgds.Partition.Device.PartInfo.FPGAVendor='Altera';
            ibufgds.addprop('generic');
            ibufgds.generic=generics(...
            'bus_hold','string','"FALSE"',...
            'differential_mode','string','"TRUE"');
            ibufgds.addprop('NoHDLFiles');
            ibufgds.addprop('wrapperFileNotNeeded');
        end
    end
end

function r=l_getClockGroups(clocks)
    r='set_clock_groups -exclusive ';
    for ii=1:numel(clocks)
        r=[r,'-group {',clocks{ii},'} '];%#ok<AGROW>
    end
end

function r=l_setPinAndIOStandard(boardObj,sgName)
    r='';
    location=boardObj.getPIN(1,sgName);
    if isempty(location)
        return;
    end
    ioStandard=boardObj.getIOStandard(sgName);


    if ischar(location)
        r=[r,'set_location_assignment PIN_',location,' -to ',sgName,char(10)];
        if~isempty(ioStandard)
            r=[r,'set_instance_assignment -name IO_STANDARD "',ioStandard,'" -to ',sgName,char(10)];
        end
    else
        for m=1:numel(location)
            portName=[sgName,'[',num2str(m-1),']'];
            r=[r,'set_location_assignment PIN_',location{m},' -to ',portName,char(10)];
            if~isempty(ioStandard)
                r=[r,'set_instance_assignment -name IO_STANDARD "',ioStandard,'" -to ',portName,char(10)];
            end
        end
    end
end