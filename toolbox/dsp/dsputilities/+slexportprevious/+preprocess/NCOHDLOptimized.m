function NCOHDLOptimized(obj)




    verobj=obj.ver;





    NCOBlock='NCO HDL Optimized';

    NCOBlks=obj.findBlocksWithMaskType(NCOBlock);


    blocks=NCOBlks;

    if isempty(blocks)
        return;
    end

    if isR2019bOrEarlier(verobj)
        subsys_warning=DAStudio.message('dsp:HDLNCO:SamplesPerFrame20aFeatureNotAvailable',blocks{1},ver_info(verobj));
        for i=1:numel(blocks)
            blk=blocks{i};
            samplesPerFrame=str2double(get_param(blk,'SamplesPerFrame'));
            if samplesPerFrame>1

                warning('dsp:HDLNCO:SamplesPerFrame20aFeatureNotAvailable',subsys_warning);
            end
        end
    end

end
