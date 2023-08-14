function evalStr=getEvalString(this,DTString)














    evalStr=DTString;
    dt=this.evaluatedNumericType;
    if~isempty(dt)
        if isscaledtype(dt)
            evalStr=tostringInternalFixdt(dt);
        elseif isFloat(this)||isboolean(dt)
            evalStr=tostringInternalSlName(dt);
        end
    end
end
