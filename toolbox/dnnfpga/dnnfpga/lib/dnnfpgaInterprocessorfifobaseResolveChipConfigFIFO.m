function cc=dnnfpgaInterprocessorfifobaseResolveChipConfigFIFO(bcc)



    fifop=dnnfpga.processorbase.fifo1Processor(bcc);
    cc=fifop.getCC();
end
