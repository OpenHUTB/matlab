function out=castToIOBitWidthInVector(in,packageElementSize,ioBitWidth)
%#codegen


    coder.allowpcode('plain');
    elementBitWidth=32;
    ioElementSize=ioBitWidth/elementBitWidth;
    assert(elementBitWidth<=ioBitWidth);
    assert(mod(ioBitWidth,elementBitWidth)==0);
    assert(mod(length(in),packageElementSize)==0);
    packageNum=length(in)/packageElementSize;
    packageIOWordSize=ceil(packageElementSize*elementBitWidth/ioBitWidth);
    assert(mod(packageElementSize,packageIOWordSize)==0);
    out=fi(zeros(ioElementSize,packageIOWordSize*packageNum),0,elementBitWidth,0);
    for i=0:packageNum-1
        package=castToUfix(in(i*packageElementSize+1:(i+1)*packageElementSize));
        temp=fi(zeros(ioElementSize,packageIOWordSize),0,elementBitWidth,0);
        for j=0:packageElementSize-1
            firstIOWordIdx=floor(j/ioElementSize);
            firstIOWordOffset=mod(j,ioElementSize);
            assert(firstIOWordOffset+elementBitWidth<=ioBitWidth);
            pk=package(j+1);
            temp(firstIOWordOffset+1,firstIOWordIdx+1)=pk;
        end
        out(:,i*packageIOWordSize+1:(i+1)*packageIOWordSize)=temp;
    end
end

function out=castToUfix(in)
    switch(lower(class(in)))
    case 'logical'
        out=fi(in,0,1,0);
    case 'double'
        assert(false);
    case 'single'
        out=dnnfpga.assembler.ConvtoUint32U(in);
    case 'half'
        out=dnnfpga.assembler.ConvtoUint32U(in);
    otherwise
        assert(isnumeric(in));
        out=in;
    end
end
