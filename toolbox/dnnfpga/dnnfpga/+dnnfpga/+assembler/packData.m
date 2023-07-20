function out=packData(in,packageSize,outTypeBitWidth,ioBitWidth)
%#codegen



    coder.allowpcode('plain');

    assert(outTypeBitWidth<=ioBitWidth);
    assert(mod(ioBitWidth,outTypeBitWidth)==0);
    assert(mod(length(in),packageSize)==0);
    packageNum=length(in)/packageSize;
    packageIOWordSize=ceil(packageSize*outTypeBitWidth/ioBitWidth);
    if(isinteger(in))
        out=int8(zeros(1,packageIOWordSize*packageNum));
    else
        out=zeros(1,packageIOWordSize*packageNum);
    end
    in1=reshape(in,packageSize,packageNum);
    in2=dnnfpga.assembler.padImage(in1,[mod(-packageSize,ioBitWidth/outTypeBitWidth),0],'post');
    out=reshape(in2,1,numel(in2));
end






































