classdef ZCU102<soc.xilboard.XilinxBoardBase

    properties
    end
    methods
        function obj=ZCU102
            obj.Name='Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit';
            obj.BoardID='zcu102';
            obj.Device='xczu9eg-ffvb1156-2-e';

            obj.InputClk=struct(...
            'source','C0_SYS_CLK',...
            'freq','300',...
            'type','diff',...
            'std','IOSTANDARD DIFF_SSTL12',...
            'pin',{{'AL7','AL8'}});
            obj.InputRst=struct(...
            'source','sys_rst',...
            'polarity','active_high',...
            'std','IOSTANDARD LVCMOS33',...
            'pin','AM13');

            obj.LED=struct(...
            'desc',{'GPIO_LED_0','GPIO_LED_1','GPIO_LED_2','GPIO_LED_3','GPIO_LED_4','GPIO_LED_5','GPIO_LED_6','GPIO_LED_7'},...
            'std','IOSTANDARD LVCMOS33',...
            'pin',{'AG14','AF13','AE13','AJ14','AJ15','AH13','AH14','AL12'});

            obj.DIPSwitch=struct(...
            'desc',{'GPIO_DIP_SW0','GPIO_DIP_SW1','GPIO_DIP_SW2','GPIO_DIP_SW3','GPIO_DIP_SW4','GPIO_DIP_SW5','GPIO_DIP_SW6','GPIO_DIP_SW7'},...
            'std','IOSTANDARD LVCMOS33',...
            'pin',{'AN14','AP14','AM14','AN13','AN12','AP12','AL13','AK13'});

            obj.PushButton=struct(...
            'desc',{'GPIO_SW_N','GPIO_SW_E','GPIO_SW_W','GPIO_SW_S','GPIO_SW_C'},...
            'std','IOSTANDARD LVCMOS33',...
            'pin',{'AG15','AE14','AF15','AE15','AG13'});

            obj.PSDDRSize=2048;
        end
    end
end
