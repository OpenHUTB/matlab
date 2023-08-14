function FFTHDLOptimized(obj)




    verobj=obj.ver;

    if~isR2016aOrEarlier(verobj)
        return;
    end

    FFTBlock='FFT HDL Optimized';
    IFFTBlock='IFFT HDL Optimized';

    FFTBlks=obj.findBlocksWithMaskType(FFTBlock);
    IFFTBlks=obj.findBlocksWithMaskType(IFFTBlock);

    blocks=[FFTBlks;IFFTBlks];

    if isempty(blocks)
        return;
    end

    if isR2013bOrEarlier(verobj)
        subsys_err=DAStudio.message('dsp:HDLFFT:BlockNotAvailableBefore14a',blocks{1});

        for i=1:numel(blocks)
            blk=blocks{i};
            subsys_msg=[get_param(blk,'MaskType'),'\n',subsys_err];
            obj.replaceWithEmptySubsystem(blk,[],subsys_msg);
        end

    else
        subsys_err=DAStudio.message('dsp:HDLFFT:BitReversedInput16bFeatureNotAvailable',blocks{1});
        for i=1:numel(blocks)
            blk=blocks{i};
            if strcmpi(get_param(blk,'BitReversedInput'),'on')

                subsys_msg=[get_param(blk,'MaskType'),'\n',subsys_err];
                obj.replaceWithEmptySubsystem(blk,[],subsys_msg);
            else

            end
        end
    end

end
