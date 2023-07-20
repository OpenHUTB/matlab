classdef PositiveNormalizedReciprocal<hdlimplbase.HDLRecurseIntoSubsystem






























    methods
        function this=PositiveNormalizedReciprocal(block)




            supportedBlocks={...
            'embreciprocals/Positive Normalized Reciprocal HDL Optimized',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for the Positive Normalized Reciprocal HDL Optimized block',...
            'HelpText','HDL will be emitted for the Positive Normalized Reciprocal HDL Optimized block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');

        end
    end

    methods(Hidden)

        function v_settings=block_validate_settings(~,~)





            v_settings=struct;


            v_settings.checkblock=true;
            v_settings.checknfp=true;
        end


        function v=validateBlock(~,hC)




            v=hdlvalidatestruct;


            hasFloatingPoint=fixed.emblib.checkForFloatInputsOutputs(hC);


            nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
            if nfpMode&&hasFloatingPoint
                v(1)=hdlvalidatestruct(1,...
                message('fixed:emblib:NfpNotSupported',hC.Name));
            end

        end

    end

end

