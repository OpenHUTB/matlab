function wr_en=dnnfpgaInterprocessorfifobaselibConv_write_mem_encoder(fc_sel,T_valid,valid,FC_THREAD_NUM)
%#codegen



    coder.allowpcode('plain');

    wr_en=false(FC_THREAD_NUM,1);
    if valid
        wr_en(fc_sel+1)=T_valid;
    end

end

