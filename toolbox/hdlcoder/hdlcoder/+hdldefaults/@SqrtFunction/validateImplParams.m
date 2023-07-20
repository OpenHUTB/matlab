function v=validateImplParams(this,hC)





    v=baseValidateImplParams(this,hC);

    value=this.getImplParams('UseMultiplier');
    if~isempty(value)
        if~((strcmpi(value,'on'))||(strcmpi(value,'off')))
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:Invalid_Value'));
        end
    end


