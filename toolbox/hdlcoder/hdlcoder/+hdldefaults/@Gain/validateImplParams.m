function v=validateImplParams(this,hC)





    v=baseValidateImplParams(this,hC);

    tmpv=validate(this,'ConstMultiplierOptimization');
    if tmpv.Status~=0
        v(end+1)=tmpv;
    end
    v(end+1)=validateEnumParam(this,hC,'DSPStyle',{'on','off','none'});

    function v=validate(this,param)

        v=hdlvalidatestruct(0,message('hdlcoder:validate:nomsg'));

        value=this.getImplParams(param);

        if~isempty(value)
            if strcmp(param,'ConstMultiplierOptimization')
                if~strcmpi(value,'none')&&~strcmpi(value,'csd')&&~strcmpi(value,'fcsd')&&~strcmpi(value,'auto')
                    v=hdlvalidatestruct(1,message('hdlcoder:validate:unknownproperty',value));
                end
            end
        end
