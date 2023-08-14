function mustBeStringLengthLessThanOrEqual(str,len,name)





    if strlength(str)>len
        error(message('aero:validators:mustBeStringLengthLessThanOrEqual',name,string(len)))
    end

end

