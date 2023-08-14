function v=checkAllCoeffsZero(this)




    if any(strcmpi(fields(this),'Coefficients'))&&all(all(this.Coefficients==0))
        v=hdlvalidatestruct(1,message('HDLShared:filters:validate:allCoeffsZero'));
    else
        v=hdlvalidatestruct;
    end
