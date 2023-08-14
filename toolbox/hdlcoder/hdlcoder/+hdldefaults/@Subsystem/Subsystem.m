classdef Subsystem<hdlimplbase.HDLDirectCodeGen



    methods
        function this=Subsystem(block)
            supportedBlocks={...
            'built-in/SubSystem',...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Subsystem',...
            'HelpText','Associate Implementation Parameters with Subsystem');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames','Module');
        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateImplParams(this,hC)
        v=validateBlock(this,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        v=recurseIntoSubSystem(this)
    end

end

