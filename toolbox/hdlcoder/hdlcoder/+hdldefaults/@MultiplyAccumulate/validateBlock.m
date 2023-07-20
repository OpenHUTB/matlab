function v=validateBlock(this,hC)



    v=hdlvalidatestruct;

    opMode=get_param(hC.SimulinkHandle,'opMode');
    in1signal=hC.PirInputPorts(1).Signal;
    in2signal=hC.PirInputPorts(2).Signal;
    in3signal=[];
    if(length(hC.PirInputPorts)>=3)
        in3signal=hC.PirInputPorts(3).Signal;
    end
    in1type=in1signal.Type.BaseType;
    in2type=in2signal.Type.BaseType;

    hDriver=hdlcurrentdriver;
    synthesisToolname=hDriver.getParameter('SynthesisTool');

    inputRate1=in1signal.SimulinkRate;
    inputRate2=in2signal.SimulinkRate;
    if inputRate1==0||inputRate2==0||(~isempty(in3signal)&&in3signal.SimulinkRate==0)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ContinuousSampleTimeUnsupported'));
    end

    if(~hdlsignalisdouble(in1signal)&&~hdlsignalisdouble(in2signal))
        if~(strcmpi(synthesisToolname,'Xilinx ISE')||strcmpi(synthesisToolname,'Altera Quartus II')||strcmpi(synthesisToolname,'Xilinx Vivado'))
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAccumulateNoSynthTool'));
            synthesisToolname='Xilinx Vivado';
        end

        resetType=hDriver.getParameter('async_reset');

        if strcmpi(synthesisToolname,'Altera Quartus II')&&resetType==0
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAccumulateAlteraSyncReset'));
        else
            if(strcmpi(synthesisToolname,'Xilinx ISE')||strcmpi(synthesisToolname,'Xilinx Vivado'))&&resetType~=0
                v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAccumulateXilinxAsyncReset'));
            end
        end
    end

    if(hdlsignalisdouble(in1signal)||hdlsignalisdouble(in2signal))
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAccumulateFloatingPoint'));
    end

    try
        if(in1signal.Type.Dimensions~=in2signal.Type.Dimensions)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultiplyAccumulateInputDimensions'));
        end
    catch
        try
            if(in1signal.Type.Dimensions>1)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultiplyAccumulateInputDimensions'));
            end
        catch
            try
                if(in2signal.Type.Dimensions>1)
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultiplyAccumulateInputDimensions'));
                end
            catch
                if(strcmp(opMode,'Vector'))

                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultiplyAccumulateInputScalar'));
                end
            end
        end
    end

    try
        if(~all([in1type.Signed,in1type.WordLength,in1type.FractionLength]==...
            [in2type.Signed,in2type.WordLength,in2type.FractionLength]))
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAccumulateInputFixedTypes'));
        end
    catch

    end

    if(isa(in3signal,'hdlcoder.signal'))
        if(hdlsignalisdouble(in3signal)&&~(hdlsignalisdouble(in1signal)||hdlsignalisdouble(in2signal)))
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAccumulateFloatingPoint'));
        end
    end

    if(~strcmp(opMode,'Vector'))
        nInputPorts=length(hC.PirInputPorts);
        signal_rate_array=zeros(1,nInputPorts);
        blkName=regexprep(get_param(hC.SimulinkHandle,'Name'),'\n',' ');
        for idx=1:nInputPorts
            signal_rate_array(idx)=[hC.PirInputPorts(idx).Signal.SimulinkRate];
            dinType=hC.PirInputSignals(idx).Type;
            if dinType.isArrayType
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:Pol2CartArray',blkName));%#ok<*AGROW>
            end
        end

        if~all(signal_rate_array==signal_rate_array(1))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultiplyAccumulateRatesDifferent'));
        end
    end
