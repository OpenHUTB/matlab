function[rd_addr,rd_sel]=dnnfpgaInterprocessorfifo1libConv_read_mem_encoder_sim(X_count,Y_count,block_count,thread_count,X,Y)
%#codegen

    coder.allowpcode('plain');

    rd_addr=Y_count+X_count*Y+block_count*X*Y;
    rd_sel=thread_count;

end

