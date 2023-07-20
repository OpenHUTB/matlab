function v=validateDSPStyle(this,hC)


    v=hdlvalidatestruct;

    DSPStyleValue=this.getImplParams('DSPStyle');
    if strcmpi(DSPStyleValue,'on')
        slbh=hC.SimulinkHandle;
        gainFactor=this.getBlockDialogValue(slbh);
        gfval=double(gainFactor);

        hDriver=hdlcurrentdriver;
        synthesisToolname=hDriver.getParameter('SynthesisTool');
        if~(strcmpi(synthesisToolname,'Xilinx ISE')||...
            strcmpi(synthesisToolname,'Altera Quartus II')||...
            strcmpi(synthesisToolname,'Xilinx Vivado'))
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:validate:DSPStyleNoSynthesisTool'));
        end

        CSDParam=this.getImplParams('ConstMultiplierOptimization');
        if strcmpi(CSDParam,'csd')||strcmpi(CSDParam,'fcsd')||...
            strcmpi(CSDParam,'auto')
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:validate:ConflictGainSetting',CSDParam));
        end

        inputs=hC.SLInputPorts;
        in1=inputs(1).Signal;
        if(in1.Type.BaseType.is1BitType)
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:validate:DSPStyleIn1Bit'));
        end

        if isfloat(gainFactor)&&hdlsignalisdouble(in1)
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:validate:DSPStylefloatingPoint'));
        end


        genericParam=hC.Owner.IsNameGenericPort(get_param(hC.SimulinkHandle,'Gain'));
        if~genericParam
            if all(gfval(:)==1)||all(gfval(:)==-1)||...
                all(gfval(:)==0)||(hdlispowerof2(gfval)&&gfval>=0)
                v(end+1)=hdlvalidatestruct(2,...
                message('hdlcoder:validate:DSPStyleShiftOpt'));
            end
        end
    end
end


