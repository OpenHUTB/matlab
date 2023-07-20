function v=validatePipelineDepth(this,hC)




    v=hdlvalidatestruct;
    pipelinedepth=this.getImplParams('Pipelinedepth');
    isAuto=false;
    in1signal=hC.PirInputPorts(1).Signal;
    in2signal=hC.PirInputPorts(2).Signal;

    if isempty(pipelinedepth)
        pipelinedepth='auto';
    end

    if strcmpi(pipelinedepth,'auto')
        isAuto=true;
        latencyInfo=0;
    else
        latencyInfo=str2double(pipelinedepth);

        if(isnan(latencyInfo))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MultiplyAddPipelineDepthNaN',pipelinedepth));
            latencyInfo=0;
            isAuto=true;
        end
    end


    if latencyInfo>0||isAuto
        hDriver=hdlcurrentdriver;
        synthesisToolname=hDriver.getParameter('SynthesisTool');


        if(~hdlsignalisdouble(in1signal)&&~hdlsignalisdouble(in2signal))
            if~(strcmpi(synthesisToolname,'Xilinx ISE')||strcmpi(synthesisToolname,'Altera Quartus II')||strcmpi(synthesisToolname,'Intel Quartus Pro')||strcmpi(synthesisToolname,'Xilinx Vivado'))
                v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAddNoSynthTool'));
                synthesisToolname='Xilinx Vivado';
            end

            resetType=hDriver.getParameter('async_reset');

            if strcmpi(synthesisToolname,'Altera Quartus II')&&resetType==0
                v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAddAlteraSyncReset'));
            else
                if(strcmpi(synthesisToolname,'Xilinx ISE')||strcmpi(synthesisToolname,'Xilinx Vivado'))&&resetType~=0
                    v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAddXilinxAsyncReset'));
                end
            end
        end

        if(hdlsignalisdouble(in1signal)||hdlsignalisdouble(in2signal))&&~isAuto
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:MultiplyAddFloatingPoint'));
        end
    end
end


