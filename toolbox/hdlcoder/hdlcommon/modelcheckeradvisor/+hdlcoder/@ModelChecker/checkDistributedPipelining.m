function flag=checkDistributedPipelining(this)




    distributed_pipelining_list={'Tapped Delay Line','M-PSK Demodulator Baseband','M-PSK Modulator Baseband',...
    'QPSK Demodulator Baseband','QPSK Modulator Baseband','BPSK Demodulator Baseband','BPSK Modulator Baseband',...
    'PN Sequence Generator','Repeat','HDL Counter','LMS Filter','Sine Wave','Viterbi Decoder','Counter Limited',...
    'Counter Free-Running','FrameConversion'};
    distributed_pipelining_sources=strjoin(distributed_pipelining_list,'|');

    [flag,blocks]=this.getMatchingHandleAndMaskedBlocks(distributed_pipelining_sources,'no-distributed-pipelining');%#ok<ASGLU>
end
