function FIRRateConverter(obj)











    verobj=obj.ver;

    if isR2015aOrEarlier(verobj)



        blocks=obj.findBlocksWithMaskType('FIR Rate Conversion',...
        'FilterSource','Auto');

        for i=1:length(blocks)
            blk=blocks{i};
            L_str=get_param(blk,'L');
            M_str=get_param(blk,'M');
            maxLM_str=['max(',L_str,',',M_str,')'];


            set_param(blk,...
            'FilterSource','Dialog parameters',...
            'h',[L_str,' .* firnyquist(24*',maxLM_str,', ',maxLM_str,', kaiser(1 + 24*',maxLM_str,', 0.1102*(80-8.71)))']);
        end
    end

    if isR2019bOrEarlier(verobj)

        libblks=obj.findBlocksWithMaskType('FIR Rate Conversion',...
        'RateMode','Allow multirate processing');


        coreblks=obj.findBlocks('BlockType','FIRSampleRateConverter');

        blocks=[libblks(:);coreblks(:)];

        msg='dsp:block:';

        for ii=1:numel(blocks)
            blk=blocks{ii};
            ph=get_param(blk,'PortHandles');
            numInputs=numel(ph.Inport);
            numOutputs=numel(ph.Outport);
            subsys_msg=DAStudio.message([msg,'EmptySubsystem_FIRRateConverter']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            replaceWithEmptySubsystem(obj,blk,subsys_msg,subsys_err);
        end

    end




end
