classdef Spartan6<eda.fpga.Xilinx





    methods
        function this=Spartan6(varargin)
            this.FPGAVendor='Xilinx';
            this.FPGAFamily='Spartan6';
            this.minDCMFreq=0.5;
            this.maxDCMFreq=666.667;
            this.SynthesisFrequency='100MHz';
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                this.FPGADevice=arg.Device;
                this.FPGASpeed=arg.Speed;
                this.FPGAPackage=arg.Package;
                if isfield(arg,'Frequency')
                    this.SynthesisFrequency=arg.Frequency;
                end
            end
        end

        function hC=ClkMgr_GMII(this,SYSCLK,SynthFreq,varargin)
            if nargin<=3
                hC=eda.internal.component.WhiteBox(...
                {'CLK_IN','INPUT','ClockPort',...
                'RESET_IN','INPUT','boolean',...
                'RXCLK_IN','INPUT','boolean',...
                'DUTCLK','OUTPUT','boolean',...
                'MACRXCLK','OUTPUT','boolean',...
                'MACTXCLK','OUTPUT','boolean',...
                'TXCLK','OUTPUT','boolean',...
                'RESET_OUT','OUTPUT','boolean'});
            else
                hC=eda.internal.component.WhiteBox(...
                {'CLK_IN','INPUT','ClockPort',...
                'CLK_OUT','OUTPUT','boolean',...
                'RESET_IN','INPUT','boolean',...
                'RXCLK_IN','INPUT','boolean',...
                'DUTCLK','OUTPUT','boolean',...
                'MACRXCLK','OUTPUT','boolean',...
                'MACTXCLK','OUTPUT','boolean',...
                'TXCLK','OUTPUT','boolean',...
                'RESET_OUT','OUTPUT','boolean'});
            end

            InClkFreq=SYSCLK.Frequency;
            ClkDVFreq=SynthFreq;
            ClkFXFreq=125;

            clkPeriod=sprintf('%f',1000./(InClkFreq));
            if SynthFreq>InClkFreq
                DIV_NUM=1;
            else
                DIV_NUM=round(InClkFreq./ClkDVFreq);
            end

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
            clk125_180=hC.signal('Name','clk125_180','FiType','boolean');
            dcmclk125=hC.signal('Name','dcmclk125','FiType','boolean');
            dcmclk125_180=hC.signal('Name','dcmclk125_180','FiType','boolean');
            LOCKED=hC.signal('Name','LOCKED','FiType','boolean');
            rxClk_internal=hC.signal('Name','rxClk_internal','FiType','boolean');
            notLocked=hC.signal('Name','notLocked','FiType','boolean');

            if(DIV_NUM==1)
                CLKDV='OPEN';
                DIV='2';
            else
                CLKDV=hC.signal('Name','CLKDV','FiType','boolean');
                DIV=num2str(DIV_NUM);
            end

            dcm=hC.component(...
            'UniqueName','DCM_SP',...
            'InstName','dcm',...
            'Component',eda.internal.component.BlackBox({...
            'CLKIN','INPUT','boolean',...
            'CLKFB','INPUT','boolean',...
            'CLK0','OUTPUT','boolean',...
            'CLK90','OUTPUT','boolean',...
            'CLK180','OUTPUT','boolean',...
            'CLK270','OUTPUT','boolean',...
            'CLK2X','OUTPUT','boolean',...
            'CLK2X180','OUTPUT','boolean',...
            'CLKFX','OUTPUT','boolean',...
            'CLKFX180','OUTPUT','boolean',...
            'CLKDV','OUTPUT','boolean',...
            'PSCLK','INPUT','boolean',...
            'PSEN','INPUT','boolean',...
            'PSINCDEC','INPUT','boolean',...
            'PSDONE','OUTPUT','boolean',...
            'LOCKED','OUTPUT','boolean',...
            'STATUS','OUTPUT','boolean',...
            'RST','INPUT','boolean',...
            'DSSEN','INPUT','boolean'}),...
            'CLKIN',hC.CLK_IN,...
            'CLKFB',clkfb0,...
            'CLK0',clk0,...
            'CLK90','OPEN',...
            'CLK180','OPEN',...
            'CLK270','OPEN',...
            'CLK2X','OPEN',...
            'CLK2X180','OPEN',...
            'CLKFX',dcmclk125,...
            'CLKFX180',dcmclk125_180,...
            'CLKDV',CLKDV,...
            'PSCLK','LOW',...
            'PSEN','LOW',...
            'PSINCDEC','LOW',...
            'PSDONE','OPEN',...
            'LOCKED',LOCKED,...
            'STATUS','OPEN',...
            'RST',hC.RESET_IN,...
            'DSSEN','LOW');


            dcm.addprop('generic');
            dcm.generic=generics(...
            'CLKDV_DIVIDE','double',[DIV,'.000'],...
            'CLKIN_DIVIDE_BY_2','boolean','FALSE',...
            'CLKFX_DIVIDE','integer',DIV125,...
            'CLKFX_MULTIPLY','integer',MULT125,...
            'CLKIN_PERIOD','double',clkPeriod,...
            'CLKOUT_PHASE_SHIFT','string','"NONE"',...
            'CLK_FEEDBACK','string','"1X"',...
            'DESKEW_ADJUST','string','"SYSTEM_SYNCHRONOUS"',...
            'PHASE_SHIFT','integer','0',...
            'STARTUP_WAIT','boolean','FALSE');

            dcm.addprop('NoHDLFiles');
            dcm.addprop('compDeclNotNeeded');
            dcm.addprop('wrapperFileNotNeeded');

            this.bufg(hC,clk0,clkfb0);
            this.bufg(hC,dcmclk125,clk125);
            this.bufg(hC,dcmclk125_180,clk125_180);


            hC.assign(' ~ LOCKED',notLocked);
            hC.assign(notLocked,hC.RESET_OUT);

            hC.assign(clk125,hC.MACTXCLK);
            hC.assign(hC.RXCLK_IN,rxClk_internal);
            hC.assign(rxClk_internal,hC.MACRXCLK);
            this.oddr(hC,clk125,clk125_180,'HIGH','LOW','HIGH',hC.TXCLK,'LOW','LOW');

            if(DIV_NUM==1)
                hC.assign(clkfb0,hC.DUTCLK);
            else
                this.bufg(hC,CLKDV,hC.DUTCLK);
            end

            if nargin>3
                hC.assign(clkfb0,hC.CLK_OUT);
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

            InClkFreq=SYSCLK.Frequency;
            ClkDVFreq=SynthFreq;
            clkPeriod=sprintf('%f',1000./(InClkFreq));

            if SynthFreq>InClkFreq
                DIV_NUM=1;
            else
                DIV_NUM=round(InClkFreq./ClkDVFreq);
            end

            hC.Partition.Device.PartInfo.FPGAVendor='Xilinx';
            hC.UniqueName='MWClkMgr';
            hC.addprop('enableCodeGen');
            hC.flatten=false;

            clk0=hC.signal('Name','clk0','FiType','boolean');
            clkfb0=hC.signal('Name','clkfb0','FiType','boolean');
            clk125=hC.signal('Name','clk125','FiType','boolean');
            clk125_180=hC.signal('Name','clk125_180','FiType','boolean');
            dcmclk125=hC.signal('Name','dcmclk125','FiType','boolean');
            dcmclk125_180=hC.signal('Name','dcmclk125_180','FiType','boolean');
            LOCKED=hC.signal('Name','LOCKED','FiType','boolean');
            notLocked=hC.signal('Name','notLocked','FiType','boolean');

            if(DIV_NUM==1)
                CLKDV='OPEN';
                DIV='2';
            else
                CLKDV=hC.signal('Name','CLKDV','FiType','boolean');
                if DIV_NUM>16
                    DIV_NUM=16;
                end
                DIV=num2str(DIV_NUM);
            end

            dcm=hC.component(...
            'UniqueName','DCM_SP',...
            'InstName','dcm',...
            'Component',eda.internal.component.BlackBox({...
            'CLKIN','INPUT','boolean',...
            'CLKFB','INPUT','boolean',...
            'CLK0','OUTPUT','boolean',...
            'CLK90','OUTPUT','boolean',...
            'CLK180','OUTPUT','boolean',...
            'CLK270','OUTPUT','boolean',...
            'CLK2X','OUTPUT','boolean',...
            'CLK2X180','OUTPUT','boolean',...
            'CLKFX','OUTPUT','boolean',...
            'CLKFX180','OUTPUT','boolean',...
            'CLKDV','OUTPUT','boolean',...
            'PSCLK','INPUT','boolean',...
            'PSEN','INPUT','boolean',...
            'PSINCDEC','INPUT','boolean',...
            'PSDONE','OUTPUT','boolean',...
            'LOCKED','OUTPUT','boolean',...
            'STATUS','OUTPUT','boolean',...
            'RST','INPUT','boolean',...
            'DSSEN','INPUT','boolean'}),...
            'CLKIN',hC.CLK_IN,...
            'CLKFB',clkfb0,...
            'CLK0',clk0,...
            'CLK90','OPEN',...
            'CLK180','OPEN',...
            'CLK270','OPEN',...
            'CLK2X','OPEN',...
            'CLK2X180','OPEN',...
            'CLKFX',dcmclk125,...
            'CLKFX180',dcmclk125_180,...
            'CLKDV',CLKDV,...
            'PSCLK','LOW',...
            'PSEN','LOW',...
            'PSINCDEC','LOW',...
            'PSDONE','OPEN',...
            'LOCKED',LOCKED,...
            'STATUS','OPEN',...
            'RST',hC.RESET_IN,...
            'DSSEN','LOW');

            dcm.addprop('generic');
            dcm.generic=generics(...
            'CLKDV_DIVIDE','double',[DIV,'.000'],...
            'CLKIN_DIVIDE_BY_2','boolean','FALSE',...
            'CLKFX_DIVIDE','integer','2',...
            'CLKFX_MULTIPLY','integer','2',...
            'CLKIN_PERIOD','double',clkPeriod,...
            'CLKOUT_PHASE_SHIFT','string','"NONE"',...
            'CLK_FEEDBACK','string','"1X"',...
            'DESKEW_ADJUST','string','"SYSTEM_SYNCHRONOUS"',...
            'PHASE_SHIFT','integer','0',...
            'STARTUP_WAIT','boolean','FALSE');

            dcm.addprop('NoHDLFiles');
            dcm.addprop('compDeclNotNeeded');
            dcm.addprop('wrapperFileNotNeeded');

            this.bufg(hC,clk0,clkfb0);
            this.bufg(hC,dcmclk125,clk125);
            this.bufg(hC,dcmclk125_180,clk125_180);


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

        function oddr(~,hC,clk,clk180,in1,in2,enb,out,set,reset)
            oddr=hC.component(...
            'UniqueName','ODDR2',...
            'InstName','ODDR2',...
            'Component',eda.internal.component.BlackBox({...
            'Q','OUTPUT','boolean',...
            'C0','INPUT','boolean',...
            'C1','INPUT','boolean',...
            'D0','INPUT','boolean',...
            'D1','INPUT','boolean',...
            'CE','INPUT','boolean',...
            'R','INPUT','boolean',...
            'S','INPUT','boolean'}),...
            'Q',out,...
            'C0',clk,...
            'C1',clk180,...
            'D0',in1,...
            'D1',in2,...
            'CE',enb,...
            'R',reset,...
            'S',set);


            oddr.addprop('generic');
            oddr.generic=generics('DDR_ALIGNMENT','string','"NONE"',...
            'INIT','ufix1','''0''',...
            'SRTYPE','string','"SYNC"');

            oddr.addprop('NoHDLFiles');
            oddr.addprop('compDeclNotNeeded');
            oddr.addprop('wrapperFileNotNeeded');
        end



    end
end
