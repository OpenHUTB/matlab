function write_ready=dnnfpgaInterprocessorfifobaselibWrite_ready_gen(w_ptr,f0_full,f1_full)
%#codegen


    coder.allowpcode('plain');

    if((~f0_full)&&(~w_ptr))||((~f1_full)&&w_ptr)
        write_ready=true;
    else
        write_ready=false;
    end

end
