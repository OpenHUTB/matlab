function emcGenerateLLVMMex(srcMex,cgName,dstMex)




    if ispc
        glueDLL(srcMex,cgName,dstMex);
    else
        glueUnix(srcMex,cgName,dstMex);
    end
end


function[llvmbc,bcSize]=loadLLVMBitCode(filename)

    [cgFile,errmsg]=fopen(filename,'r');

    if cgFile<0
        error(['Read source cg file error with message: ',errmsg]);
    end

    llvmbc=fread(cgFile,'*uint8');

    bcSize=size(llvmbc,1);

    fclose(cgFile);
end


function write2newFile(dstMexName,data)
    newMexFile=fopen(dstMexName,'w+');

    if newMexFile<0
        error(['Read destination mex file error with message: ',errmsg]);
    end

    fwrite(newMexFile,data,'*uint8');
    fclose(newMexFile);
end


function mexData=loadTemplateMex(mexName)

    [mexFile,errmsg]=fopen(mexName,'r');

    if mexFile<0
        error(['Read srouce mex file error with message: ',errmsg]);
    end

    mexData=fread(mexFile,'*uint8');
    fclose(mexFile);
end



function out=encodeData(aNum,nBytes)
    hexStr=dec2hex(aNum,2*nBytes);
    out=uint8(zeros(nBytes,1));
    for i=1:nBytes
        out(nBytes-i+1)=hex2dec(hexStr(i*2-1:i*2));
    end
end



function out=decodeData(str,nBytes,outType)
    hexStr=char(zeros(1,2*nBytes));
    for i=1:nBytes
        idx=nBytes-i+1;
        hexStr(idx*2-1:idx*2)=dec2hex(str(i),2);
    end
    out=cast(hex2dec(hexStr),outType);
end



function glueDLL(srcMex,cgName,dstMex)

    [llvm_bit_code,bcSize]=loadLLVMBitCode(cgName);
    binary=loadTemplateMex(srcMex);


    bcTargetStr='Bitcode Size';
    LLVMBCLoc=strfind(binary',bcTargetStr);
    data=binary(1:LLVMBCLoc-1);


    peLoc=decodeData(data(61:64),4,'uint32')+1;













    peTable=data(peLoc:peLoc+23);

    assert(isequal(peTable(1:4),[80,69,0,0]'),'Faile to verify surrogateMex COFF Table magic keyword.');

    assert(isequal(peTable(5:6),[100,134]'),'Faile to verify surrogateMex COFF archite');


    numSec=decodeData(peTable(7:8),2,'uint32');




    FSAlignment=512;
    SecAlignment=4096;


    secTableLoc=peLoc+24+240;
    LLVMBCLoc=-1;
    LLVMSecID=-1;

    for i=1:numSec
        start=secTableLoc+(i-1)*40;
        currentTable=data(start:start+39);
        if isequal(currentTable(1:8),[46,76,76,86,77,66,67,0]')
            LLVMBCLoc=start;
            LLVMSecID=i;
            break;
        end
    end

    assert(LLVMSecID~=-1,'Unable to find LLVM section');
















    LLVMMemSizeLoc=LLVMBCLoc+8;
    memSize=int32(bcSize)+16;
    data(LLVMMemSizeLoc:LLVMMemSizeLoc+3)=encodeData(memSize,4);


    LLVMBCVRLoc=LLVMBCLoc+12;
    bcRVA=decodeData(data(LLVMBCVRLoc:LLVMBCVRLoc+3),4,'uint32');


    LLVMBCRawSizeLoc=LLVMBCLoc+16;
    diskSize=uint32(ceil(double(memSize)/FSAlignment)*FSAlignment);
    data(LLVMBCRawSizeLoc:LLVMBCRawSizeLoc+3)=encodeData(diskSize,4);


    LLVMBCPtrToRawLoc=LLVMBCLoc+20;
    bcLoc=decodeData(data(LLVMBCPtrToRawLoc:LLVMBCPtrToRawLoc+3),4,'uint32');



    prevRVA=bcRVA;
    prevMemSize=memSize;
    prevDiskOffset=bcLoc;
    prevDiskSize=diskSize;
    appendOffset=-1;

    for i=LLVMSecID+1:numSec
        start=secTableLoc+(i-1)*40;

        if i==LLVMSecID+1
            appendOffset=decodeData(data(start+20:start+23),4,'uint32');
        end


        VALoc=start+12;
        newVA=uint32(prevRVA+ceil(double(prevMemSize)/SecAlignment)*SecAlignment);
        data(VALoc:VALoc+3)=encodeData(newVA,4);
        prevRVA=newVA;


        prevMemSize=decodeData(data(start+8:start+11),4,'uint32');


        DiskOffset=start+20;
        newOffset=uint32(prevDiskOffset+double(prevDiskSize));
        data(DiskOffset:DiskOffset+3)=encodeData(newOffset,4);

        prevDiskOffset=newOffset;
        prevDiskSize=decodeData(data(start+16:start+19),4,'uint32');

        if isequal(data(start:start+7),[46,114,101,108,111,99,0,0]')


            data(peLoc+176:peLoc+179)=encodeData(prevRVA,4);
        end
    end


    prevImgSize=ceil(double(prevMemSize)/SecAlignment)*SecAlignment;
    data(peLoc+80:peLoc+83)=encodeData(prevRVA+prevImgSize,4);



    LLVMBCLoc=size(data,1)+1;
    data=[data;zeros(diskSize,1,'uint8')];

    sizeStr=int2str(bcSize);
    data(LLVMBCLoc:LLVMBCLoc+length(sizeStr)-1)=sizeStr;

    LLVMBCLoc=LLVMBCLoc+16;
    data(LLVMBCLoc:LLVMBCLoc+bcSize-1)=llvm_bit_code;


    data=[data(1:end-1);binary(appendOffset:end)];

    write2newFile(dstMex,data);

end

function glueUnix(mexName,cgName,dstMex)

    [llvm_bit_code,bcSize]=loadLLVMBitCode(cgName);
    binary=loadTemplateMex(mexName);

    bcOffset=length(binary);

    sizeTag='Bitcode Size';
    offseTag='Bitcode Offset';
    sizeStr=int2str(bcSize);
    offsetStr=int2str(bcOffset);


    loc=strfind(binary',sizeTag);
    binary(loc:loc+15)=uint8(zeros(16,1));
    binary(loc:loc+length(sizeStr)-1)=sizeStr;


    loc=strfind(binary',offseTag);
    binary(loc:loc+15)=uint8(zeros(16,1));
    binary(loc:loc+length(offsetStr)-1)=offsetStr;


    binary=[binary;llvm_bit_code];


    write2newFile(dstMex,binary);
end
