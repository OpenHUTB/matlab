function v=validate(this,hC)




    v=hdlvalidatestruct;
    ptr=getFunctionImpl(this,hC);
    bfp=hC.SimulinkHandle;
    if~isempty(ptr)
        v=ptr.baseValidate(hC);
    else
        Fname=get_param(hC.SimulinkHandle,'Function');

        if targetmapping.hasFloatingPointPort(hC)
            switch Fname
            case{'tan','acos','asin','atan',...
                'sinh','cosh','tanh','asinh','acosh','atanh'}
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TargetCodeGenInvalidTrigonometricFunction',Fname));
            otherwise
                if targetcodegen.targetCodeGenerationUtils.isNFPMode()
                    v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:trigfuncunsupported',Fname));
                end


                if strcmpi(get_param(bfp,'ApproximationMethod'),'CORDIC')
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:trigApproxMethodNotNone'));
                end
            end
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:trigfuncunsupported',Fname));
        end

    end


