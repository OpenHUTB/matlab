classdef EmbeddedMATLAB<hdlimplbase.SFBase



    methods
        function this=EmbeddedMATLAB(block)
            supportedBlocks={...
            'eml_lib/MATLAB Function',...
            };
            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'MATLAB Function'},...
            'DeprecatedArchName','Embedded MATLAB');
        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
    end


    methods(Hidden)
        v=validate(this,hC)
        msgObj=validateForFloatPorts(~,~)
        val=useML2PIR(~,hC)
    end

end

