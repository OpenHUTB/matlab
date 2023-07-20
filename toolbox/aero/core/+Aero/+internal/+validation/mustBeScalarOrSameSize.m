function mustBeScalarOrSameSize(a,b,name1,name2)





    if isscalar(b)||Aero.internal.validation.isSameSize(a,b)
        return
    else
        error(message('aero:validators:mustBeScalarOrSameSize',name1,name2))
    end

end

