function FIRHDLOptimized(obj)




    FIRBlock='Discrete FIR Filter HDL Optimized';
    verobj=obj.ver;
    blocks=obj.findBlocksWithMaskType(FIRBlock);
    n2bReplaced=length(blocks);

    if n2bReplaced>0
        if isR2016bOrEarlier(verobj)
            subsys_err=DAStudio.message('dsp:HDLFIRFilter:BlockNotAvailableBefore17a',blocks{1});

            for i=1:n2bReplaced
                blk=blocks{i};
                subsys_msg=[get_param(blk,'MaskType'),'\n',subsys_err];
                replaceWithEmptySubsystem(obj,blk,[],subsys_msg);
            end

        elseif isReleaseOrEarlier(verobj,'R2018a')
            coder.internal.warning('dsp:HDLFIRFilter:ValidInputPort18bFeatureIsMandatory',blocks{1});
            for i=1:n2bReplaced
                blk=blocks{i};
                if strcmpi(get_param(blk,'NumeratorSource'),'Input port (Parallel interface)')
                    coder.internal.warning('dsp:HDLFIRFilter:ProgramableCoefficient19aFeature',blk);
                end
                if strcmpi(get_param(blk,'ResetInputPort'),'on')||strcmpi(get_param(blk,'HDLGlobalReset'),'on')
                    coder.internal.warning('dsp:HDLFIRFilter:ResetOption18bFeature',blk);
                end
                if strcmpi(get_param(blk,'FilterStructure'),'Partly serial systolic')
                    set_param(blk,'FilterStructure','Direct form systolic')
                    len=length(eval(get_param(blk,'Numerator')));
                    if strcmpi(get_param(blk,'SerializationOption'),'Minimum number of cycles between valid input samples')
                        sharingFactor=get_param(blk,'NumberOfCycles');
                        coder.internal.warning('dsp:HDLFIRFilter:BackwardCompatibilityForPartlySerial1',blk,sharingFactor);
                    else
                        sharingFactor=get_param(blk,'NumberOfMultipliers');
                        sharingFactorR=ceil(len/str2double(sharingFactor));
                        sharingFactorC=ceil(2*len/str2double(sharingFactor));
                        coder.internal.warning('dsp:HDLFIRFilter:BackwardCompatibilityForPartlySerial2',blk,sharingFactorR,sharingFactorC);
                    end
                    coder.internal.warning('dsp:HDLFIRFilter:ReadyPort18bFeature',blk);
                end
            end
        elseif isReleaseOrEarlier(verobj,'R2018b')

            for i=1:n2bReplaced
                blk=blocks{i};

                if strcmpi(get_param(blk,'NumeratorSource'),'Input port (Parallel interface)')
                    coder.internal.warning('dsp:HDLFIRFilter:ProgramableCoefficient19aFeature',blk);
                end
                if strcmpi(get_param(blk,'FilterStructure'),'Partly serial systolic')
                    set_param(blk,'FilterStructure','Direct form systolic')
                    len=length(eval(get_param(blk,'Numerator')));
                    if strcmpi(get_param(blk,'SerializationOption'),'Minimum number of cycles between valid input samples')
                        sharingFactor=get_param(blk,'NumberOfCycles');
                        coder.internal.warning('dsp:HDLFIRFilter:BackwardCompatibilityForPartlySerial1',blk,sharingFactor);
                    else
                        sharingFactor=get_param(blk,'NumberOfMultipliers');
                        sharingFactorR=ceil(len/str2double(sharingFactor));
                        sharingFactorC=ceil(2*len/str2double(sharingFactor));
                        coder.internal.warning('dsp:HDLFIRFilter:BackwardCompatibilityForPartlySerial2',blk,sharingFactorR,sharingFactorC);
                    end
                end
            end
        end
    end
end

