function prepareAndGenerateSystemCTB(this,~,emlDutInterface,loggedData)




    out=[];
    outIndex=1;
    complexRealPostfix=this.hCgInfo.codegenSettings.ComplexRealPostfix;
    complexImagPostfix=this.hCgInfo.codegenSettings.ComplexImagPostfix;
    toolName=this.hCgInfo.codegenSettings.SynthesisTool;
    for i=1:emlDutInterface.numOut
        isSigned=emlDutInterface.outputTypesInfo{i}.issigned;
        wordSize=emlDutInterface.outputTypesInfo{i}.wordsize;
        frac=emlDutInterface.outputTypesInfo{i}.binarypoint;
        isIntegerType=(wordSize+frac==wordSize);

        fxpName=getFxpName(toolName,isSigned,isIntegerType,wordSize,frac);

        out(outIndex).name=emlDutInterface.outportNames{i};

        if any(strcmp(out(outIndex).name,emlDutInterface.inportNames))
            out(outIndex).name=out(outIndex).name+"_out";
        end

        out(outIndex).type=fxpName;
        out(outIndex).isIntType=isIntegerType;
        out(outIndex).isVector=emlDutInterface.outputTypesInfo{i}.isvector;
        out(outIndex).dim=emlDutInterface.outputTypesInfo{i}.dims;
        out(outIndex).isSigned=isSigned;

        if emlDutInterface.outputTypesInfo{i}.iscomplex
            out(outIndex+1)=out(outIndex);
            currName=out(outIndex).name;
            out(outIndex).name=[currName,complexRealPostfix];
            out(outIndex+1).name=[currName,complexImagPostfix];
        end

        outData=loggedData.outputs{i};
        if out(outIndex).isVector
            if emlDutInterface.outputTypesInfo{i}.iscomplex

                out(outIndex).isConst=isConstVector(real(outData));
                if out(outIndex).isConst
                    out(outIndex).val=getConstVecInHexFormat(fi(real(outData)));
                end


                out(outIndex+1).isConst=isConstVector(imag(outData));
                if out(outIndex+1).isConst
                    out(outIndex+1).val=getConstVecInHexFormat(fi(imag(outData)));
                end
            else
                out(outIndex).isConst=isConstVector(outData);
                if out(outIndex).isConst
                    out(outIndex).val=getConstVecInHexFormat(fi(outData));
                end
            end
        else
            if emlDutInterface.outputTypesInfo{i}.iscomplex

                [out(outIndex).isConst,out(outIndex).val]=processScalar(real(outData));
                [out(outIndex+1).isConst,out(outIndex+1).val]=processScalar(imag(outData));
            else
                [out(outIndex).isConst,out(outIndex).val]=processScalar(outData);
            end
        end


        if emlDutInterface.outputTypesInfo{i}.iscomplex
            outIndex=outIndex+2;
        else
            outIndex=outIndex+1;
        end
    end

    in=[];
    inIndex=1;
    for i=1:emlDutInterface.numIn
        isSigned=emlDutInterface.inputTypesInfo{i}.issigned;
        wordSize=emlDutInterface.inputTypesInfo{i}.wordsize;
        frac=emlDutInterface.inputTypesInfo{i}.binarypoint;
        isIntegerType=(wordSize+frac==wordSize);

        fxpName=getFxpName(toolName,isSigned,isIntegerType,wordSize,frac);

        in(inIndex).name=emlDutInterface.inportNames{i};
        in(inIndex).type=fxpName;
        in(inIndex).isIntType=isIntegerType;
        in(inIndex).isVector=emlDutInterface.inputTypesInfo{i}.isvector;
        in(inIndex).dim=emlDutInterface.inputTypesInfo{i}.dims;

        if emlDutInterface.inputTypesInfo{i}.iscomplex
            in(inIndex+1)=in(inIndex);
            in(inIndex).name=[emlDutInterface.inportNames{i},complexRealPostfix];
            in(inIndex+1).name=[emlDutInterface.inportNames{i},complexImagPostfix];
        end

        inData=loggedData.inputs{i};


        if in(inIndex).isVector
            if emlDutInterface.inputTypesInfo{i}.iscomplex

                in(inIndex).isConst=isConstVector(real(inData));
                if in(inIndex).isConst
                    in(inIndex).val=getConstVecInHexFormat(fi(real(inData)));
                end


                in(inIndex+1).isConst=isConstVector(imag(inData));
                if in(inIndex+1).isConst
                    in(inIndex+1).val=getConstVecInHexFormat(fi(imag(inData)));
                end
            else
                in(inIndex).isConst=isConstVector(inData);
                if in(inIndex).isConst
                    in(inIndex).val=getConstVecInHexFormat(fi(inData));
                end
            end
        else
            if emlDutInterface.inputTypesInfo{i}.iscomplex

                [in(inIndex).isConst,in(inIndex).val]=processScalar(real(inData));
                [in(inIndex+1).isConst,in(inIndex+1).val]=processScalar(imag(inData));
            else
                [in(inIndex).isConst,in(inIndex).val]=processScalar(inData);
            end
        end


        if emlDutInterface.inputTypesInfo{i}.iscomplex
            inIndex=inIndex+2;
        else
            inIndex=inIndex+1;
        end
    end

    moduleName=this.hCgInfo.topName;
    codegenDir=this.hCgInfo.targetDir;

    num_test_points=loggedData.iter;
    this.generateSystemCTB(in,out,moduleName,codegenDir,num_test_points);

end


function fxpName=getFxpName(toolName,isSigned,isIntegerType,wordSize,frac)
    if contains(toolName,"Xilinx Vitis HLS")
        typePrefix="ap_";
    else
        typePrefix="sc_";
    end

    isIntegerType=isIntegerType&&(wordSize<=64);

    if isSigned&&~isIntegerType
        fxpName=typePrefix+"fixed";
    elseif~isSigned&&~isIntegerType
        fxpName=typePrefix+"ufixed";
    elseif isSigned&&isIntegerType
        fxpName=typePrefix+"int";
    else
        fxpName=typePrefix+"uint";
    end

    if~isIntegerType
        fxpName=fxpName+"<"+num2str(wordSize)+","+num2str(wordSize+frac)+">";
    else
        fxpName=fxpName+"<"+num2str(wordSize)+">";
    end
end


function const=isConstVector(data)
    testVec=data(1,:);
    [nrow,~]=size(data);
    const=true;
    for k=2:nrow
        compare=real(data(k,:));
        if(~all(compare==testVec))
            const=false;
            break;
        end
    end
end


function constVec=getConstVecInHexFormat(data)
    testVec=data(1,:);
    [~,nCol]=size(data);
    for j=1:nCol
        tmp=testVec(j);
        constVec(j,:)=tmp.hex;
    end
end


function[const,val]=processScalar(data)
    if all(data==data(1))
        const=true;
        val=fi(data(1)).hex;
    else
        const=false;
        val=[];
    end
end
