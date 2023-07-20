function v=validateBlock(this,hC)




    impl=getFunctionImpl(this,hC);


    if isempty(impl)


        ports=this.getAllSLInputPorts(hC);


        ports=[ports,this.getAllSLOutputPorts(hC)];


        v=this.baseValidatePortDatatypes(ports);
        blockInfo=this.getBlockInfo(hC);






        in1SigT=hC.PirInputSignals(1).Type;
        in1Dim=in1SigT.getDimensions;
        in1Type=in1SigT.getLeafType;
        in2SigT=hC.PirInputSignals(2).Type;
        in2Dim=in2SigT.getDimensions;
        in2Type=in2SigT.getLeafType;
        in1WL=in1Type.WordLength;
        in2WL=in2Type.WordLength;
        outSigT=hC.PirOutputSignals(1).Type;
        outType=outSigT.getLeafType;
        numPipelineStages=ceil(log2(min(in1WL,in2WL)));

        if strcmpi(blockInfo.latencyStrategy,'CUSTOM')&&(blockInfo.customLatency>numPipelineStages)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InvalidCustomLatencyMultiplyShiftAdd',num2str(blockInfo.customLatency),hC.Name,num2str(ceil(log2(min(in1WL,in2WL)))),min(in1WL,in2WL)));
        end



        if in1SigT.isComplexType||in2SigT.isComplexType
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedComplexMultiplyShiftAdd'));
        end


        if(in1WL>62||in2WL>62)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:UnsupportedInputWordLengthMultiplyShiftAdd'));
        end

        allEqualFloatType=isequal(ClassName(in1Type),ClassName(in2Type),ClassName(outType));
        if in1Type.isFloatType&&in2Type.isFloatType&&outType.isFloatType&&allEqualFloatType
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InvalidArchdivide',hC.Name));
        end

        if(in1Dim~=in2Dim)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:multiplyshiftaddmixedscalarvector'));
        end
    else
        v=impl.validateBlock(hC);
    end
end




