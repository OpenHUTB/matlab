function v=validateImplParams(this,hC)





    v=baseValidateImplParams(this,hC);
    v(end+1)=this.validateOnOffParam(hC,'AddClockEnablePort');
    addclken=this.getImplParams('AddClockEnablePort');

    if~isempty(addclken)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:deprecatedparam'));
    end
end
