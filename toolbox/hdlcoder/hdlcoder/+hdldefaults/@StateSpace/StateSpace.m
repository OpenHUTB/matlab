classdef StateSpace<hdlimplbase.HDLRecurseIntoSubsystem



    methods
        function this=StateSpace(block)
            supportedBlocks={...
            'hdlssclib/Dynamic State-Space',...
            'simulink/Additional Math & Discrete/Additional Discrete/Fixed-Point State-Space',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for Dynamic State-Space Block',...
            'HelpText','HDL will be emitted for this Dynamic State-Space block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end

    end

    methods(Hidden)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end

end

