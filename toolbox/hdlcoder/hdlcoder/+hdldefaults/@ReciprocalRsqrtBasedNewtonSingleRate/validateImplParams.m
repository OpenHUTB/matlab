function v=validateImplParams(this,hC)


    v=baseValidateImplParams(this,hC);


    value=this.getImplParams('Iterations');
    if~isempty(value)
        if any(double(value)==0)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipnegativevalue'));
        elseif any(double(value)<2)||any(double(value)>10)
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:recipoutofrange'));
        end
    elseif isempty(value)&&ischar(value)
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:recipdefault'));

    end
