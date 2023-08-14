classdef ModelReference<hdlimplbase.EmlImplBase



    methods
        function this=ModelReference(block)
            supportedBlocks={...
            'built-in/ModelReference',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Model Reference',...
            'HelpText','Complete Model Reference support');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames',{'ModelReference'});

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        [inPortNames,outPortNames]=getPortNamesFromSimulink(~,blockHandle)
        stateInfo=getStateInfo(this,hC)
        optimize=optimizeForModelGen(~,~,~)
        registerImplParamInfo(this)
        v=validateImplParams(this,hC)
        v=validateBlock(this,hC)
    end

end

