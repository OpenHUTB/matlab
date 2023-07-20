function[left_idx_dbl,right_idx_dbl,wl_x]=checkLeftRightBitIndices(fcnNameStr,x,left_idx,right_idx)





    if~(isfi(x)&&isfixed(x))
        error(message('fixed:fi:unsupportedDataType',x.DataType));
    end

    wl_x=x.WordLength;

    if nargin==2
        left_idx_dbl=wl_x;
        right_idx_dbl=1;
    elseif nargin==3
        if~isnumeric(left_idx)
            error(message('fixed:fi:indexNotNumeric'));
        end
        left_idx_dbl=double(left_idx);
        right_idx_dbl=1;
    else
        if~(isnumeric(left_idx)&&isnumeric(right_idx))
            error(message('fixed:fi:indexNotNumeric'));
        end
        left_idx_dbl=double(left_idx);
        right_idx_dbl=double(right_idx);
    end

    if~(isscalar(left_idx_dbl)&&isscalar(right_idx_dbl))
        error(message('fixed:fi:indexNotScalar'));
    end

    if~(isreal(x)&&isreal(left_idx_dbl)&&isreal(right_idx_dbl))
        error(message('fixed:fi:unsupportedComplexArguments',fcnNameStr));
    end

    if((left_idx_dbl>wl_x)||(right_idx_dbl>left_idx_dbl)||(right_idx_dbl<=0))
        error(message('fixed:fi:bitIndicesNotInRange',fcnNameStr));
    end
