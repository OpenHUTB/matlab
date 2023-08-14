function fixblkinhdllib(this,blkh)









    if strcmpi(hdlgetblocklibpath(blkh),'dspobslib/Digital Filter')
        set_param(blkh,'IIRFiltStruct',...
        'Biquad direct form II transposed (SOS)');
    end


    this.setSampleModeForBlock(blkh);




