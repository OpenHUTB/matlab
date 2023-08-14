function v=validateImplParams(this,hC)





    v=baseValidateImplParams(this,hC);


    value=this.getImplParams('Iterations');
    if~isempty(value)
        if any(double(value)==0)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:negativevalue'));
        elseif any(double(value)<3)
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:toosmallorlarge_s'));
        elseif any(double(value)>10)
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:toosmallorlarge_l'));
        end
    elseif isempty(value)&&ischar(value)
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:sqrtdefault'));
    end
