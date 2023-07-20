function[rd_addr,f_sel,bin_sel]=dnnfpgaInterprocessorfifo2libConv_read_mem_encoder_sim(Xdiv3,Xmod3,Ydiv3,Ymod3,block_count,thread_count,Xdiv3_limit,Ydiv3_limit,opW,addroffset)
%#codegen

    coder.allowpcode('plain');

    rd_addr=Xdiv3+Ydiv3*Xdiv3_limit+block_count*Xdiv3_limit*Ydiv3_limit+addroffset;
    f_sel=thread_count;
    bin_sel=Ymod3+Xmod3*opW;

end

