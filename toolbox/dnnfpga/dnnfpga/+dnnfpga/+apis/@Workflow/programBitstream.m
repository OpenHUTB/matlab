function programBitstream(this,verbose)




    if nargin<2
        verbose=this.DefaultVerbose;
    end


    try


        fpgaChecksum=this.readChecksum;
        isMatch=isequal(fpgaChecksum,this.BitstreamChecksum);
    catch



        isMatch=false;
    end


    if~isMatch




        this.disconnectTarget();


        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ProgFPGAUsingTarget',string(this.Target.Interface)))
        this.Target.programBitstream(this.hBitstream);








        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ProgFPGACompl'));

    else
        dnnfpga.disp(message('dnnfpga:dnnfpgadisp:ProgBitstreamSkip'),verbose);
    end
end


