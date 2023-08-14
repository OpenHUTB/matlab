

























function codedout=FddHSDSCH(chc,trblkin)
    if~iscell(trblkin)
        trblkin={trblkin};
        incell=0;
    else
        incell=1;
    end
    codedout_P=hsdsch(trblkin{1},chc.CodeGroup,chc.Modulation,chc.SystematicPriority,chc.RedundancyVersion,chc.VirtualBufferCapacity);

    if size(trblkin,2)==2
        codedout_S=hsdsch(trblkin{2},chc.CodeGroup,chc.Modulation2,chc.SystematicPriority2,chc.RedundancyVersion2,chc.VirtualBufferCapacity);
        codedout={codedout_P,codedout_S};
    else
        if incell
            codedout={codedout_P};
        else
            codedout=codedout_P;
        end
    end
end

function codedout=hsdsch(trblkin,codeGroup,modulationScheme,systematicPriority,redundancyVersion,virtualBufferCapacity)

    blkcrc=FddCRC(trblkin,1,'24');
    blkscrm=FddHSBitScrambling(blkcrc);

    cblks=FddTrCHCoding(blkscrm,'turbo');

    if ischar(modulationScheme)||isstring(modulationScheme)
        modulationScheme=FddGetModnFromString(modulationScheme);
    end
    PhyFrameCapacity=double(codeGroup)*960*(double(modulationScheme)+1);
    codedout=FddHSHarq(cblks,PhyFrameCapacity,systematicPriority,redundancyVersion,modulationScheme,virtualBufferCapacity);
end

