function bits=dnnfpgaIndexDataType(imgSizeLimit,paddingModeAddrW)



    padding=2^paddingModeAddrW;
    horz=imgSizeLimit(1)+2*padding;
    vert=imgSizeLimit(2)+2*padding;
    bits=ceil(log2(horz*vert));


end
