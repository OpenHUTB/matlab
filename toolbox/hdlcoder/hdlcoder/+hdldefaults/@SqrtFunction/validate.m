function v=validate(this,hC)





    v=hdlvalidatestruct;
    Fname=get_param(hC.SimulinkHandle,'Function');
    impl=getFunctionImpl(this,hC);

    if(strcmpi(Fname,'Sqrt')&&isempty(impl))
        v=validateSqrtbitset(this,hC);

    elseif(~isempty(getFunctionImpl(this,hC)))
        v=getFunctionImpl(this,hC).baseValidate(hC);
    else
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:sqrtfuncunsupported',Fname));
    end

    if(strcmpi(Fname,'rsqrt'))
        out=hC.SLOutputSignals(1);
        if targetmapping.mode(out,'Altera')
            return;
        elseif targetmapping.mode(out,'Xilinx')
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:RsqrtNotSupportedByXilinx'));
            return;
        end



        archname=char(this.ArchitectureNames);
        if(strcmpi(archname,'SqrtFunction'))
            if(isFloatType(out.Type.BaseType))&&~targetcodegen.targetCodeGenerationUtils.isNFPMode()
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nfprecipsqrt'));
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedarchforRsqrt'));
            end
        end


    end

end



