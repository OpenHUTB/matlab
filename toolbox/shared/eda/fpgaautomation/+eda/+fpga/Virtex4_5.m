classdef Virtex4_5<eda.fpga.Xilinx




    methods
        function this=Virtex4_5(varargin)
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                this.FPGADevice=arg.Device;
                this.FPGASpeed=arg.Speed;
                this.FPGAPackage=arg.Package;

            end
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

            InClkFreq=SYSCLK.Frequency;
            ClkDVFreq=SynthFreq;
            ClkFXFreq=125;


            AllowedValues=[1.5,...
            2,...
            2.5,...
            3,...
            3.5,...
            4,...
            4.5,...
            5,...
            5.5,...
            6,...
            6.5,...
            7,...
            7.5,...
            8,...
            9,...
            10,...
            11,...
            12,...
            13,...
            14,...
            15,...
            16];

            clkPeriod=num2str(round(1000./(InClkFreq)));

            DIV_NUM_UNROUNDED=InClkFreq./ClkDVFreq;

            [~,val]=min(abs(ones(size(AllowedValues))*DIV_NUM_UNROUNDED-AllowedValues));
            DIV_NUM=AllowedValues(val);

            [MULT125,DIV125]=rat(ClkFXFreq/InClkFreq);

            if MULT125==1||DIV125==1
                MULT125=MULT125*2;
                DIV125=DIV125*2;
            end
            MULT125=num2str(MULT125);
            DIV125=num2str(DIV125);

            hC.Partition.Device.PartInfo.FPGAVendor='Xilinx';
            hC.UniqueName='MWClkMgr';
            hC.addprop('enableCodeGen');
            hC.flatten=false;

            clk0=hC.signal('Name','clk0','FiType','boolean');
            clkfb0=hC.signal('Name','clkfb0','FiType','boolean');
            clk125=hC.signal('Name','clk125','FiType','boolean');
            dcmclk125=hC.signal('Name','CLKFX','FiType','boolean');
            LOCKED=hC.signal('Name','LOCKED','FiType','boolean');
            rxClk_internal=hC.signal('Name','rxClk_internal','FiType','boolean');
            notLocked=hC.signal('Name','notLocked','FiType','boolean');

            if(round(DIV_NUM_UNROUNDED)==1)
                CLKDV='OPEN';
                DIV='2';
            else
                CLKDV=hC.signal('Name','CLKDV','FiType','boolean');
                DIV=num2str(DIV_NUM);
            end

            dcm=hC.component(...
            'UniqueName','DCM_BASE',...
            'InstName','dcm',...
            'Component',eda.internal.component.BlackBox({...
            'CLK0','OUTPUT','boolean',...
            'CLK180','OUTPUT','boolean',...
            'CLK270','OUTPUT','boolean',...
            'CLK2X','OUTPUT','boolean',...
            'CLK2X180','OUTPUT','boolean',...
            'CLK90','OUTPUT','boolean',...
            'CLKDV','OUTPUT','boolean',...
            'CLKFX','OUTPUT','boolean',...
            'CLKFX180','OUTPUT','boolean',...
            'LOCKED','OUTPUT','boolean',...
            'CLKFB','INPUT','boolean',...
            'CLKIN','INPUT','boolean',...
            'RST','INPUT','boolean'}),...
            'CLK0',clk0,...
            'CLK180','OPEN',...
            'CLK270','OPEN',...
            'CLK2X','OPEN',...
            'CLK2X180','OPEN',...
            'CLK90','OPEN',...
            'CLKDV',CLKDV,...
            'CLKFX',dcmclk125,...
            'CLKFX180','OPEN',...
            'LOCKED',LOCKED,...
            'CLKFB',clkfb0,...
            'CLKIN',hC.CLK_IN,...
            'RST',hC.RESET_IN);

            dcm.addprop('generic');
            dcm.generic=generics(...
            'CLKDV_DIVIDE','double',[DIV,'.000'],...
            'CLKIN_DIVIDE_BY_2','boolean','FALSE',...
            'CLKFX_DIVIDE','integer',DIV125,...
            'CLKFX_MULTIPLY','integer',MULT125,...
            'CLKIN_PERIOD','double',[clkPeriod,'.000'],...
            'CLKOUT_PHASE_SHIFT','string','"NONE"',...
            'CLK_FEEDBACK','string','"1X"',...
            'DCM_PERFORMANCE_MODE','string','"MAX_SPEED"',...
            'DFS_FREQUENCY_MODE','string','"LOW"',...
            'DLL_FREQUENCY_MODE','string','"LOW"',...
            'DUTY_CYCLE_CORRECTION','boolean','TRUE',...
            'DESKEW_ADJUST','string','"SYSTEM_SYNCHRONOUS"',...
            'PHASE_SHIFT','integer','0',...
            'STARTUP_WAIT','boolean','FALSE');

            dcm.addprop('NoHDLFiles');
            dcm.addprop('compDeclNotNeeded');
            dcm.addprop('wrapperFileNotNeeded');

            this.bufg(hC,clk0,clkfb0);
            this.bufg(hC,dcmclk125,clk125);


            hC.assign(' ~ LOCKED',notLocked);
            hC.assign(notLocked,hC.RESET_OUT);

            hC.assign(clk125,hC.MACTXCLK);
            hC.assign(hC.RXCLK_IN,rxClk_internal);
            hC.assign(rxClk_internal,hC.MACRXCLK);
            this.oddr(hC,clk125,'HIGH','LOW','HIGH',hC.TXCLK,'LOW','LOW');

            if(DIV_NUM==1)
                hC.assign(clkfb0,hC.DUTCLK);
            else
                this.bufg(hC,CLKDV,hC.DUTCLK);
            end

        end

        function hC=ClkMgr_RGMII(this,SYSCLK,SynthFreq)
            hC=ClkMgr_GMII(this,SYSCLK,SynthFreq);
        end

        function hC=ClkMgr_MII(this,SYSCLK,SynthFreq)

            hC=eda.internal.component.WhiteBox(...
            {'RESET_IN','INPUT','boolean',...
            'CLK_IN','INPUT','boolean',...
            'TXCLK_IN','INPUT','boolean',...
            'RXCLK_IN','INPUT','boolean',...
            'TXCLK_OUT','OUTPUT','boolean',...
            'RXCLK_OUT','OUTPUT','boolean',...
            'DUTCLK','OUTPUT','boolean',...
            'RESET_OUT','OUTPUT','boolean'});

            hC.Partition.Device.PartInfo.FPGAVendor='Xilinx';
            hC.UniqueName='MWClkMgr';
            hC.addprop('enableCodeGen');
            hC.flatten=false;

            InClkFreq=SYSCLK.Frequency;
            ClkDVFreq=SynthFreq;
            clkPeriod=num2str(round(1000./(InClkFreq)));
            if SynthFreq>InClkFreq
                DIV_NUM=1;
            else
                DIV_NUM=round(InClkFreq./ClkDVFreq);
            end

            clk0=hC.signal('Name','clk0','FiType','boolean');
            clkfb0=hC.signal('Name','clkfb0','FiType','boolean');
            clk125=hC.signal('Name','clk125','FiType','boolean');
            dcmclk125=hC.signal('Name','CLKFX','FiType','boolean');
            LOCKED=hC.signal('Name','LOCKED','FiType','boolean');
            notLocked=hC.signal('Name','notLocked','FiType','boolean');

            if(DIV_NUM==1)
                CLKDV='OPEN';
                DIV='2';
            else
                CLKDV=hC.signal('Name','CLKDV','FiType','boolean');
                DIV=num2str(DIV_NUM);
            end

            dcm=hC.component(...
            'UniqueName','DCM_BASE',...
            'InstName','dcm',...
            'Component',eda.internal.component.BlackBox({...
            'CLK0','OUTPUT','boolean',...
            'CLK180','OUTPUT','boolean',...
            'CLK270','OUTPUT','boolean',...
            'CLK2X','OUTPUT','boolean',...
            'CLK2X180','OUTPUT','boolean',...
            'CLK90','OUTPUT','boolean',...
            'CLKDV','OUTPUT','boolean',...
            'CLKFX','OUTPUT','boolean',...
            'CLKFX180','OUTPUT','boolean',...
            'LOCKED','OUTPUT','boolean',...
            'CLKFB','INPUT','boolean',...
            'CLKIN','INPUT','boolean',...
            'RST','INPUT','boolean'}),...
            'CLK0',clk0,...
            'CLK180','OPEN',...
            'CLK270','OPEN',...
            'CLK2X','OPEN',...
            'CLK2X180','OPEN',...
            'CLK90','OPEN',...
            'CLKDV',CLKDV,...
            'CLKFX',dcmclk125,...
            'CLKFX180','OPEN',...
            'LOCKED',LOCKED,...
            'CLKFB',clkfb0,...
            'CLKIN',hC.CLK_IN,...
            'RST',hC.RESET_IN);

            dcm.addprop('generic');
            dcm.generic=generics(...
            'CLKDV_DIVIDE','double',[DIV,'.000'],...
            'CLKIN_DIVIDE_BY_2','boolean','FALSE',...
            'CLKFX_DIVIDE','integer','2',...
            'CLKFX_MULTIPLY','integer','2',...
            'CLKIN_PERIOD','double',[clkPeriod,'.000'],...
            'CLKOUT_PHASE_SHIFT','string','"NONE"',...
            'CLK_FEEDBACK','string','"1X"',...
            'DCM_PERFORMANCE_MODE','string','"MAX_SPEED"',...
            'DFS_FREQUENCY_MODE','string','"LOW"',...
            'DLL_FREQUENCY_MODE','string','"LOW"',...
            'DUTY_CYCLE_CORRECTION','boolean','TRUE',...
            'DESKEW_ADJUST','string','"SYSTEM_SYNCHRONOUS"',...
            'PHASE_SHIFT','integer','0',...
            'STARTUP_WAIT','boolean','FALSE');

            dcm.addprop('NoHDLFiles');
            dcm.addprop('compDeclNotNeeded');
            dcm.addprop('wrapperFileNotNeeded');

            this.bufg(hC,clk0,clkfb0);
            this.bufg(hC,dcmclk125,clk125);


            hC.assign(' ~ LOCKED',notLocked);
            hC.assign(notLocked,hC.RESET_OUT);


            if(DIV_NUM==1)
                hC.assign(clkfb0,hC.DUTCLK);
            else
                this.bufg(hC,CLKDV,hC.DUTCLK);
            end

            this.ibufg(hC,hC.TXCLK_IN,hC.TXCLK_OUT);
            this.ibufg(hC,hC.RXCLK_IN,hC.RXCLK_OUT);


        end

    end
end
