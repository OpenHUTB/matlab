classdef MATLABDatapath<hdlimplbase.SFBase


    methods
        function this=MATLABDatapath(block)
            supportedBlocks={...
            'eml_lib/MATLAB Function',...
            };
            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'MATLAB Datapath'});
        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        params=hideImplParams(~,~,~)
    end

    methods(Hidden)
        v=validate(this,hC)
    end

    methods(Static)
        v=ml2pirValidate(this,hC)
        hNewC=ml2pirElaborate(this,hN,hC)
    end

end

