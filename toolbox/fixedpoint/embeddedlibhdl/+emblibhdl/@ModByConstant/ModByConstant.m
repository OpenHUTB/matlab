classdef ModByConstant<hdlimplbase.EmlImplBase








    methods
        function this=ModByConstant(block)

            supportedBlocks={...
            ['embmathops/Modulo by Constant',newline,'HDL Optimized'],...
            'fixed.system.ModByConstant',...
            'fixed.system.internal.modbyconstant_hdl'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Modulo by Constant',...
            'HelpText','HDL Support for Modulo by Constant');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

        registerImplParamInfo(this)
        varargout=makeValidLine(~,hN,inSignal,outSignal,blkInfo)
        makeSubNet(~,hN,inSignal,outSignal,blkInfo)
        makeMulByDenominator(~,hN,inSignal,outSignal,blkInfo)
        bool=hasDesignDelay(~,~,~)
        blkInfo=getBlockInfo(~,hC)
        hCNew=elaborate(this,hN,hC)
        elabModViaCast(~,hN,inSignal,outSignal,blkInfo)

    end
end
