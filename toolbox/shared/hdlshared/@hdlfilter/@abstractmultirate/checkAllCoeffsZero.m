function v=checkAllCoeffsZero(this,varargin)




    if any(strcmpi(fields(this),'PolyPhaseCoefficients'))&&all(all(this.PolyPhaseCoefficients==0))
        v=hdlvalidatestruct(1,message('HDLShared:filters:validate:allCoeffsZero'));
    else
        v=hdlvalidatestruct;
    end
