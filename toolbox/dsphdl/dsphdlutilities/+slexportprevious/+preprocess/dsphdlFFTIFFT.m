function dsphdlFFTIFFT(obj)




    FFTBlock='dsphdlxfrm2/FFT';
    IFFTBlock='dsphdlxfrm2/IFFT';
    verobj=obj.ver;
    fftblocks=obj.findLibraryLinksTo(FFTBlock);
    ifftblocks=obj.findLibraryLinksTo(IFFTBlock);
    blocks=[fftblocks;ifftblocks];
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2013bOrEarlier(verobj)


            for i=1:n2bReplaced
                blk=blocks{i};

                subsys_msg=get_param(blk,'MaskType');
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end
        elseif isR2016aOrEarlier(verobj)
            subsys_err=DAStudio.message('dsp:HDLFFT:BitReversedInput16bFeatureNotAvailable',blocks{1});
            for i=1:numel(blocks)
                blk=blocks{i};
                if strcmpi(get_param(blk,'BitReversedInput'),'on')

                    subsys_msg=[get_param(blk,'MaskType'),'\n',subsys_err];
                    obj.replaceWithEmptySubsystem(blk,[],subsys_msg);
                end
            end
        end
    end
end
