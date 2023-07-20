classdef Fcn<hdlimplbase.EmlImplBase



    methods
        function this=Fcn(block)
            supportedBlocks={...
            'built-in/Fcn',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','Generate HDL in native floating point mode',...
            'HelpText','Code generation for function expression');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc...
            );


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)

        function val=mustElaborateInPhase1(~,~,~)


            val=true;
        end

        v=validateBlock(this,hC)
    end

    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        newComp=elaborate(this,hN,hC)
        v=validate(this,hC)
    end

end

