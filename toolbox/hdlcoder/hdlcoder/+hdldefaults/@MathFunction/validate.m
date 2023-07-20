function v=validate(this,hC)


    v=hdlvalidatestruct;
    ptr=getFunctionImpl(this,hC);

    if(~isempty(ptr))
        ptr.implParams=this.implParams;
        v=ptr.baseValidate(hC);
    else
        Fname=get_param(hC.SimulinkHandle,'Function');
        in=hC.PirInputPorts(1).Signal;
        out=hC.PirOutputPorts(1).Signal;
        isInputValid=targetmapping.isValidDataType(in.Type);
        isOutputValid=targetmapping.isValidDataType(out.Type);

        if(isInputValid||isOutputValid)
            switch Fname
            case{'reciprocal','exp','log','mod','rem','square','conj',...
                'pow','magnitude^2','hypot','log10','sqrt','10^u','transpose','hermitian'}
                if targetcodegen.targetCodeGenerationUtils.isXilinxMode()
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TargetCodeGenMathFunctionUnsupportedByXilinx',Fname));
                else
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TargetCodeGenInvalidMathFunction',Fname));
                end
            otherwise
                if(targetcodegen.targetCodeGenerationUtils.isNFPMode())
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:funcunsupported',Fname));
                else
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:funcunsupported',Fname));
                end
            end
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:funcunsupported',Fname));
        end
    end

end


