function data=readData(dataDescriptor,mem,num,offset,addrOffset)

    if nargin<3
        num=1;
    end

    if nargin<4
        offset=0;
    end

    if nargin<5
        addrOffset=dataDescriptor.memoryRegion.defaultAddrOffset;
    end

    num=uint32(num);
    offset=uint32(offset);

    if num>1
        data=[];
        for i=1:num
            dataOne=dnnfpga.dagnet.shared.readData(dataDescriptor,mem,1,uint32(i-1),addrOffset);
            sqz=squeeze(dataOne);
            if numel(size(sqz))==2&&rank(sqz)==1
                row=reshape(sqz,1,[]);
                data=cat(1,data,row);
            else
                data=cat(4,data,dataOne);
            end
        end
    else

        if dataDescriptor.net.dataFormat==dnnfpga.dagCompile.DataFormat.FC
            reshp=false;
        else
            reshp=true;
        end

        net=dataDescriptor.net;
        szOrig=net.size;


        sz=dnnfpga.dagCompile.DDRSupport.normalizeSizeStatic(szOrig,dataDescriptor.dataTransNum);
        readCount=dataDescriptor.getDataCount();
        sizeInBytes=dataDescriptor.getSizeInBytes();
        addr=dataDescriptor.memoryRegion.getAddr();
        addr=addr+uint32(addrOffset);
        addr=uint32(addr+offset*sizeInBytes);
        data=mem.read(addr,readCount);

        if reshp
            data=dnnfpga.format.convertDDRVectorFormatConv4To3DOutput(data,dataDescriptor.dataTransNum,sz);
        end

        sqz=squeeze(data);
        if numel(size(sqz))==2&&rank(sqz)==1
            data=reshape(sqz,1,[]);
        end

        data=trimData(data,szOrig);
    end
end

function data=trimData(dataIn,szTrimmed)
    rv=reshape(dataIn,1,[]);
    rv=rv(1:prod(szTrimmed));
    data=reshape(rv,szTrimmed);
end

