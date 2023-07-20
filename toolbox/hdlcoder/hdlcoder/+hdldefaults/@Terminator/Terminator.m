classdef Terminator<hdlimplbase.NoHDL


    methods
        function this=Terminator(block)

            supportedBlocks={'built-in/Terminator'};
            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Do not generate HDL',...
            'HelpText','No HDL will be emitted for this block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'No HDL'}...
            );
        end

    end

    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        registerImplParamInfo(this)
    end
end
