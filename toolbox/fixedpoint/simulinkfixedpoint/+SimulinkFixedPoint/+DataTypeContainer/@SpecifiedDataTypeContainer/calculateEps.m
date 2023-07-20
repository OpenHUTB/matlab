function calculateEps(this)







    this.isEpsCalculated=true;



    if~isempty(this.evaluatedNumericType)
        if isFixed(this)||isBoolean(this)
            dt=fixed.internal.type.extractNumericType(this.evaluatedNumericType);
            if~(isFixed(this)&&contains(dt.DataTypeMode,'unspecified'))
                this.eps=double(eps(dt));
            end
        elseif isFloat(this)
            if isdouble(this.evaluatedNumericType)
                this.eps=double(eps(0));
            elseif issingle(this.evaluatedNumericType)
                this.eps=double(eps(single(0)));
            else
                this.eps=double(eps(half(0)));
            end
        end
    end
end
