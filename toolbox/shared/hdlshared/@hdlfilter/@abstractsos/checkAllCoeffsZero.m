function v=checkAllCoeffsZero(this)





    if any(strcmpi(fields(this),'Coefficients'))&&any(all(this.Coefficients(:,1:3).'==0))
        v=hdlvalidatestruct(1,message('HDLShared:filters:validate:allNumCoeffsZero'));
    else
        v=hdlvalidatestruct;
    end
