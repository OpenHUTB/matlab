function B=cast(A,nt,preferBuiltIn)























    narginchk(2,3);
    validateattributes(A,{'numeric','embedded.fi','logical'},{});
    validateattributes(nt,{'embedded.numerictype'},{'scalar'});
    if nargin==2
        preferBuiltIn=true;
    else
        validateattributes(preferBuiltIn,{'logical','double'},{'scalar'});
        preferBuiltIn=logical(preferBuiltIn);
    end

    if~fixed.internal.type.isAnyFloat(nt)
        if any(isnan(A(:)))
            throwAsCaller(MException(message("fixed:fi:unsupportedNanInput")));
        end
        if any(isinf(A(:)))
            throwAsCaller(MException(message("fixed:fi:unsupportedInfInput")));
        end
    end

    if isboolean(nt)
        B=logical(uint8(A));
    elseif ishalf(nt)
        B=half(single(A));
    elseif preferBuiltIn&&fixed.internal.type.isEquivalentToBuiltin(nt)
        B=cast(A,nt.tostringInternalSlName);
    else
        B=fi(A,nt,'RoundingMethod','Round','OverflowAction','Saturate');
        B=removefimath(B);
    end
end
