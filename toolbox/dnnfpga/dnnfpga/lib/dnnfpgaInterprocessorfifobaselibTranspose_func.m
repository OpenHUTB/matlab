function data_out=dnnfpgaInterprocessorfifobaselibTranspose_func(data_in,BIN_SIZE,THREAD_NUM)
%#codegen

    coder.allowpcode('plain');

    data_in=reshape(data_in,[BIN_SIZE,THREAD_NUM]);
    data_in=permute(data_in,[2,1]);
    data_out=reshape(data_in,[THREAD_NUM*BIN_SIZE,1]);

end
