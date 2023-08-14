function FIRDecimator(obj)







    verobj=obj.ver;

    if isR2015aOrEarlier(verobj)



        blocks=obj.findBlocksWithMaskType('FIR Decimation',...
        'FilterSource','Auto');

        for i=1:length(blocks)
            blk=blocks{i};
            maxLM_str=get_param(blk,'D');


            set_param(blk,...
            'FilterSource','Dialog parameters',...
            'h',['firnyquist(24*',maxLM_str,', ',maxLM_str,', kaiser(1 + 24*',maxLM_str,', 0.1102*(80-8.71)))']);
        end
    end

    if isR2014bOrEarlier(verobj)

        blocks=obj.findBlocksWithMaskType('FIR Decimation','FilterSource','Input port');
        for i=1:numel(blocks)
            obj.replaceWithEmptySubsystem(blocks{i},...
            'FIR Decimator - Coefficients from Input Port',...
            DAStudio.message('dsp:block:coeffPortNotAvailable'));
        end
    end

end
