function wr_en=dnnfpgaPaddinglogiclibPadding_write_mem_encoder(fc_sel,valid,BIN_SIZE)
%#codegen

    coder.allowpcode('plain');

    wr_en=false(BIN_SIZE,1);
    wr_en(fc_sel+1)=valid;
end