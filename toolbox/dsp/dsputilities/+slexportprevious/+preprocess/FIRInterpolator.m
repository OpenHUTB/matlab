function FIRInterpolator(obj)







    verobj=obj.ver;

    if isR2015aOrEarlier(verobj)



        blocks=obj.findBlocksWithMaskType('FIR Interpolation',...
        'FilterSource','Auto');

        for i=1:length(blocks)
            blk=blocks{i};
            L_str=get_param(blk,'L');
            maxLM_str=L_str;


            set_param(blk,...
            'FilterSource','Dialog parameters',...
            'h',[L_str,' .* firnyquist(24*',maxLM_str,', ',maxLM_str,', kaiser(1 + 24*',maxLM_str,', 0.1102*(80-8.71)))']);
        end
    end

    if isR2014aOrEarlier(verobj)

        blocks=obj.findBlocksWithMaskType('FIR Interpolation',...
        'FilterSource','Input port');
        for i=1:numel(blocks)
            obj.replaceWithEmptySubsystem(blocks{i},...
            'FIR Interpolator - Coefficients from Input Port',...
            DAStudio.message('dsp:block:coeffPortNotAvailable'));
        end
    end

end
